import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:encrypt/encrypt.dart' as encrypt; // For AES decryption
import 'package:crypto/crypto.dart'; // For HMAC-SHA256
import 'package:web3dart/web3dart.dart'; // For blockchain interaction
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For environment variables

class QRValidator {
  late Web3Client client;
  late DeployedContract contract;
  final privateKey = dotenv.env['PRIVATE_KEY']!;
  late final Credentials credentials;

  QRValidator() {
    final rpcUrl = dotenv.env['RPC_URL']!;
    final contractAddress = dotenv.env['CONTRACT_ADDRESS']!;
    credentials = EthPrivateKey.fromHex(privateKey);

    client = Web3Client(rpcUrl, http.Client());

    final contractABI = dotenv.env['ABI']!;
    contract = DeployedContract(
      ContractAbi.fromJson(contractABI, 'Ticketing'),
      EthereumAddress.fromHex(contractAddress),
    );
  }

  Future<bool> validateQRCode(String qrCode) async {
    try {
      // Step 1: Extract QR Code Components
      final parts = qrCode.split('#');
      if (parts.length != 4) {
        throw Exception("Invalid QR Code format");
      }
      final encryptedCombined = parts[0];
      final encryptedPositions = parts[1];
      final authTag = parts[2];
      final cid = parts[3];

      // Step 2: Decrypt the combined string using AES
      final decryptedCombined = _aesDecrypt(encryptedCombined, 'my_secret_key_1234567890');
      print("Decrypted Combined String: $decryptedCombined");

      // Step 3: Extract Embedded String, Encrypted Positions, and AuthTag
      final modifiedStream = decryptedCombined.substring(0, decryptedCombined.length - encryptedPositions.length - authTag.length);
      print("Modified Stream: $modifiedStream");

      // Step 4: Verify AuthTag using HMAC-SHA256
      final isAuthTagValid = _verifyAuthTag(modifiedStream, authTag, 'my_secret_key_1234567890');
      if (!isAuthTagValid) {
        throw Exception("Authentication Tag is invalid");
      }
      print("AuthTag Verified Successfully");

      // Step 5: Retrieve Metadata from IPFS using CID
      final ipfsData = await _retrieveFromIPFS(cid);
      final expectedTicketId = _generateTicketId(ipfsData['eventID'], ipfsData['userID'], ipfsData['uuid']);
      print("Expected Ticket ID: $expectedTicketId");

      // Step 6: Compare Ticket ID
      if (!modifiedStream.contains(expectedTicketId)) {
        throw Exception("Ticket ID does not match");
      }
      print("Ticket ID Verified Successfully");

      // Step 7: Check Ticket Status on Blockchain
      final isTicketValid = await _checkTicketStatus(expectedTicketId);
      if (!isTicketValid) {
        throw Exception("Ticket is no longer valid or has already been used");
      }
      print("Ticket is Valid");

      // Step 8: Update Ticket Status to Used
      await _updateTicketStatus(expectedTicketId, 2); // 2 = Used
      print("Ticket Status Updated to Used");

      return true;
    } catch (e) {
      print("QR Code Validation Failed: $e");
      return false;
    }
  }

  // AES Decryption
  String _aesDecrypt(String encryptedData, String aesKey) {
    final key = encrypt.Key.fromUtf8(aesKey);
    final iv = encrypt.IV.fromUtf8('my_secret_iv_1234567890'); // Example IV
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.decrypt64(encryptedData, iv: iv);
  }

  // Verify AuthTag using HMAC-SHA256
  bool _verifyAuthTag(String message, String authTag, String key) {
    final hmac = Hmac(sha256, utf8.encode(key));
    final generatedAuthTag = hmac.convert(utf8.encode(message)).toString();
    return authTag == generatedAuthTag;
  }

  // Retrieve Metadata from IPFS
  Future<Map<String, dynamic>> _retrieveFromIPFS(String cid) async {
    final url = 'https://gateway.pinata.cloud/ipfs/$cid';
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception("Failed to retrieve data from IPFS: ${response.body}");
    }
  }

  // Generate Ticket ID
  String _generateTicketId(String eventId, String userId, String uuid) {
    final rawId = "$eventId$userId$uuid";
    return sha256.convert(utf8.encode(rawId)).toString();
  }

  // Check Ticket Status on Blockchain
  Future<bool> _checkTicketStatus(String ticketId) async {
    final function = contract.function('getTicketStatus');
    final ticketIdBytes = Uint8List.fromList(utf8.encode(ticketId));
    final result = await client.call(
      contract: contract,
      function: function,
      params: [ticketIdBytes],
    );
    return result[0] == 1; // Assuming 1 = Active
  }

  // Update Ticket Status to Used
  Future<void> _updateTicketStatus(String ticketId, int newStatus) async {
    final function = contract.function('updateTicketStatus');
    final ticketIdBytes = Uint8List.fromList(utf8.encode(ticketId));
    await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [ticketIdBytes, BigInt.from(newStatus)],
      ),
      chainId: 1337, // Update as per your network
    );
  }
}