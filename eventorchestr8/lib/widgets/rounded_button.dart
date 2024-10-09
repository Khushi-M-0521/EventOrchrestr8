import 'package:flutter/material.dart';

class RoundedButton extends StatelessWidget {
  const RoundedButton({required this.onPressed, required this.child,this.style,super.key});

  final void Function() onPressed;
  final Widget child;
  final ButtonStyle? style;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed, 
      style: style,
      child: child
    );
  }
}