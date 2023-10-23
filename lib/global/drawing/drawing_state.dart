import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'drawing_initializer.dart';
import 'drawing_painter.dart';
import 'drawing_point.dart';

enum BlocState {
  on,
  off
}

class DrawingState {

  BlocState state;
  bool on;
  Color color;
  double width;
  List<DrawingPoint> drawingPoints;
  DrawingPoint? currentDrawingPoint;
  DrawingInitializer drawingInitializer;
  DrawingPainter drawingPainter;

  DrawingState(
    this.state,
    this.on,
    this.color,
    this.width,
    this.drawingPoints,
    this.currentDrawingPoint,
    this.drawingInitializer,
    this.drawingPainter,
  );

  DrawingState copyWith({
    BlocState? state,
    bool? on,
    Color? color,
    double? width,
    List<DrawingPoint>? drawingPoints,
    DrawingPoint? currentDrawingPoint,
    bool cleanCurrentDrawingPoint = false,
    DrawingPainter? drawingPainter,
  }) => DrawingState(
    state ?? this.state,
    on ?? this.on,
    color ?? this.color,
    width ?? this.width,
    drawingPoints ?? this.drawingPoints,
    cleanCurrentDrawingPoint ? null : currentDrawingPoint ?? this.currentDrawingPoint,
    drawingInitializer,
    drawingPainter ?? this.drawingPainter,
  );

}

class DrawingCubit extends Cubit<DrawingState> {

  DrawingCubit(DrawingInitializer initializer)
      : super(DrawingState(BlocState.off, false, Colors.black, 2, [], null, initializer, DrawingPainter(drawingPoints: [])));

  turn({ required bool on }) {
    if (on) {
      emit(state.copyWith(on: true));
    } else {
      emit(state.copyWith(on: false,
        drawingPainter: DrawingPainter(drawingPoints: []),
        drawingPoints: [],
        cleanCurrentDrawingPoint: true,
        currentDrawingPoint: null
      ));
    }
  }

  drawStart(DragStartDetails details) async {
    final drawingPoints = List.of(state.drawingPoints);
    final currentDrawingPoint = DrawingPoint(
        color: state.color,
        width: state.width,
        id: DateTime.now().microsecondsSinceEpoch,
        offsets: [
          details.localPosition
        ]
    );
    drawingPoints.add(currentDrawingPoint);

    emit(state.copyWith(
      currentDrawingPoint: currentDrawingPoint,
      drawingPoints: drawingPoints,
      drawingPainter: DrawingPainter(drawingPoints: drawingPoints),
    ));
  }

  drawUpdate(DragUpdateDetails details) {
    if (state.currentDrawingPoint == null) return;

    final currentDrawingPoint = state.currentDrawingPoint!.copyWidth(
      offsets: state.currentDrawingPoint!.offsets
          ..add(details.localPosition)
    );
    final drawingPoints = List.of(state.drawingPoints);
    drawingPoints.last = currentDrawingPoint;

    emit(state.copyWith(
      currentDrawingPoint: currentDrawingPoint,
      drawingPoints: drawingPoints,
      drawingPainter: DrawingPainter(drawingPoints: drawingPoints),
    ));
  }

  drawEnd(_) {
    emit(state.copyWith(
      currentDrawingPoint: null,
      cleanCurrentDrawingPoint: true,
    ));
  }

  selectColor(BuildContext context) async {
    final color = await state.drawingInitializer.selectColor(context);
    if (color is Color) {
      _colorSelected(color);
    }
  }

  _colorSelected(Color color) {
    final drawingPoints = state.drawingPoints.map((point) => point..color = color).toList();
    emit(state.copyWith(
      color: color,
      drawingPoints: drawingPoints,
      drawingPainter: DrawingPainter(drawingPoints: drawingPoints)
    ));
  }

  selectWidth(BuildContext context) {
    state.drawingInitializer.selectWidth(context);
  }

  widthSelected(double width) {
    final drawingPoints = state.drawingPoints.map((point) {
      point.width = width;
      return point;
    }).toList();
    emit(state.copyWith(
      width: width,
      drawingPoints: drawingPoints,
      drawingPainter: DrawingPainter(drawingPoints: drawingPoints)
    ));
  }

}