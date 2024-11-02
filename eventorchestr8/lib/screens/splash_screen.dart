import 'dart:async';

import 'package:eventorchestr8/provider/auth_provider.dart';
import 'package:eventorchestr8/screens/home_screen.dart';
import 'package:eventorchestr8/screens/onboarding_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    final p = Provider.of<AuthProvider>(context, listen: false);
    Timer(
        const Duration(seconds: 3),
        () => Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(
                  builder: (context) =>
                      p.isSignedIn //if true get shared preference data
                          ? const HomeScreen()
                          : const OnboardingScreen()),
              (route) => false,
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Center(
            child: CircleAvatar(
              radius: 100,
              child: Image.asset(
                "assets/images/logo.jpg",
              ),
            ),
          ),
          const SizedBox(height: 20),
          // You can add a loading spinner or some text
          // const CircularProgressIndicator(),
        ],
      ),
    );
  }
}
