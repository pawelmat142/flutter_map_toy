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

    elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
            textStyle: MaterialStateProperty.all<TextStyle>(const TextStyle(
              fontFamily: AppFont.robotoMono,
              fontWeight: FontWeight.w500
            ))
        )
    ),

    fontFamily: AppFont.robotoMono,

    listTileTheme: const ListTileThemeData(
      textColor: Colors.white,
    ),

    textTheme: const TextTheme(

      titleLarge: titleLargeTextStyle,

      labelMedium: TextStyle(
        fontSize: AppFontSize.medium,
        fontWeight: FontWeight.w500,
        color: AppColor.white80,
        letterSpacing: 1.1
      ),
    )

  );

  static const titleLargeTextStyle = TextStyle(
      fontSize: AppFontSize.big,
      fontWeight: FontWeight.w500,
      color: AppColor.secondary,
      letterSpacing: 1.3
  );
}