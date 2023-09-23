import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';

class BlueButton extends StatelessWidget {

  final String text;
  final VoidCallback? onPressed;
  final bool active;

  const BlueButton(this.text, {
    this.onPressed,
    this.active = true,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: () {
        if (active && onPressed != null) {
          onPressed!();
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? AppColor.blue : AppColor.blueInactive
      ),
      child: Text(text, style: TextStyle(
          color: active ? AppColor.blueContrast : AppColor.primaryDark
      )),
    );
  }

}

