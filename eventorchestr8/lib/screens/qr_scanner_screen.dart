import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isProcessing = false;
  bool isValid = false;
  String? scannedUsername;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.pauseCamera();
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) {
      if (!isProcessing) {
        isProcessing = true;
        // You can handle the scanned data here, like validating the attendee's ticket
        Map<String, dynamic> data = _parseQRCode(scanData.code);
        scannedUsername = data['username'];
        isValid = data['isValid']; // Replace with your actual validation logic
        setState(() {
          isProcessing = true;
        });
        _showOverlay();
      }
    });
  }

  Map<String, dynamic> _parseQRCode(String? code) {
    // Simulate parsing the QR code and returning a username
    // In a real scenario, you should parse the actual QR code data
    return {
      'username': 'Khushi',
      'isValid': code == 'h8j2k4l5m6n7o8p9q1r2s3t4u5v6w7x8y9z1a2b3c4d5e6f7g8h9j0', // Replace with actual validation logic
    };
  }

  void _showOverlay() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pop();
            controller?.resumeCamera();
            setState(() {
              isProcessing = false;
            });
          },
          child: Scaffold(
            backgroundColor: Colors.black54,
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Icon(
                    isValid ? Icons.check_circle_outline : Icons.cancel_outlined,
                    color: isValid ? Colors.green : Colors.red,
                    size: 200,
                  ),
                  SizedBox(height: 20),
                  if(isValid)
                  Text(
                    scannedUsername ?? 'Unknown User',
                    style: TextStyle(color: Colors.white, fontSize: 24),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Admit')),
      body: QRView(
        key: qrKey,
        onQRViewCreated: _onQRViewCreated,
        overlay: QrScannerOverlayShape(
          borderColor: Theme.of(context).colorScheme.primary,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 300,
        ),
      ),
    );
  }
}
