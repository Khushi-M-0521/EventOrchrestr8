import 'package:flutter/material.dart';

class SubtitleText extends StatelessWidget {
  const SubtitleText({required this.text,super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyLarge!.copyWith(
        color: Colors.grey,
      ),
    );
  }
}