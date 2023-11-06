import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_state.dart';
import 'package:flutter_map_toy/models/map_cubit.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/models/marker_info.dart';
import 'package:flutter_map_toy/presentation/components/toolbar.dart';
import 'package:flutter_map_toy/presentation/dialogs/popups/app_popup.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_icon.dart';
import 'package:flutter_map_toy/presentation/views/home_screen.dart';
import 'package:flutter_map_toy/presentation/views/location_search/location_search_screen.dart';
import 'package:flutter_map_toy/presentation/views/saved_maps_screen.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
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
        color: AppColor.blue,
        onTap: () async {
          cubit.addDrawingAsMarker(
            context: context,
            drawingLines: drawingCubit.state.drawingLines,
            drawingModelId: drawingState.drawingModelId.isEmpty ? null : drawingState.drawingModelId,
          );
        }
      ),
      ToolBarItem(
        label: 'cancel',
        barLabel: 'cancel',
        color: AppColor.red,
        icon: AppIcon.cancel,
        onTap: () => cubit.turnDrawingMode(context: context, on: false)
      ),
      ToolBarItem(
          label: 'color',
          barLabel: 'color',
          icon: AppIcon.drawColor,
          color: drawingState.editMode ? AppColor.secondary : Colors.white,
          onTap: () => drawingCubit.selectColor(context)
      ),
      ToolBarItem(
          label: 'width',
          barLabel: 'width',
          icon: AppIcon.drawWidth,
          color: drawingState.editMode ? AppColor.secondary : Colors.white,
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
          menuLabel: 'clean all markers',
          icon: AppIcon.cleanPoint,
          onTap: () => cubit.cleanMarkers(context)
      ),
    ];
  }

  List<ToolBarItem> mapToolbar(BuildContext context, MapCubit cubit, MapState state) {
    return [

      state.isAnyIconSelected ? ToolBarItem(
        label: 'edit_icon',
        barLabel: 'edit',
        icon: AppIcon.editPoint,
        color: AppColor.secondary,
        disabled: cubit.state.selectedMarkerId.isEmpty,
        onTap: () => cubit.updateIconMarker(context),
      ) : state.isAnyDrawingSelected ? MarkerInfoToolbarItem(context, cubit)
        : ToolBarItem(
        label: 'add_point',
        barLabel: 'add point',
        menuLabel: 'add point',
        color: AppColor.secondary,
        icon: AppIcon.addPoint,
        onTap: () => cubit.addIconMarker(context),
      ),

      state.isAnyIconSelected ? MarkerInfoToolbarItem(context, cubit)
        : state.isAnyDrawingSelected ? ToolBarItem(
          label: 'edit_line',
          barLabel: 'edit line',
          icon: AppIcon.editLine,
          color: AppColor.secondary,
          onTap: () {
            cubit.editDrawing(context);
          }
      ) :  ToolBarItem(
          label: 'draw_line',
          barLabel: 'draw line',
          color: AppColor.secondary,
          icon: AppIcon.drawLine,
          onTap: () => cubit.turnOnDrawingMode(context: context),
          ),
      ToolBarItem(
          label: 'clean_map',
          menuLabel: 'clean markers',
          icon: AppIcon.cleanPoint,
          onTap: () => cubit.cleanMarkers(context)
      ),
      ToolBarItem(
          label: 'remove',
          barLabel: 'remove',
          icon: AppIcon.delete,
          disabled: !state.isAnyMarkerSelected,
          color: AppColor.red,
          onTap: () {
            AppPopup(context)
              .title('Are you sure?')
              .onOk(() => cubit.removeMarker(true, context));
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
      if (state.mapModelId.isNotEmpty) ToolBarItem(
          label: 'find_map',
          menuLabel: 'Find map',
          icon: AppIcon.search,
          onTap: () => MapUtil.animateCameraToMapCenter(state)
      ),
      ToolBarItem(
          label: 'saved_maps',
          menuLabel: 'Saved maps',
          icon: AppIcon.savedMaps,
          onTap: () => Navigator.pushNamedAndRemoveUntil(
            context,
            SavedMapsScreen.id,
            ModalRoute.withName(HomeScreen.id)
          ),
      ),

      ToolBarItem(
          label: 'search',
          icon: AppIcon.search,
          menuLabel: 'Find location',
          onTap: () => Navigator.pushNamed(context, LocationSearchScreen.id),
      )
    ];
  }

}



class MarkerInfoToolbarItem extends ToolBarItem {
  MarkerInfoToolbarItem(BuildContext context, MapCubit cubit) : super(
      label: 'set_info',
      barLabel: 'Set info',
      icon: AppIcon.nameMarker,
      color: AppColor.secondary,
      onTap: () async {
        final selectedMarker = cubit.state.selectedMarker;
        cubit.state.unselectMarker();
        if (selectedMarker is Marker) {
          cubit.state.mapController?.hideMarkerInfoWindow(selectedMarker.markerId);
          final markerInfo = await MarkerInfo.dialog(context, selectedMarker);
          if (markerInfo is MarkerInfo) {
            // ignore: use_build_context_synchronously
            cubit.setMarkerInfo(context, markerInfo);
          }
        }
      }
  );
}
