import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/static.dart';
import 'package:flutter_map_toy/presentation/components/icon_tile.dart';
import 'package:flutter_map_toy/presentation/dialogs/app_modal.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_icon.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';

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

  DrawingState(
    this.state,
    this.on,
    this.color,
    this.width,
    this.drawingPoints,
    this.currentDrawingPoint,
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
  );

}

class DrawingCubit extends Cubit<DrawingState> {

  DrawingCubit()
      : super(DrawingState(BlocState.off, false, Colors.black, 2, [], null));

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

  selectColor(BuildContext context) {
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) {
      return AppModal(showBack: false, lineOnTop: false,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: AppStyle.defaultPaddingVal*2),
          child: Wrap(
            spacing: AppStyle.wrapSpacing,
            runSpacing: AppStyle.wrapSpacing,
            children: AppColor.mapFlutterIconColors.asMap()
                .map((index, color) => MapEntry(index, IconTile(
              icon: AppIcon.defaultIcon,
              onPressed: () {
                _colorSelected(color);
                Navigator.pop(context);
              },
              size: Static.getModalTileSize(context),
              color: color,
            ))).values.toList()
          ),
        )
      ],);
    });
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
    showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) {
      return AppModal(showBack: false, lineOnTop: false,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppStyle.defaultPaddingVal*2),
            child: BlocBuilder<DrawingCubit, DrawingState>(builder: (ctx, state) {
              return Slider(
                value: state.width,
                min: 1,
                max: 20,
                onChanged: (value) {
                  emit(state.copyWith(
                    width: value,
                    drawingPoints: state.drawingPoints.map((point) {
                      point.width = value;
                      return point;
                    }).toList()
                  ));
                },
              );
            }),
          )
        ],);
    });
  }

}