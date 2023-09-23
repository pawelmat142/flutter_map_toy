import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_fonts.dart';

abstract class AppTheme {

  static final ThemeData appLightTheme = ThemeData(
    scaffoldBackgroundColor: AppColor.primary,
    backgroundColor: AppColor.primary,
    dialogBackgroundColor: AppColor.primary,

    primaryColor: AppColor.primary,
    primaryColorDark: AppColor.primaryDark,
    primaryColorLight: AppColor.primaryLight,


    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.primaryDark,
      titleTextStyle: titleLargeTextStyle
    ),

    fontFamily: AppFonts.robotoMono,

    textTheme: const TextTheme(
      titleLarge: titleLargeTextStyle
    ),

  );

  static const titleLargeTextStyle = TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.w500,
      color: AppColor.secondary,
      letterSpacing: 1.3
  );
}