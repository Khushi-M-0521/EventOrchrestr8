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
        () => Navigator.of(context).push(
              MaterialPageRoute(
                  builder: (context) => p.isSignedIn //if true get shared preference data
                      ? const HomeScreen()
                      : const OnboardingScreen()),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return const OnboardingScreen();
  }
}
