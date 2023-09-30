import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map_toy/models/map_icon_point.dart';
import 'package:flutter_map_toy/utils/icon_util.dart';
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

  static Future<Marker> getMarkerFromIcon(MapIconPoint mapIconPoint) async {
    final iconData = IconData(mapIconPoint.iconDataPoint, fontFamily: 'MaterialIcons');
    final iconStr = String.fromCharCode(iconData.codePoint);

    final pictureRecorder = PictureRecorder();
    final canvas = Canvas(pictureRecorder);

    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    final imgSize = mapIconPoint.size;

    textPainter.text = TextSpan(
        text: iconStr,
        style: TextStyle(
          letterSpacing: 0.0,
          fontSize: imgSize,
          // fontSize: imgSize/2,
          fontWeight: FontWeight.w200,
          fontFamily: iconData.fontFamily,
          color: Color(mapIconPoint.colorInt),
        )
    );
    textPainter.layout();
    // textPainter.paint(canvas, Offset(imgSize/4, imgSize/2));
    textPainter.paint(canvas, const Offset(0, 0));
    // textPainter.paint(canvas, Offset(0, 0));

    final picture = pictureRecorder.endRecording();
    final image = await picture.toImage(imgSize.toInt(), imgSize.toInt());
    final bytes = await image.toByteData(format: ImageByteFormat.png);

    if (bytes == null) throw "bytes == null";

    final bitmapDescriptor = BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
    final marker = Marker(
      markerId: MarkerId(mapIconPoint.id),
      position: IconUtil.pointFromCoordinates(mapIconPoint.coordinates),
      icon: bitmapDescriptor,
    );

    return marker;
  }

}