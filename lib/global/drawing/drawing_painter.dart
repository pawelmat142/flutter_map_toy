import 'package:flutter/material.dart';

import 'drawing_line.dart';

class DrawingPainter extends CustomPainter {

  final List<DrawingLine> drawingLines;

  DrawingPainter({
    required this.drawingLines
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var drawingLine in drawingLines) {
      final paint = Paint()
          ..color = drawingLine.color
          ..isAntiAlias = true
          ..strokeWidth = drawingLine.width
          ..strokeCap = StrokeCap.round;

      for (var i = 0; i < drawingLine.offsets.length; i++) {
        var notLastOffset = i != drawingLine.offsets.length-1;
        
        if (notLastOffset) {
          final current = drawingLine.offsets[i];
          final next = drawingLine.offsets[i+1];
          canvas.drawLine(current, next, paint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

}