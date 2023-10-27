import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map_toy/global/drawing/drawing_line.dart';
import 'package:flutter_map_toy/global/drawing/drawing_painter.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/models/map_drawing_model.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

abstract class DrawUtil {

  static Future<Set<Marker>> getMarkersFromDrawingModels(Iterable<MapDrawingModel> drawingModels) async {
    final futures = drawingModels.map((drawingModel) => getMarkerFromDrawingModel(drawingModel));
    return (await Future.wait(futures)).toSet();
  }

  static Future<Marker> getMarkerFromDrawingModel(MapDrawingModel mapDrawingModel) async {
    return Marker(
      markerId: MarkerId(mapDrawingModel.id),
      position: MapUtil.pointFromCoordinates(mapDrawingModel.coordinates),
      icon: await bitmapFromModel(mapDrawingModel),
    );
  }

  static Future<BitmapDescriptor> bitmapFromModel(MapDrawingModel mapDrawingModel) async {
    final drawingLines = mapDrawingModel.restoreLines();
    final dxs = drawingLines.expand((drawingLine) => drawingLine.offsets.map((o) => o.dx).toList());
    final minX = dxs.reduce(min);
    final maxX = dxs.reduce(max);
    final dys = drawingLines.expand((drawingLine) => drawingLine.offsets.map((o) => o.dy).toList());
    final minY = dys.reduce(min);
    final maxY = dys.reduce(max);

    return await CustomPaint(
      painter: DrawingPainter(drawingLines: drawingLines),
      child: SizedBox(
        width: maxX - minX,
        height: maxY - minY,
      ),
    ).toBitmapDescriptor(waitToRender: Duration.zero);
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

      final drawingCenter = Point((minX + maxX)/2 , (minY + maxY)/2 + height/2);
      final drawingPosition = await mapController.getLatLng(ScreenCoordinate(
        x: (drawingCenter.x * devicePixelRatio).toInt(),
        y: (drawingCenter.y * devicePixelRatio).toInt(),
      ));

      return MapDrawingModel('', '', const Uuid().v1(),
        drawingPosition.coordinates,
        drawing.first.color.value,
        drawing.first.width,
        MapDrawingModel.storeLines(drawing)
      );
  }


  // static Future<MapDrawingModel> getModelFromDrawing({
  //   required double devicePixelRatio,
  //   required List<DrawingLine> drawingLines,
  //   required GoogleMapController mapController
  // }) async {
  //   final dxs = drawingLines.expand((drawingLine) => drawingLine.offsets.map((o) => o.dx).toList());
  //   final minX = dxs.reduce(min);
  //   final maxX = dxs.reduce(max);
  //   final dys = drawingLines.expand((drawingLine) => drawingLine.offsets.map((o) => o.dy).toList());
  //   final minY = dys.reduce(min);
  //   final maxY = dys.reduce(max);
  //   final height = maxY - minY;
  //
  //   var drawing = addOffset(
  //       drawingLines: drawingLines,
  //       dx: minX,
  //       dy: minY
  //   );
  //
  //   final widget = CustomPaint(
  //     painter: DrawingPainter(drawingLines: drawing),
  //     child: SizedBox(
  //       width: maxX - minX,
  //       height: height,
  //     ),
  //   );
  //   final bitmap = await createImageFromWidget(widget,
  //     waitToRender: Duration.zero,
  //   );
  //
  //   final drawingCenter = Point((minX + maxX)/2 , (minY + maxY)/2 + height/2);
  //   final drawingPosition = await mapController.getLatLng(ScreenCoordinate(
  //     x: (drawingCenter.x * devicePixelRatio).toInt(),
  //     y: (drawingCenter.y * devicePixelRatio).toInt(),
  //   ));
  //   final id = const Uuid().v1();
  //
  //   return MapDrawingModel(id, id, bitmap, id, drawingPosition.coordinates);
  // }

  static List<DrawingLine> addOffset({ required List<DrawingLine> drawingLines, double? dx, double? dy }) {
    return drawingLines.map((point) => DrawingLine(
        width: point.width,
        color: point.color,
        offsets: point.offsets.map((o) => Offset(o.dx - (dx ?? 0), o.dy - (dy ?? 0))).toList()
    )).toList();
  }
}