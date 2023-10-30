import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_state.dart';
import 'package:flutter_map_toy/models/map_cubit.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/presentation/components/toolbar.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_icon.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapToolbar extends StatelessWidget {

  const MapToolbar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mapCubit = BlocProvider.of<MapCubit>(context);

    return BlocBuilder<MapCubit, MapState>(builder: (ctx, state) {
      return Toolbar(toolbarItems: state.drawingMode
          ? drawingToolbar(context, mapCubit, state)
          : mapToolbar(context, mapCubit, state)
      );
    });
  }

  List<ToolBarItem> drawingToolbar(BuildContext context, MapCubit cubit, MapState state) {
    final drawingCubit = BlocProvider.of<DrawingCubit>(context);
    final drawingState = drawingCubit.state;
    return [
      ToolBarItem(
        label: 'confirm',
        barLabel: 'confirm',
        icon: AppIcon.confirm,
        onTap: () {
          cubit.addDrawingAsMarker(
            context: context,
            drawingLines: drawingCubit.state.drawingLines,
            drawingModelId: drawingState.drawingModelId.isEmpty ? null : drawingState.drawingModelId
          );
        }
      ),
      ToolBarItem(
        label: 'cancel',
        barLabel: 'cancel',
        icon: AppIcon.cancel,
        onTap: () => cubit.turnDrawingMode(context: context, on: false)
      ),
      ToolBarItem(
          label: 'color',
          barLabel: 'color',
          icon: AppIcon.drawColor,
          onTap: () => drawingCubit.selectColor(context)
      ),
      ToolBarItem(
          label: 'width',
          barLabel: 'width',
          icon: AppIcon.drawWidth,
          onTap: () => drawingCubit.selectWidth(context)
      ),
      ToolBarItem(
        label: Toolbar.menuLabel,
        barLabel: 'menu',
        icon: AppIcon.menu,
        onTap: () {}
      ),
      ToolBarItem(
          label: 'clean_map',
          menuLabel: 'clean markers',
          icon: AppIcon.cleanPoint,
          onTap: cubit.cleanMarkers
      ),
    ];
  }

  List<ToolBarItem> mapToolbar(BuildContext context, MapCubit cubit, MapState state) {
    return [
      !state.isAnyIconSelected ?
      ToolBarItem(
        label: 'add_point',
        barLabel: 'add point',
        menuLabel: 'add point',
        icon: AppIcon.addPoint,
        onTap: () => cubit.addIconMarker(context),
      ) : ToolBarItem(
        label: 'edit_marker',
        barLabel: 'edit',
        icon: AppIcon.editPoint,
        color: AppColor.secondary,
        disabled: cubit.state.selectedMarkerId.isEmpty,
        onTap: () => cubit.updateIconMarker(context),
      ),

      state.isAnyDrawingSelected ?
      ToolBarItem(
          label: 'edit_line',
          barLabel: 'edit line',
          icon: AppIcon.editLine,
          color: AppColor.secondary,
          onTap: () {
            cubit.editDrawing(context);
          }
      ) : ToolBarItem(
          label: 'draw_line',
          barLabel: 'draw line',
          icon: AppIcon.drawLine,
          onTap: () {
            cubit.turnDrawingMode(
                context: context, on: !state.drawingMode);
          }
      ),
      ToolBarItem(
          label: 'clean_map',
          menuLabel: 'clean markers',
          icon: AppIcon.cleanPoint,
          onTap: cubit.cleanMarkers
      ),
      ToolBarItem(
          label: 'remove',
          barLabel: 'remove',
          icon: AppIcon.delete,
          disabled: !state.isAnyMarkerSelected,
          onTap: () {
            showDialog<bool?>(context: context, builder: (ctx) => AlertDialog(
              title: const Text('Are you sure?'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel')
                ),
                TextButton(
                  child: const Text('OK'),
                  onPressed: () => Navigator.pop(context, true),
                )
              ],
            )).then(cubit.removeMarker);
          }
      ),
      ToolBarItem(
          label: 'save_map',
          barLabel: 'save',
          menuLabel: 'save',
          icon: AppIcon.save,
          onTap: () => cubit.onSaveMapModel(context),
      ),
      ToolBarItem(
          label: Toolbar.menuLabel,
          barLabel: 'menu',
          icon: AppIcon.menu,
          onTap: () {}
      ),
      ToolBarItem(
          label: 'map_type_normal',
          menuLabel: 'Normal',
          icon: AppIcon.mapTypeNormal,
          onTap: () => cubit.setType(MapType.normal)
      ),
      ToolBarItem(
          label: 'map_type_terrain',
          menuLabel: 'Terrain',
          icon: AppIcon.mapTypeTerrain,
          onTap: () => cubit.setType(MapType.terrain)
      ),
      ToolBarItem(
          label: 'map_type_satellite',
          menuLabel: 'Satellite',
          icon: AppIcon.mapTypeSatellite,
          onTap: () => cubit.setType(MapType.satellite)
      ),
    ];
  }

}