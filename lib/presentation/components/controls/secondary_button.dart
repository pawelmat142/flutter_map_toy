import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {

  final String text;
  final VoidCallback? onPressed;
  final bool active;

  const SecondaryButton(this.text, {
    this.onPressed,
    this.active = true,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: active ? onPressed : null,
      child: Text(text),
    );
  }

}
