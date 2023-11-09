import 'dart:math';

import 'package:flutter_map_toy/models/map_state.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapUtil {

  static const double kZoomDefault = 16;
  static const double kZoomInitial = 18;

  static const double earthRadius = 6371; // Earth's radius in kilometers

  static const LatLng initialPosition = LatLng(54.3991806, 18.5571554);

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

  static animateCameraToMapCenter(MapState state) {
    CameraUpdate cameraUpdate;

    if (state.markers.isEmpty) {
      cameraUpdate = CameraUpdate.newCameraPosition(state.initialCameraPosition!);
    } else if (state.markers.length == 1) {
      cameraUpdate = CameraUpdate.newCameraPosition(CameraPosition(
          target: state.markers.first.position, zoom: kZoomInitial)
      );
    } else {
      final lats = state.markers.map((marker) => marker.position.latitude);
      final lngs = state.markers.map((marker) => marker.position.longitude);
      final bounds = LatLngBounds(
          southwest: LatLng(lats.reduce(min), lngs.reduce(min)),
          northeast: LatLng(lats.reduce(max), lngs.reduce(max))
      );
      cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 150);
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

  static getMarkerName(String name) {
    return name.isEmpty ? ' ' : name;
  }

}