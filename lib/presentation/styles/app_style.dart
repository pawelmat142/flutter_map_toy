import 'package:flutter/material.dart';

abstract class AppStyle {

  static const double defaultPaddingVal = 20;
  static const defaultPadding = EdgeInsets.symmetric(horizontal: defaultPaddingVal);
  static const defaultPaddingAll = EdgeInsets.all(defaultPaddingVal);

  static const double defaultRadiusVal = 15;
  static const defaultRadius = Radius.circular(defaultRadiusVal);

  static const double controlDistanceVal = 15;
  static const horizontalDefaultDistance = SizedBox(width: controlDistanceVal);
  static const verticalDefaultDistance = SizedBox(height: controlDistanceVal);

  static const double wrapSpacing = 12;

}