import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'drawing_point.dart';

enum BlocState {
  on,
  off
}

class DrawingState {

  BlocState state;
  bool on;
  Color color;
  int width;
  List<DrawingPoint> historyDrawingPoints;
  List<DrawingPoint> drawingPoints;
  DrawingPoint? currentDrawingPoint;

  DrawingState(
    this.state,
    this.on,
    this.color,
    this.width,
    this.historyDrawingPoints,
    this.drawingPoints,
    this.currentDrawingPoint,
  );

  DrawingState copyWith({
    BlocState? state,
    bool? on,
    Color? color,
    int? width,
    List<DrawingPoint>? historyDrawingPoints,
    List<DrawingPoint>? drawingPoints,
    DrawingPoint? currentDrawingPoint,
    bool cleanCurrentDrawingPoint = false,
  }) => DrawingState(
    state ?? this.state,
    on ?? this.on,
    color ?? this.color,
    width ?? this.width,
    historyDrawingPoints ?? this.historyDrawingPoints,
    drawingPoints ?? this.drawingPoints,
    cleanCurrentDrawingPoint ? null : currentDrawingPoint ?? this.currentDrawingPoint,
  );

}

class DrawingCubit extends Cubit<DrawingState> {

  DrawingCubit() : super(DrawingState(BlocState.off, false, Colors.black, 2, [], [], null));

  turn({ required bool on }) {
    emit(state.copyWith(on: on));
  }

  drawStart(DragStartDetails details) {
    final currentDrawingPoint = DrawingPoint(
        id: DateTime.now().microsecondsSinceEpoch,
        offsets: [
          details.localPosition
        ]
    );
    final drawingPoints = List.of(state.drawingPoints);
    drawingPoints.add(currentDrawingPoint);
    emit(state.copyWith(
      currentDrawingPoint: currentDrawingPoint,
      drawingPoints: drawingPoints,
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
    ));
  }

  drawEnd(_) {
    emit(state.copyWith(
      currentDrawingPoint: null,
      cleanCurrentDrawingPoint: true
    ));
  }

}