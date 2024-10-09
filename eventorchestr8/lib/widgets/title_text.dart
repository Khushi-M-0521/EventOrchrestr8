import 'package:flutter/material.dart';

class TitleText extends StatelessWidget {
  const TitleText({required this.text,super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style:  Theme.of(context).textTheme.titleLarge!
    );
  }
}