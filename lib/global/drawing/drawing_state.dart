import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'drawing_initializer.dart';
import 'drawing_painter.dart';
import 'drawing_line.dart';

enum BlocState {
  on,
  off
}

class DrawingState {

  BlocState state;
  bool on;
  Color color;
  double width;
  List<DrawingLine> drawingLines;
  DrawingLine? currentDrawingLine;
  DrawingInitializer drawingInitializer;
  DrawingPainter drawingPainter;

  DrawingState(
    this.state,
    this.on,
    this.color,
    this.width,
    this.drawingLines,
    this.currentDrawingLine,
    this.drawingInitializer,
    this.drawingPainter,
  );

  DrawingState copyWith({
    BlocState? state,
    bool? on,
    Color? color,
    double? width,
    List<DrawingLine>? drawingLines,
    DrawingLine? currentDrawingLine,
    bool cleanCurrentDrawingLine = false,
    DrawingPainter? drawingPainter,
  }) => DrawingState(
    state ?? this.state,
    on ?? this.on,
    color ?? this.color,
    width ?? this.width,
    drawingLines ?? this.drawingLines,
    cleanCurrentDrawingLine ? null : currentDrawingLine ?? this.currentDrawingLine,
    drawingInitializer,
    drawingPainter ?? this.drawingPainter,
  );

}

class DrawingCubit extends Cubit<DrawingState> {

  DrawingCubit(DrawingInitializer initializer)
      : super(DrawingState(BlocState.off, false, Colors.black, 2, [], null, initializer, DrawingPainter(drawingLines: [])));

  turn({ required bool on }) {
    if (on) {
      emit(state.copyWith(on: true));
    } else {
      emit(state.copyWith(on: false,
        drawingPainter: DrawingPainter(drawingLines: []),
        drawingLines: [],
        cleanCurrentDrawingLine: true,
        currentDrawingLine: null
      ));
    }
  }

  drawStart(DragStartDetails details) async {
    final drawingLines = List.of(state.drawingLines);
    final currentDrawingLine = DrawingLine(
        color: state.color,
        width: state.width,
        id: DateTime.now().microsecondsSinceEpoch,
        offsets: [
          details.localPosition
        ]
    );
    drawingLines.add(currentDrawingLine);

    emit(state.copyWith(
      currentDrawingLine: currentDrawingLine,
      drawingLines: drawingLines,
      drawingPainter: DrawingPainter(drawingLines: drawingLines),
    ));
  }

  drawUpdate(DragUpdateDetails details) {
    if (state.currentDrawingLine == null) return;

    final currentDrawingLine = state.currentDrawingLine!.currentDrawingLine(
      offsets: state.currentDrawingLine!.offsets
          ..add(details.localPosition)
    );
    final drawingLines = List.of(state.drawingLines);
    drawingLines.last = currentDrawingLine;

    emit(state.copyWith(
      currentDrawingLine: currentDrawingLine,
      drawingLines: drawingLines,
      drawingPainter: DrawingPainter(drawingLines: drawingLines),
    ));
  }

  drawEnd(_) {
    emit(state.copyWith(
      currentDrawingLine: null,
      cleanCurrentDrawingLine: true,
    ));
  }

  selectColor(BuildContext context) async {
    final color = await state.drawingInitializer.selectColor(context);
    if (color is Color) {
      _colorSelected(color);
    }
  }

  _colorSelected(Color color) {
    final drawingLines = state.drawingLines.map((point) => point..color = color).toList();
    emit(state.copyWith(
      color: color,
      drawingLines: drawingLines,
      drawingPainter: DrawingPainter(drawingLines: drawingLines)
    ));
  }

  selectWidth(BuildContext context) {
    state.drawingInitializer.selectWidth(context);
  }

  widthSelected(double width) {
    final drawingLines = state.drawingLines.map((point) {
      point.width = width;
      return point;
    }).toList();
    emit(state.copyWith(
      width: width,
      drawingLines: drawingLines,
      drawingPainter: DrawingPainter(drawingLines: drawingLines)
    ));
  }

}