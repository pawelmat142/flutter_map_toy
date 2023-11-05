import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_initializer.dart';
import 'package:flutter_map_toy/global/drawing/drawing_state.dart';
import 'package:flutter_map_toy/global/static.dart';
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

      final colors = AppColor.mapFlutterIconColors;
      const icon = AppIcon.drawLine;
      final length = colors.length;
      const itemsPerRow = 4;
      final tileSize = Static.getModalTileSize(context, itemsPerRow: itemsPerRow);

      List<Widget> columns = [ const SizedBox(height: AppStyle.defaultPaddingVal) ];

      for (var from = 0; from <= length; from+=itemsPerRow) {
        int to = from + itemsPerRow;
        if (to > length) {
          to = length;
        }
        columns.add(Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: colors.getRange(from, to)
                .map((color) => GestureDetector(
              onTap: () => Navigator.pop(context, color),
              child: Icon(icon,
                  color: color,
                  size: tileSize
              ),
            )).toList()
        ));
      }
      return AppModal(showBack: false, lineOnTop: false,
        children: columns);
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