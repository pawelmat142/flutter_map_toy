import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_initializer.dart';
import 'package:flutter_map_toy/global/drawing/drawing_state.dart';
import 'package:flutter_map_toy/global/static.dart';
import 'package:flutter_map_toy/presentation/components/icon_tile.dart';
import 'package:flutter_map_toy/presentation/dialogs/app_modal.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_icon.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';

class AppDrawing extends DrawingInitializer {

  @override
  Color get defaultColor => AppColor.blue;

  @override
  Future<Color?> selectColor(BuildContext context) {
    return showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) {
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
                    Navigator.pop(context, color);
                  },
                  size: Static.getModalTileSize(context),
                  color: color,
                ))).values.toList()
            ),
          )
        ],);
    });
  }

  @override
  Future<double?> selectWidth(BuildContext context) {
    final cubit = BlocProvider.of<DrawingCubit>(context);
    return showModalBottomSheet(context: context, backgroundColor: Colors.transparent, builder: (ctx) {
      return AppModal(showBack: false, lineOnTop: false,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: AppStyle.defaultPaddingVal*2),
            child: BlocBuilder<DrawingCubit, DrawingState>(builder: (ctx, state) {
              return Slider(
                value: state.width,
                min: 1,
                max: 20,
                onChanged: cubit.widthSelected,
              );
            }),
          )
        ],);
    });
  }

}