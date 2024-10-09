import 'package:eventorchestr8/constants/color_scheme.dart';
import 'package:eventorchestr8/screens/splash_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData.light().copyWith(
        colorScheme: lightColorScheme,  
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: darkColorScheme,  
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}

