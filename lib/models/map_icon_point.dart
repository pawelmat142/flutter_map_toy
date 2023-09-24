import 'package:flutter_map_toy/presentation/dialogs/icon_craft.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:flutter_map_toy/global/extensions.dart';


// flutter packages pub run build_runner build --delete-conflicting-outputs

@JsonSerializable()
@HiveType(typeId: 1)
class MapIconPoint extends HiveObject {

  @HiveField(0)
  int iconDataPoint;

  @HiveField(1)
  int colorInt;

  @HiveField(2)
  double size;

  @HiveField(3)
  String id;

  @HiveField(4)
  List<double> coordinates;

  @HiveField(5)
  String type;

  MapIconPoint(
      this.iconDataPoint,
      this.colorInt,
      this.size,
      this.id,
      this.coordinates,
      this.type
  );

  static MapIconPoint create(IconCraft craft, LatLng point) {
    Log.log('IconData: ${craft.iconData?.codePoint.toString()}');
    Log.log('Color: ${craft.color.hashCode.toString()}');
    Log.log('id: ${craft.id.toString()}');
    if (!craft.complete) throw 'craft is incomplete!';
    return MapIconPoint(
        craft.iconData!.codePoint,
        craft.color!.value,
        craft.size!,
        craft.id!,
        point.coordinates,
        'default'
    );
  }

  MapIconPoint rescale(double rescaleFactor) {
    return MapIconPoint(
        iconDataPoint,
        colorInt,
        size * rescaleFactor,
        id,
        coordinates,
        type
    );
  }

}