import 'package:flutter_map_toy/global/drawing/map_drawing_model.dart';
import 'package:flutter_map_toy/models/map_icon_model.dart';
import 'package:flutter_map_toy/models/map_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

abstract class AppHive {

  static initBoxes() async {

    await Hive.initFlutter();

    Hive.registerAdapter(MapIconModelAdapter());
    Hive.registerAdapter(MapDrawingModelAdapter());
    Hive.registerAdapter(MapModelAdapter());

    await MapModel.openBox();

  }
}