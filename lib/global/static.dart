import 'package:flutter/material.dart';
import 'package:flutter_map_toy/global/wizard/wizard_theme.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';

class Static {
  static final wizardTheme = WizardTheme(
    activeColor: AppColor.secondary,
    disabledColor: AppColor.primary,
    enabledColor: AppColor.blue,
    backgroundColor: AppColor.primaryDark,

    padding: AppStyle.defaultPaddingVal,
    radius: AppStyle.defaultRadiusVal,
  );

  static double getModalTileSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    const itemsPerRow = 4;
    return (screenWidth - itemsPerRow*AppStyle.wrapSpacing - 2*AppStyle.defaultPaddingVal) / itemsPerRow;
  }
}