import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

      return Toolbar(toolbarItems: [
        ToolBarItem(
          label: 'add_point',
          barLabel: 'add point',
          menuLabel: 'add point',
          icon: AppIcon.addPoint,
          onTap: () => mapCubit.addMarker(context,
              mapViewCenter: state.mapViewCenter,
              rescaleFactor: state.rescaleFactor
          ),
        ),
        ToolBarItem(
          label: 'edit_marker',
          barLabel: 'edit',
          icon: AppIcon.editPoint,
          disabled: mapCubit.state.selectedMarkerId.isEmpty,
          onTap: () => mapCubit.updateMarker(context, rescaleFactor: state.rescaleFactor),
        ),
        ToolBarItem(
            label: 'clean_map',
            menuLabel: 'clean markers',
            icon: AppIcon.cleanPoint,
            onTap: mapCubit.cleanMarkers
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
            onTap: (){}
        ),
        ToolBarItem(
            label: 'map_type_normal',
            menuLabel: 'Normal',
            icon: AppIcon.mapTypeNormal,
            onTap: () => mapCubit.setType(MapType.normal)
        ),
        ToolBarItem(
            label: 'map_type_terrain',
            menuLabel: 'Terrain',
            icon: AppIcon.mapTypeTerrain,
            onTap: () => mapCubit.setType(MapType.terrain)
        ),
        ToolBarItem(
            label: 'map_type_satellite',
            menuLabel: 'Satellite',
            icon: AppIcon.mapTypeSatellite,
            onTap: () => mapCubit.setType(MapType.satellite)
        ),
      ],);
    });
  }

}
