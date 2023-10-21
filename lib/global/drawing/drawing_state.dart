import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'drawing_initializer.dart';
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

  DrawingState(
    this.state,
    this.on,
    this.color,
    this.width,
    this.drawingPoints,
    this.currentDrawingPoint,
    this.drawingInitializer,
  );

  DrawingState copyWith({
    BlocState? state,
    bool? on,
    Color? color,
    double? width,
    List<DrawingPoint>? drawingPoints,
    DrawingPoint? currentDrawingPoint,
    bool cleanCurrentDrawingPoint = false,
  }) => DrawingState(
    state ?? this.state,
    on ?? this.on,
    color ?? this.color,
    width ?? this.width,
    drawingPoints ?? this.drawingPoints,
    cleanCurrentDrawingPoint ? null : currentDrawingPoint ?? this.currentDrawingPoint,
    drawingInitializer,
  );

}

class DrawingCubit extends Cubit<DrawingState> {

  DrawingCubit(DrawingInitializer initializer)
      : super(DrawingState(BlocState.off, false, Colors.black, 2, [], null, initializer));

  turn({ required bool on }) {
    emit(state.copyWith(on: on));
  }

  drawStart(DragStartDetails details) {
    final currentDrawingPoint = DrawingPoint(
        color: state.color,
        width: state.width,
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

  selectColor(BuildContext context) async {
    final color = await state.drawingInitializer.selectColor(context);
    if (color is Color) {
      _colorSelected(color);
    }
  }

  _colorSelected(Color color) {
    emit(state.copyWith(
      color: color,
      drawingPoints: state.drawingPoints.map((point) {
        point.color = color;
        return point;
      }).toList()
    ));
  }

  selectWidth(BuildContext context) {
    state.drawingInitializer.selectWidth(context);
  }

  widthSelected(double width) {
    emit(state.copyWith(
        width: width,
        drawingPoints: state.drawingPoints.map((point) {
          point.width = width;
          return point;
        }).toList()
    ));
  }

}