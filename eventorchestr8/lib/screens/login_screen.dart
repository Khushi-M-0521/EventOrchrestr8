import 'package:eventorchestr8/widgets/rounded_button.dart';
import 'package:eventorchestr8/widgets/subtitle_text.dart';
import 'package:eventorchestr8/widgets/title_text.dart';
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("EventOrchestr8..."),
              RoundedButton(onPressed: () {},
              child: const Text("button"),),
              const TitleText(text: "Verify Your Mobile Number"),
              const SubtitleText(text: "A Verification Code is sent to (+91) 9010102030"),
            ],
          ),
        ),
      );
  }
}