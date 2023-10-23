import 'package:flutter/material.dart';

class DrawingLine {

  int id;
  List<Offset> offsets;
  Color color;
  double width;

  DrawingLine({
    this.id = -1,
    this.offsets = const [],
    this.color = Colors.black,
    this.width = 2
  });

  DrawingLine currentDrawingLine({List<Offset>? offsets}) {
    return DrawingLine(
      id: id,
      color: color,
      width: width,
      offsets: offsets ?? this.offsets
    );
  }
}