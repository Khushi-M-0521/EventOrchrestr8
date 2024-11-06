import 'package:flutter/services.dart';

class SecureScreen {
  static const MethodChannel _channel =
      MethodChannel('com.example.eventorchestr8/secure_screen');

  static Future<void> enableSecureScreen() async {
    await _channel.invokeMethod('enableSecureScreen');
  }

  static Future<void> disableSecureScreen() async {
    await _channel.invokeMethod('disableSecureScreen');
  }
}
