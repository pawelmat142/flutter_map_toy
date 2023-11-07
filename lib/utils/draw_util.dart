import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_line.dart';
import 'package:flutter_map_toy/global/drawing/drawing_painter.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/global/drawing/map_drawing_model.dart';
import 'package:flutter_map_toy/models/map_cubit.dart';
import 'package:flutter_map_toy/models/marker_info.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:widget_to_marker/widget_to_marker.dart';

abstract class DrawUtil {

  static Future<Marker> getMarkerFromDrawingModel(MapDrawingModel mapDrawingModel, BuildContext context) async {
    final cubit = BlocProvider.of<MapCubit>(context);
    final markerId = MarkerId(mapDrawingModel.id);
    return Marker(
      markerId: markerId,
      position: MapUtil.pointFromCoordinates(mapDrawingModel.coordinates),
      icon: await bitmapFromModel(mapDrawingModel),
      infoWindow: getInfoWindow(mapDrawingModel),
      flat: true,
      draggable: false,
      consumeTapEvents: true,
      zIndex: 10,
      onTap: () {
        cubit.state.mapController?.showMarkerInfoWindow(markerId);
        cubit.selectMarker(markerId.value, context);
      },
    );
  }

  static InfoWindow getInfoWindow(MapDrawingModel mapDrawingModel) {
    return InfoWindow(title: MapUtil.getMarkerName(mapDrawingModel.name),
        snippet: mapDrawingModel.description.isEmpty ? null : mapDrawingModel.description);
  }

  static Future<BitmapDescriptor> bitmapFromModel(MapDrawingModel mapDrawingModel) {
    final drawingLines = mapDrawingModel.restoreLines();

    //adding padding to avoid cut line bcs of its  width
    final padding = mapDrawingModel.width;

    return CustomPaint(
      painter: DrawingPainter(drawingLines: drawingLines),
      child: SizedBox(
        width: DrawUtil.width(drawingLines) + padding,
        height: DrawUtil.height(drawingLines) + padding,
      ),
    ).toBitmapDescriptor(waitToRender: Duration.zero);
  }

  static Future<MapDrawingModel> getModelFromDrawing({
    required BuildContext context,
    required List<DrawingLine> drawingLines,
    required GoogleMapController mapController,
    String? drawingModelId,
    MarkerInfo? markerInfo,
    double? rescaleFactor,
  }) async {
      //adding padding to avoid cut line bcs of its width
      final padding = drawingLines.first.width/2;

      final xs = dxs(drawingLines);
      final minX = xs.reduce(min) - padding;
      final maxX = xs.reduce(max) + padding;
      final ys = dys(drawingLines);
      final minY = ys.reduce(min) - padding;
      final maxY = ys.reduce(max) + padding;
      final height = maxY - minY;

      //removes drawing offset between screen edge
      var drawing = addOffset(
          drawingLines: drawingLines,
          dx: minX,
          dy: minY,
      );

      final pixelRatio = getPixelRatio(context);
      final drawingCenter = Point((minX + maxX)/2 , (minY + maxY)/2 + height/2);
      final drawingPosition = await mapController.getLatLng(ScreenCoordinate(
        x: (drawingCenter.x * pixelRatio).toInt(),
        y: (drawingCenter.y * pixelRatio).toInt(),
      ));

      return MapDrawingModel(
        markerInfo?.name ?? '',
        markerInfo?.getDescription() ?? '',
        drawingModelId ?? const Uuid().v1(),
        drawingPosition.coordinates,
        drawing.first.color.value,
        drawing.first.width,
        MapDrawingModel.storeLines(drawing)
      ).rescale(rescaleFactor ?? 1);
  }

  static List<DrawingLine> prepareDrawingOffsetToEdit({
    required MapDrawingModel mapDrawingModel,
    required ScreenCoordinate screenCoordinate,
    required BuildContext context,
  }) {
    final pixelRatio = getPixelRatio(context);
    final drawingLines = mapDrawingModel.restoreLines();
    final padding = mapDrawingModel.width/2;
    return addOffset(
        drawingLines: drawingLines,
        dy: (screenCoordinate.y.toDouble() / -pixelRatio) + height(drawingLines) + padding*2,
        dx: (screenCoordinate.x.toDouble() / -pixelRatio) + width(drawingLines)/2 + padding,
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