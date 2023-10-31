import 'dart:math';

import 'package:flutter_map_toy/models/map_icon_model.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/utils/icon_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

abstract class MapUtil {

  static const double kZoomDefault = 16;
  static const double kZoomInitial = 18;

  static const double earthRadius = 6371; // Earth's radius in kilometers

  static CameraPosition getCameraPosition(LatLng point) {
    return CameraPosition(
      target: point,
      zoom: MapUtil.kZoomInitial
    );
  }

  static LatLng pointFromCoordinates(List<double> coordinates) {
    if (coordinates.length != 2) {
      throw 'coordinates length != 2';
    }
    return LatLng(coordinates[1], coordinates[0]);
  }

  static double distanceBetweenPoints(LatLng pointOne, LatLng pointTwo) {
    double dLat = _degreesToRadians(pointTwo.latitude - pointOne.latitude);
    double dLon = _degreesToRadians(pointTwo.longitude - pointOne.longitude);

    double a = pow(sin(dLat / 2), 2) +
        cos(_degreesToRadians(pointOne.latitude)) * cos(_degreesToRadians(pointTwo.latitude)) * pow(sin(dLon / 2), 2);

    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c * 1000; // Distance in meters [m]
  }

  static double _degreesToRadians(double degrees) => degrees * pi / 180;

  static Future<double> calcMapViewDiagonalDistance(GoogleMapController googleMapController) async {
    final viewPort = await googleMapController.getVisibleRegion();
    return distanceBetweenPoints(viewPort.southwest, viewPort.northeast);
  }

  //TODO name and description icon marker

  static Future<Marker> getMarkerFromIcon(MapIconModel mapIconPoint) async {
    final craft = IconUtil.craftFromMapIconPoint(mapIconPoint);
    if (craft.incomplete) throw 'craft incomplete!';
    craft.size = craft.size! / 5;
    return Marker(
      markerId: MarkerId(craft.id!),
      position: MapUtil.pointFromCoordinates(mapIconPoint.coordinates),
      icon: await craft.widget().toBitmapDescriptor(),
    );
  }

  static void animateCameraToMapCenter(MapState state) {
    if (state.mapModelId.isEmpty || state.markers.isEmpty) return;

    CameraUpdate cameraUpdate;

    if (state.markers.length == 1) {
      cameraUpdate = CameraUpdate.newCameraPosition(CameraPosition(
          target: state.markers.first.position, zoom: kZoomInitial));
    } else {
      Set<double> latitudes = {};
      Set<double> longitudes = {};
      for (var marker in state.markers) {
        longitudes.add(marker.position.longitude);
        latitudes.add(marker.position.latitude);
      }
      final minY = longitudes.reduce(min);
      final maxY = longitudes.reduce(max);
      final minX = latitudes.reduce(min);
      final maxX = latitudes.reduce(max);
      final bounds = LatLngBounds(
          southwest: LatLng(minX, minY),
          northeast: LatLng(maxX, maxY)
      );
      cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);
    }
    state.mapController?.animateCamera(cameraUpdate);
  }

  static Future<void> animateCameraToDefaultRotation(MapState state) async {
    if (state.cameraPosition == null) {
      return;
    }
    return state.mapController?.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: state.cameraPosition!.target,
      zoom: state.cameraPosition!.zoom,
      bearing: 0
    )));
  }

}