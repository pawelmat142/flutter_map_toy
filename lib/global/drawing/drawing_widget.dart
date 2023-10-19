import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'drawing_painter.dart';
import 'drawing_state.dart';

class DrawingWidget extends StatelessWidget {
  const DrawingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final cubit = BlocProvider.of<DrawingCubit>(context);

    return LayoutBuilder(builder: (BuildContext ctx, BoxConstraints constraints) {
      return BlocBuilder<DrawingCubit, DrawingState>(builder: (ctx, state) {

        return state.on == false ? const SizedBox.shrink() :
          GestureDetector(
            onPanStart: cubit.drawStart,
            onPanUpdate: cubit.drawUpdate,
            onPanEnd: cubit.drawEnd,

            child: CustomPaint(
                painter: DrawingPainter(
                  drawingPoints: state.drawingPoints,
                ),
                child: SizedBox(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,
                ),
            )
          );
      });
    });
  }
}