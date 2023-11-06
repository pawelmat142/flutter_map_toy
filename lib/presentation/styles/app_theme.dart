import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_fonts.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';

abstract class AppTheme {

  static final ThemeData appLightTheme = ThemeData(
    scaffoldBackgroundColor: AppColor.primary,
    dialogBackgroundColor: AppColor.primary,

    primaryColor: AppColor.primary,
    primaryColorDark: AppColor.primaryDark,
    primaryColorLight: AppColor.primaryLight,

    secondaryHeaderColor: AppColor.secondary,

    appBarTheme: const AppBarTheme(
      backgroundColor: AppColor.primaryDark,
      titleTextStyle: AppStyle.titleLargeTextStyle
    ),

    fontFamily: AppFont.robotoMono,

    listTileTheme: const ListTileThemeData(
      textColor: Colors.white,
    ),

    textTheme: const TextTheme(
      titleLarge: AppStyle.titleLargeTextStyle,
      labelMedium: AppStyle.labelMediumTextStyle,
      titleMedium: AppStyle.textInput,
    ),

    inputDecorationTheme: const InputDecorationTheme(
      focusColor: AppColor.secondary,
      labelStyle: TextStyle(
          color: AppColor.white30
      ),
      floatingLabelStyle: TextStyle(
          color: AppColor.blue
      ),
      enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColor.secondaryInactive)
      ),
      focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColor.secondary)
      ),
      focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColor.secondary)
      ),
    ),

    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColor.secondary
    ),

    dialogTheme: const DialogTheme(
      titleTextStyle: AppStyle.titleLargeTextStyle,
      contentTextStyle: AppStyle.labelMediumTextStyle,
      iconColor: AppColor.redContrast,
    ),

  );



}