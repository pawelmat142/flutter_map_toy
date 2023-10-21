import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_state.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/presentation/components/toolbar.dart';
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
    return [
      ToolBarItem(
        label: 'cancel',
        barLabel: 'cancel',
        icon: AppIcon.drawCancel,
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
    ];
  }

  List<ToolBarItem> mapToolbar(BuildContext context, MapCubit cubit, MapState state) {
    return [
      state.selectedMarkerId.isEmpty ?
      ToolBarItem(
        label: 'add_point',
        barLabel: 'add point',
        menuLabel: 'add point',
        icon: AppIcon.addPoint,
        onTap: () =>
            cubit.addMarker(context,
                mapViewCenter: state.mapViewCenter,
                rescaleFactor: state.rescaleFactor
            ),
      ) : ToolBarItem(
        label: 'edit_marker',
        barLabel: 'edit',
        icon: AppIcon.editPoint,
        disabled: cubit.state.selectedMarkerId.isEmpty,
        onTap: () =>
            cubit.updateMarker(context, rescaleFactor: state.rescaleFactor),
      ),

      ToolBarItem(
          label: 'draw_line',
          barLabel: 'draw line',
          icon: AppIcon.drawLine,
          onTap: () {
            cubit.turnDrawingMode(
                context: context, on: state.drawingMode == false);
          }
      ),
      ToolBarItem(
          label: 'clean_map',
          menuLabel: 'clean markers',
          icon: AppIcon.cleanPoint,
          onTap: cubit.cleanMarkers
      ),
      ToolBarItem(
          label: 'save_map',
          barLabel: 'save',
          menuLabel: 'save',
          icon: AppIcon.save,
          onTap: () {
            if (kDebugMode) {
              print('on save');
            }
          }
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