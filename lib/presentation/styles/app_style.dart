import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_fonts.dart';

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


  static const titleLargeTextStyle = TextStyle(
      fontSize: AppFontSize.big,
      fontWeight: FontWeight.w500,
      color: AppColor.secondary,
      letterSpacing: 1.3
  );

  static const labelMediumTextStyle = TextStyle(
      fontSize: AppFontSize.medium,
      fontWeight: FontWeight.w500,
      color: AppColor.white80,
      letterSpacing: 1.1
  );

  static const secondaryMedium = TextStyle(
      fontSize: AppFontSize.medium,
      fontWeight: FontWeight.w500,
      color: AppColor.secondary,
      letterSpacing: 1.1
  );

  static const textInput = TextStyle(
      fontSize: AppFontSize.medium,
      fontWeight: FontWeight.w500,
      color: AppColor.white,
      letterSpacing: 1.1
  );

  static const listTileTitle = TextStyle(
      fontSize: AppFontSize.medium,
      fontWeight: FontWeight.w500,
      color: AppColor.secondary,
      letterSpacing: 1
  );

  static const listTileSubtitle = TextStyle(
      fontSize: AppFontSize.small,
      fontWeight: FontWeight.w300,
      color: AppColor.white,
      letterSpacing: 1
  );


}