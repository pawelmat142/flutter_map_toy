import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_fonts.dart';

abstract class AppElevatedButton {

  static TextStyle textStyle({ bool active = true }) {
    return TextStyle(
        fontFamily: AppFont.robotoMono,
        color: active ? AppColor.primaryDark : AppColor.white30
    );
  }

}