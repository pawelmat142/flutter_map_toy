import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map_toy/global/drawing/drawing_line.dart';
import 'package:flutter_map_toy/global/drawing/drawing_painter.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/global/drawing/map_drawing_model.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

abstract class DrawUtil {

  static Future<Marker> getMarkerFromDrawingModel(MapDrawingModel mapDrawingModel) async {
    return Marker(
      markerId: MarkerId(mapDrawingModel.id),
      position: MapUtil.pointFromCoordinates(mapDrawingModel.coordinates),
      icon: await bitmapFromModel(mapDrawingModel),
    );
  }

  static Future<BitmapDescriptor> bitmapFromModel(MapDrawingModel mapDrawingModel) async {
    final drawingLines = mapDrawingModel.restoreLines();
    return await CustomPaint(
      painter: DrawingPainter(drawingLines: drawingLines),
      child: SizedBox(
        width: DrawUtil.width(drawingLines),
        height: DrawUtil.height(drawingLines),
      ),
    ).toBitmapDescriptor(waitToRender: Duration.zero);
  }

  static Future<MapDrawingModel> getModelFromDrawing({
    required BuildContext context,
    required List<DrawingLine> drawingLines,
    required GoogleMapController mapController,
    String? drawingModelId,
  }) async {
      //removes drawing offset between screen edge
      final xs = dxs(drawingLines);
      final minX = xs.reduce(min);
      final maxX = xs.reduce(max);
      final ys = dys(drawingLines);
      final minY = ys.reduce(min);
      final maxY = ys.reduce(max);
      final height = maxY - minY;
      var drawing = addOffset(
          drawingLines: drawingLines,
          dx: minX,
          dy: minY
      );

      //TODO add padding - stroke width is cut when create marker

      final pixelRatio = getPixelRatio(context);
      final drawingCenter = Point((minX + maxX)/2 , (minY + maxY)/2 + height/2);
      final drawingPosition = await mapController.getLatLng(ScreenCoordinate(
        x: (drawingCenter.x * pixelRatio).toInt(),
        y: (drawingCenter.y * pixelRatio).toInt(),
      ));

      return MapDrawingModel('', '',
        drawingModelId ?? const Uuid().v1(),
        drawingPosition.coordinates,
        drawing.first.color.value,
        drawing.first.width,
        MapDrawingModel.storeLines(drawing)
      );
  }

  static List<DrawingLine> prepareDrawingOffsetToEdit({
    required MapDrawingModel mapDrawingModel,
    required ScreenCoordinate screenCoordinate,
    required BuildContext context,
  }) {
    final pixelRatio = getPixelRatio(context);
    final drawingLines = mapDrawingModel.restoreLines();
    return addOffset(
        drawingLines: drawingLines,
        dy: (screenCoordinate.y.toDouble() / -pixelRatio) + height(drawingLines),
        dx: (screenCoordinate.x.toDouble() / -pixelRatio) + width(drawingLines)/2,
    );
  }

  static double getPixelRatio(BuildContext context) {
    return Platform.isAndroid
        ? MediaQuery.of(context).devicePixelRatio
        : 1.0;
  }

  static List<DrawingLine> addOffset({ required List<DrawingLine> drawingLines, double? dx, double? dy }) {
    return drawingLines.map((point) => DrawingLine(
        width: point.width,
        color: point.color,
        offsets: point.offsets.map((o) => Offset(o.dx - (dx ?? 0), o.dy - (dy ?? 0))).toList()
    )).toList();
  }

  static Iterable<double> dxs(List<DrawingLine> drawingLines) {
    return drawingLines.expand((drawingLine) => drawingLine.offsets.map((o) => o.dx));
  }

  static Iterable<double> dys(List<DrawingLine> drawingLines) {
    return drawingLines.expand((drawingLine) => drawingLine.offsets.map((o) => o.dy));
  }

  static double width(List<DrawingLine> drawingLines) {
    final xs = dxs(drawingLines);
    return xs.reduce(max) - xs.reduce(min);
  }

  static double height(List<DrawingLine> drawingLines) {
    final ys = dys(drawingLines);
    return ys.reduce(max) - ys.reduce(min);
  }

}