import 'package:hive_flutter/adapters.dart';

// flutter packages pub run build_runner build --delete-conflicting-outputs

part 'map_icon_model.g.dart';

@HiveType(typeId: 1)
class MapIconModel extends HiveObject {

  @HiveField(0)
  int iconDataPoint;

  @HiveField(1)
  int colorInt;

  @HiveField(2)
  double size;

  @HiveField(3)
  String id;

  @HiveField(4)
  List<double> coordinates; // [ longitude, latitude ]

  @HiveField(5)
  String type;

  MapIconModel(
      this.iconDataPoint,
      this.colorInt,
      this.size,
      this.id,
      this.coordinates,
      this.type
  );

  MapIconModel rescale(double rescaleFactor) {
    return MapIconModel(
        iconDataPoint,
        colorInt,
        size * rescaleFactor,
        id,
        coordinates,
        type
    );
  }

}