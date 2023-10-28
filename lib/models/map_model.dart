import 'package:flutter/foundation.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/global/drawing/map_drawing_model.dart';
import 'package:flutter_map_toy/models/map_icon_model.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:uuid/uuid.dart';

// flutter packages pub run build_runner build --delete-conflicting-outputs

part 'map_model.g.dart';

@HiveType(typeId: 0)
class MapModel extends HiveObject {

  @HiveField(0)
  String name;

  @HiveField(1)
  String id;

  @HiveField(2)
  List<MapIconModel> icons;

  @HiveField(3)
  List<MapDrawingModel> drawings;

  @HiveField(4)
  List<double> mainCoordinates;
  
  @HiveField(5)
  DateTime modified;

  MapModel(
    this.name,
    this.id,
    this.icons,
    this.drawings,
    this.mainCoordinates,
    this.modified,
  );

  static const String hiveKey = 'map_model_hive_key_xx';

  static Box<MapModel> get hiveBox => Hive.box<MapModel>(hiveKey);

  static openBox() {
    if (!Hive.isBoxOpen(hiveKey)) {
      return Hive.openBox<MapModel>(hiveKey);
    }
  }

  static MapModel? getById(String id) {
    return hiveBox.get(id);
  }

  static Future<MapModel> createByMapState({
    required MapState state,
    required String name,
    String? id,
  }) async {
    return MapModel(
      name,
      id ?? const Uuid().v1(),
      state.icons.toList(),
      state.drawings.toList(),
      (await state.mapViewCenter).coordinates,
      DateTime.now()
    );
  }

  @override
  save() {
    final itemKey = id;
    return hiveBox.put(itemKey, this);
  }

  saveOrCreate() {

  }

  static test() {
    if (kDebugMode) {
      print(hiveBox.keys);
    }
  }

}