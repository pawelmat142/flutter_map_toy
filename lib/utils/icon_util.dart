import 'package:flutter/material.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/models/map_icon_model.dart';
import 'package:flutter_map_toy/presentation/dialogs/icon_craft.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class IconUtil {

  static IconCraft craftFromMapIconPoint(MapIconModel mapIconPoint) {
    final craft = IconCraft();
    craft.id = mapIconPoint.id;
    craft.size = mapIconPoint.size;
    craft.color = Color(mapIconPoint.colorInt);
    craft.iconData = _iconDataFromMapIconPoint(mapIconPoint);
    return craft;
  }

  static IconData _iconDataFromMapIconPoint(MapIconModel mapIconPoint) {
    return IconData(mapIconPoint.iconDataPoint, fontFamily: 'MaterialIcons');
  }

  static MapIconModel mapIconPointFromCraft(IconCraft craft, LatLng point) {
    Log.log('IconData: ${craft.iconData?.codePoint.toString()}');
    Log.log('Color: ${craft.color.hashCode.toString()}');
    Log.log('id: ${craft.id.toString()}');
    craft.validate();
    return MapIconModel(
        craft.iconData!.codePoint,
        craft.color!.value,
        craft.size!,
        craft.id!,
        point.coordinates,
        'default'
    );
  }

}