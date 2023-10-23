import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


import 'drawing_state.dart';

class DrawingWidget extends StatelessWidget {
  const DrawingWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final cubit = BlocProvider.of<DrawingCubit>(context);

    return LayoutBuilder(
        builder: (BuildContext _, BoxConstraints constraints) {
          if (kDebugMode) {
            print('drawing widget width: ${constraints.maxWidth}');
            print('drawing widget height: ${constraints.maxHeight}');
          }

          final width = constraints.maxWidth;
          final height = constraints.maxHeight;

          return BlocBuilder<DrawingCubit, DrawingState>(builder: (ctx, state) {
            return state.on == false ? const SizedBox.shrink() :
            GestureDetector(
                onPanStart: cubit.drawStart,
                onPanUpdate: cubit.drawUpdate,
                onPanEnd: cubit.drawEnd,

                child: CustomPaint(
                  painter: state.drawingPainter,
                  child: SizedBox(
                    width: width,
                    height: height,
                  ),
                )
            );
          });
        });
  }

}