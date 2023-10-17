import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'drawing_painter.dart';
import 'drawing_state.dart';

class DrawingWidget extends StatelessWidget {
  const DrawingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final cubit = BlocProvider.of<DrawingCubit>(context);

    return GestureDetector(
      onPanStart: cubit.drawStart,
      onPanUpdate: cubit.drawUpdate,
      onPanEnd: cubit.drawEnd,

      child: BlocBuilder<DrawingCubit, DrawingState>(builder: (ctx, state) {
        return CustomPaint(
          painter: DrawingPainter(
            drawingPoints: state.drawingPoints
          ),
          child: SizedBox(
            //TODO get parent size
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
          ),
        );
      }),
    );
  }
}