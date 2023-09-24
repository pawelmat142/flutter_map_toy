import 'dart:math';

import 'package:google_maps_flutter/google_maps_flutter.dart';

abstract class MapUtil {

  static const double kZoomDefault = 16;
  static const double kZoomInitial = 14.5;

  static const double earthRadius = 6371; // Earth's radius in kilometers


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

}