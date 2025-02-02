import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart'; // For SHA-256
//import 'package:encrypt/encrypt.dart' as encrypt; // For AES encryption
import 'package:web3dart/web3dart.dart'; // For blockchain interaction
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For environment variables

class TicketingWorkflow {
  late Web3Client client;
  late Credentials credentials;
  late DeployedContract contract;

  TicketingWorkflow() {
    final rpcUrl = dotenv.env['RPC_URL']!;
    final privateKey = dotenv.env['PRIVATE_KEY']!;
    final contractAddress = dotenv.env['CONTRACT_ADDRESS']!;

    client = Web3Client(rpcUrl, http.Client());

    credentials = EthPrivateKey.fromHex(privateKey);

    final contractABI = dotenv.env['ABI']!;
    contract = DeployedContract(
      ContractAbi.fromJson(contractABI, 'Ticketing'),
      EthereumAddress.fromHex(contractAddress),
    );
  }

  Future<String> handleRegistration(
      String eventId, String userId, int price, int paymentId) async {
    try {
      String uuid=generateRandomStream();
      // Step 1: Prepare metadata
      final metadata = {
        "eventID": eventId,
        "userID": userId,
        "uuid": uuid,
      };

      // Step 2: Upload metadata to IPFS
      final cid = await _uploadToIPFS(metadata);
      print("Uploaded metadata to IPFS. CID: $cid");

      // Step 3: Generate Ticket ID
      final ticketId = _generateTicketId(eventId, userId, uuid);
      print("Generated Ticket ID: $ticketId");

      // Step 4: Add block to blockchain
      final txHash = await _addBlockToBlockchain(ticketId, price, paymentId, cid);
      print("Block added to blockchain. Transaction hash: $txHash");

      // Step 5: Generate QR Code
      final qrCodeData = await _generateQRCode(cid, ticketId);
      print("Generated QR Code data: $qrCodeData");

      return qrCodeData;
      // Step 6: Show QR Code in the app
      // _showQRCodeScreen(qrCodeData, eventId, userId);
    } catch (e) {
      print("Error during registration: $e");
      return "";
    }
  }

  // Function to upload metadata to IPFS
  Future<String> _uploadToIPFS(Map<String, dynamic> metadata) async {
    final url = 'https://api.pinata.cloud/pinning/pinJSONToIPFS';
    final response = await http.post(
      Uri.parse(url),
      headers: {
        'Content-Type': 'application/json',
        'pinata_api_key': dotenv.env['PINATA_API_KEY']!,
        'pinata_secret_api_key': dotenv.env['PINATA_SECRET_API_KEY']!,
      },
      body: jsonEncode(metadata),
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return json['IpfsHash'];
    } else {
      throw Exception("Failed to upload to IPFS: ${response.body}");
    }
  }

  // Generate a Ticket ID using SHA-256
  String _generateTicketId(String eventId, String userId, String uuid) {
    final rawId = "$eventId$userId$uuid";
    return sha256.convert(utf8.encode(rawId)).toString();
  }

  // Add block to blockchain
  Future<String> _addBlockToBlockchain(
      String ticketId, int price, int paymentId, String cid) async {
    final function = contract.function('createTicket');
    final ticketIdBytes = Uint8List.fromList(utf8.encode(ticketId));
    final transaction = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [
          ticketIdBytes,
          BigInt.from(price),
          BigInt.from(paymentId),
          cid,
        ],
      ),
      chainId: 1337,
    );
    return transaction;
  }

  // Generate a QR code string
  Future<String> _generateQRCode(String cid, String ticketID) async {
    // final randomStream = generateRandomStream(); // Example
    // final combinedData = embedTicketID(randomStream, ticketId); // Simplified structure
    // final encryptedData = _encryptData(combinedData);
    // return encryptedData;
    final randomStream = generateRandomStream();
    final (modifiedStream,positions) = embedTicketID(randomStream, ticketID);
    //final positions = List.generate(ticketID.length, (_) => Random.secure().nextInt(randomStream.length));
    final encryptedPositions = encryptPositions(positions).base64;
    final authTag = hmacSHA256(modifiedStream, 'my_secret_key_1234567890').toString();
    final encryptedCombined = encryptCombinedString(modifiedStream, encryptedPositions, authTag).base64;
    return '$encryptedCombined#$encryptedPositions#$authTag#$cid';
  }

  String generateRandomStream() {
    final random = Random.secure();
    final stream = List.generate(32, (_) => random.nextInt(256).toRadixString(16));
    return stream.join();
  }

  // *Embed Ticket ID at random positions*
  (String,List<int>) embedTicketID(String randomStream, String ticketID) {
    final positions = List.generate(ticketID.length, (_) => Random.secure().nextInt(randomStream.length));
    var modifiedStream = randomStream;
    for (var i = 0; i < ticketID.length; i++) {
      modifiedStream = modifiedStream.substring(0, positions[i]) + ticketID[i] + modifiedStream.substring(positions[i] + 1);
    }
    return (modifiedStream,positions);
  }

  // **Encrypt positions using AES**
  Encrypted encryptPositions(List<int> positions) {
    // **AES encryption key and IV**
    final key = Key.fromUtf8('my_secret_key_1234567890');
    final iv = IV.fromUtf8('my_secret_iv_1234567890');
    final encrypter = Encrypter(AES(key));
    final encrypted = encrypter.encrypt(positions.join(), iv: iv);
    return encrypted;
  }

  // **Generate AuthTag using HMAC-SHA256**
  Digest hmacSHA256(String message, String key) {
    // **HMAC-SHA256 key**
    final hmac = Hmac(sha256, utf8.encode(key));
    final digest = hmac.convert(utf8.encode(message));
    return digest;
  }

  // **Combine and encrypt combined string using AES-256**
  Encrypted encryptCombinedString(String modifiedStream, String encryptedPositions, String authTag) {
    // **AES encryption key and IV**
    final key = Key.fromUtf8('my_secret_key_1234567890');
    final iv = IV.fromUtf8('my_secret_iv_1234567890');
    final encrypter = Encrypter(AES(key));
    final combined = '$modifiedStream$encryptedPositions$authTag';
    final encrypted = encrypter.encrypt(combined, iv: iv);
    return encrypted;
  }

  // Encrypt data using AES
  // String _encryptData(String data) {
  //   final key = encrypt.Key.fromUtf8(generateRandomStream());
  //   final iv = encrypt.IV.fromLength(16);
  //   final encrypter = encrypt.Encrypter(encrypt.AES(key));
  //   return encrypter.encrypt(data, iv: iv).base64;
  // }

  // Display QR Code in the app
  // void _showQRCodeScreen(String qrCodeData, String eventId, String userId) {
  //   // Navigate to the ticket page and display QR code
  //   print("Display QR Code for Event $eventId and User $userId");
  // }
}