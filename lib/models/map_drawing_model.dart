import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter_map_toy/global/drawing/drawing_line.dart';
import 'package:hive_flutter/hive_flutter.dart';

// flutter packages pub run build_runner build --delete-conflicting-outputs

part 'map_drawing_model.g.dart';

@HiveType(typeId: 2)
class MapDrawingModel extends HiveObject {

  @HiveField(0)
  String name;

  @HiveField(1)
  String description;

  @HiveField(2)
  String id;

  @HiveField(3)
  List<double> coordinates;

  @HiveField(4)
  int colorInt;

  @HiveField(5)
  double width;

  @HiveField(6)
  List<List<List<double>>> points;

  MapDrawingModel(this.name, this.description, this.id, this.coordinates, this.colorInt, this.width, this.points);

  static List<List<List<double>>> storeLines(List<DrawingLine> lines) {
    return lines.map((line) => line.offsets.map((offset) => [ offset.dx, offset.dy ]).toList()).toList();
  }

  List<DrawingLine> restoreLines() {
    int i = 0;
    return points.map((line) => DrawingLine(
      id: ++i,
      color: Color(colorInt),
      width: width,
      offsets: line.map((offset) => Offset(offset.first, offset.last)).toList()
    )).toList();
  }
}