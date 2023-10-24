import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map_toy/global/drawing/drawing_line.dart';
import 'package:flutter_map_toy/global/drawing/drawing_painter.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/models/map_drawing_model.dart';
import 'package:flutter_map_toy/models/map_icon_point.dart';
import 'package:flutter_map_toy/utils/icon_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

abstract class MapUtil {

  static const double kZoomDefault = 16;
  static const double kZoomInitial = 14.5;

  static const double earthRadius = 6371; // Earth's radius in kilometers

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

  static Future<Marker> getMarkerFromIcon(MapIconPoint mapIconPoint) async {
    final craft = IconUtil.craftFromMapIconPoint(mapIconPoint);
    if (craft.incomplete) throw 'craft incomplete!';
    craft.size = craft.size! / 5;
    return Marker(
      markerId: MarkerId(craft.id!),
      position: MapUtil.pointFromCoordinates(mapIconPoint.coordinates),
      icon: await craft.widget.toBitmapDescriptor(),
    );
  }


  static Marker getMarkerFromDrawingModel(MapDrawingModel mapDrawingModel) {
    return Marker(
      markerId: MarkerId(mapDrawingModel.id),
      position: pointFromCoordinates(mapDrawingModel.coordinates),
      icon: BitmapDescriptor.fromBytes(mapDrawingModel.bitmap),
    );
  }

  static Future<MapDrawingModel> getModelFromDrawing({
    required double devicePixelRatio,
    required List<DrawingLine> drawingLines,
    required GoogleMapController mapController
  }) async {
    final dxs = drawingLines.expand((drawingLine) => drawingLine.offsets.map((o) => o.dx).toList());
    final minX = dxs.reduce(min);
    final maxX = dxs.reduce(max);
    final dys = drawingLines.expand((drawingLine) => drawingLine.offsets.map((o) => o.dy).toList());
    final minY = dys.reduce(min);
    final maxY = dys.reduce(max);
    final height = maxY - minY;

    var drawing = addOffset(
        drawingLines: drawingLines,
        dx: minX,
        dy: minY
    );

    final widget = CustomPaint(
      painter: DrawingPainter(drawingLines: drawing),
      child: SizedBox(
        width: maxX - minX,
        height: height,
      ),
    );
    final bitmap = await createImageFromWidget(widget,
      waitToRender: Duration.zero,
    );

    final drawingCenter = Point((minX + maxX)/2 , (minY + maxY)/2 + height/2);
    final drawingPosition = await mapController.getLatLng(ScreenCoordinate(
      x: (drawingCenter.x * devicePixelRatio).toInt(),
      y: (drawingCenter.y * devicePixelRatio).toInt(),
    ));
    final id = const Uuid().v1();

    return MapDrawingModel(id, id, bitmap, id, drawingPosition.coordinates);
  }

  static List<DrawingLine> addOffset({ required List<DrawingLine> drawingLines, double? dx, double? dy }) {
    return drawingLines.map((point) => DrawingLine(
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