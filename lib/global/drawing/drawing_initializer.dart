import 'package:flutter/cupertino.dart';

abstract class DrawingInitializer {

  Future<Color?> selectColor(BuildContext context);

  Future<double?> selectWidth(BuildContext context);

}