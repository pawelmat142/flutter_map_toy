import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/models/map_cubit.dart';
import 'package:flutter_map_toy/models/map_icon_model.dart';
import 'package:flutter_map_toy/presentation/dialogs/icon_craft.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

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

  static MapIconModel mapIconPointFromCraft(IconCraft craft, {
    required LatLng point,
  }) {
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
        'default',
        '',
        ''
    );
  }

  static Future<Marker> getMarkerFromIcon(MapIconModel mapIconModel, BuildContext context) async {
    final craft = IconUtil.craftFromMapIconPoint(mapIconModel);
    if (craft.incomplete) throw 'craft incomplete!';
    craft.size = craft.size! / 5;
    final cubit = BlocProvider.of<MapCubit>(context);
    final markerId = MarkerId(mapIconModel.id);
    return Marker(
        markerId: MarkerId(craft.id!),
        position: MapUtil.pointFromCoordinates(mapIconModel.coordinates),
        icon: await craft.widget().toBitmapDescriptor(),
        infoWindow: getInfoWindow(mapIconModel),
        draggable: true,
        consumeTapEvents: true,
        zIndex: 10,
        onDragEnd: (point) {
          cubit.replaceMarker(context, point, markerId: markerId.value);
        },
        onTap: () {
          cubit.state.mapController?.showMarkerInfoWindow(markerId);
          cubit.selectMarker(markerId.value, context);
        }
    );
  }

  static InfoWindow getInfoWindow(MapIconModel mapIconModel) {
    return InfoWindow(title: MapUtil.getMarkerName(mapIconModel.name),
        snippet: mapIconModel.description.isEmpty ? null : mapIconModel.description);
  }

}