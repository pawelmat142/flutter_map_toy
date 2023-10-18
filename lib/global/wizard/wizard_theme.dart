import 'package:flutter/material.dart';

class WizardTheme {
  final Color activeColor;
  final Color enabledColor;
  final Color disabledColor;
  final Color backgroundColor;

  final double padding;
  final double radius;

  final double stepCircleSize;
  final double stepCirclePadding;
  final double stepActiveSize;
  final double progressLineHeight;

  double get separatorsSpacing => stepCircleSize + stepCirclePadding*2;

  WizardTheme({
    required this.activeColor,
    required this.enabledColor,
    required this.disabledColor,
    required this.backgroundColor,

    required this.padding,
    required this.radius,

    this.stepCircleSize = 22,
    this.stepCirclePadding = 8,
    this.stepActiveSize = 32,
    this.progressLineHeight = 4,
  });
}
