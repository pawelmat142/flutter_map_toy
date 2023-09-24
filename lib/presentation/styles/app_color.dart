import 'package:flutter/material.dart';

abstract class AppColor {

  static const Color white30 = Colors.white30;
  static const Color white80 = Color(0xCCFFFFFF);

  static const Color black70 = Color(0xB3000000);

  static const Color primaryDark = Color(0xFF232F34);
  static const Color primary = Color(0xFF344955);
  static const Color primaryLight = Color(0xFF4A6572);

  static const Color secondary = Color(0xFFF9AA33);
  static const Color secondaryInactive = Color(0x57C58425);
  static const Color secondaryContrast = primaryDark;

  static const Color blue = Color(0xFF3366FF);
  static const Color blueInactive = Color(0x812749B4);
  static const Color blueContrast = black70;

  static const Color red = Color(0xFFFF5733);
  static const Color redInactive = Color(0x74AD3922);
  static const Color redContrast = primaryDark;

  static const Color green = Color(0xFF00FF00);

  static const Color lightBlue = Color(0xFF00CCFF);

  static const Color purple = Color(0xFFCC00FF);

  static List<Color> mapFlutterIconColors = [
    secondary,
    blue,
    red,
    green,
    lightBlue,
    purple,
    Colors.black,
    Colors.white,
  ];

}