import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart'; // For SHA-256
import 'package:encrypt/encrypt.dart' as encrypt; // For AES encryption// For QR code screen
import 'package:web3dart/web3dart.dart'; // For blockchain interaction
import 'package:flutter_dotenv/flutter_dotenv.dart'; // For environment variables

class TicketingWorkflow {
  late Web3Client client;
  late Credentials credentials;
  late DeployedContract contract;

  TicketingWorkflow() {
    
    if (!dotenv.isInitialized) {
      throw NotInitializedError();
    }

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
  Future<void> showQR(
BuildContext context, String qrCodeData, String eventId, String userId
  )async {
    try{
      _showQRCodeScreen(context,qrCodeData, eventId, userId);
    }
    catch(e){
      print("Error showing QR code: $e $e.stackTrace");
    }
  }

  Future<String> handleRegistration(
      BuildContext context, String eventId, String userId, String uuid, int price, int paymentId) async {
    try {
      // runApp(MaterialApp(home: BlockCreation()));

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

      // Step 6: Show QR Code in the app
      // _showQRCodeScreen(context,qrCodeData, eventId, userId);
      return qrCodeData;
    } catch (e) {
      print("Error during registration: $e $e.stackTrace");
      return '';
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

   final ticketIdBytes = Uint8List.fromList(utf8.encode(ticketId).sublist(0, 32));

    final transaction = await client.sendTransaction(
      credentials,
      Transaction.callContract(
        contract: contract,
        function: function,
        parameters: [
          ticketIdBytes,
          BigInt.from(price),
          BigInt.from(paymentId),
        ],
      ),
      chainId: 1337,
    );
    return transaction;
  }

  // Generate a QR code string
  Future<String> _generateQRCode(String cid, String ticketId) async {
    final randomStream = "aGj4dLpM2aB5eK7cRfT8xV9yS6zQ5wE4rF3t2gH1iJ"; // Example
    final combinedData = "$ticketId#$cid"; // Simplified structure
    final encryptedData = _encryptData(combinedData);
    return encryptedData;
  }

  // Encrypt data using AES
  String _encryptData(String data) {
    final key = encrypt.Key.fromUtf8('12345678901234567890123456789012');
    final iv = encrypt.IV.fromLength(16);
    final encrypter = encrypt.Encrypter(encrypt.AES(key));
    return encrypter.encrypt(data, iv: iv).base64;
  }

  // Display QR Code in the app
  void _showQRCodeScreen(BuildContext context, String qrCodeData, String eventId, String userId) {
    print("Display QR Code for Event $eventId and User $userId");
  }
}
