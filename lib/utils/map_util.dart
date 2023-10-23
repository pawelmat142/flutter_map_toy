import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map_toy/global/drawing/drawing_painter.dart';
import 'package:flutter_map_toy/global/drawing/drawing_point.dart';
import 'package:flutter_map_toy/models/map_icon_point.dart';
import 'package:flutter_map_toy/utils/icon_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

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
    final craft = IconUtil.craftFromMapIconPoint(mapIconPoint);
    if (craft.incomplete) throw 'craft incomplete!';
    craft.size = craft.size! / 5;
    return Marker(
      markerId: MarkerId(craft.id!),
      position: IconUtil.pointFromCoordinates(mapIconPoint.coordinates),
      icon: await craft.widget.toBitmapDescriptor(),
    );
  }

  static Future<Marker> getMarkerFromDrawing({
    required double devicePixelRatio,
    required List<DrawingPoint> drawingPoints,
    required GoogleMapController mapController
  }) async {

    final dxs = drawingPoints.expand((drawingPoint) => drawingPoint.offsets.map((o) => o.dx).toList());
    final minX = dxs.reduce(min);
    final maxX = dxs.reduce(max);
    final dys = drawingPoints.expand((drawingPoint) => drawingPoint.offsets.map((o) => o.dy).toList());
    final minY = dys.reduce(min);
    final maxY = dys.reduce(max);
    final height = maxY - minY;

    var drawingPointsCutToEdge = addOffset(
        drawingPoints: drawingPoints,
        dx: minX,
        dy: minY
    );

    final bitmap = await CustomPaint(
      painter: DrawingPainter(drawingPoints: drawingPointsCutToEdge),
      child: SizedBox(
        width: maxX - minX,
        height: height,
      ),
    ).toBitmapDescriptor();

    final drawingCenter = Point((minX + maxX)/2 , (minY + maxY)/2 + height/2);

    final drawingPosition = await mapController.getLatLng(ScreenCoordinate(
        x: (drawingCenter.x * devicePixelRatio).toInt(),
        y: (drawingCenter.y * devicePixelRatio).toInt(),
    ));

    return Marker(
        markerId: MarkerId(const Uuid().v1()),
        position: drawingPosition,
        icon: bitmap
    );
  }

  static List<DrawingPoint> addOffset({ required List<DrawingPoint> drawingPoints, double? dx, double? dy }) {
    return drawingPoints.map((point) => DrawingPoint(
      width: point.width,
      color: point.color,
      offsets: point.offsets.map((o) => Offset(o.dx - (dx ?? 0), o.dy - (dy ?? 0))).toList()
    )).toList();
  }

  //   static Future<Marker> getMarkerFromIcon(MapIconPoint mapIconPoint) async {
  //   final iconData = IconData(mapIconPoint.iconDataPoint, fontFamily: 'MaterialIcons');
  //   final iconStr = String.fromCharCode(iconData.codePoint);
  //
  //   final pictureRecorder = PictureRecorder();
  //   final canvas = Canvas(pictureRecorder);
  //
  //   const iconProportion = 0.8;
  //   final size = mapIconPoint.size/2;
  //   final rectOffset = size*0.025;
  //   final iconOffset = (size*(1-iconProportion)/2)+rectOffset;
  //   final color = Color(mapIconPoint.colorInt);
  //   final radius = size*0.2;
  //
  //   final rect = RRect.fromLTRBR(rectOffset, rectOffset, size, size, Radius.circular(radius));
  //
  //   canvas.drawRRect(rect, Paint()..color = color.withAlpha(50));
  //
  //   canvas.drawPath(
  //     Path()
  //       ..addRRect(rect),
  //     Paint()
  //       ..color = color
  //       ..strokeWidth = size*0.05
  //       ..style = PaintingStyle.stroke
  //   );
  //
  //   final textPainter = TextPainter(textDirection: TextDirection.ltr);
  //   textPainter.text = TextSpan(
  //       text: iconStr,
  //       style: TextStyle(
  //         letterSpacing: 0.0,
  //         fontSize: size*iconProportion,
  //         fontWeight: FontWeight.w200,
  //         fontFamily: iconData.fontFamily,
  //         color: Color(mapIconPoint.colorInt),
  //       )
  //   );
  //   textPainter.layout();
  //   textPainter.paint(canvas, Offset(iconOffset, iconOffset));
  //
  //   final imgSize = (size*1.05).toInt();
  //   final image = await pictureRecorder.endRecording().toImage(imgSize, imgSize);
  //   final bytes = await image.toByteData(format: ImageByteFormat.png);
  //
  //   if (bytes == null) throw "bytes == null";
  //
  //   final bitmapDescriptor = BitmapDescriptor.fromBytes(bytes.buffer.asUint8List());
  //   final marker = Marker(
  //     markerId: MarkerId(mapIconPoint.id),
  //     position: IconUtil.pointFromCoordinates(mapIconPoint.coordinates),
  //     icon: bitmapDescriptor,
  //   );
  //
  //   return marker;
  // }

}