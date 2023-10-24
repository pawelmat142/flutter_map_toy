import 'dart:typed_data';
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
  Uint8List bitmap;

  @HiveField(3)
  String id;

  @HiveField(4)
  List<double> coordinates;

  MapDrawingModel(this.name, this.description, this.bitmap, this.id, this.coordinates);
}