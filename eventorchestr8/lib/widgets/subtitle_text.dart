import 'package:flutter/material.dart';

class SubtitleText extends StatelessWidget {
  const SubtitleText({required this.text,this.textAlign ,super.key});

  final String text;
  final TextAlign? textAlign;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      textAlign: textAlign,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Colors.grey,
      ),
    );
  }
}