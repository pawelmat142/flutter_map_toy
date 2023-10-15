import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

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