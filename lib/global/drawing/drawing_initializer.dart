import 'package:flutter/material.dart';

abstract class DrawingInitializer {

  Color get defaultColor => Colors.black;

  double get defaultWidth => 5;

  Future<Color?> selectColor(BuildContext context);

  Future<double?> selectWidth(BuildContext context);

}