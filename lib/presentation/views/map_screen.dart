import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/models/map_icon_point.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/presentation/components/toolbar.dart';
import 'package:flutter_map_toy/presentation/dialogs/icon_craft.dart';
import 'package:flutter_map_toy/presentation/styles/app_icon.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  static const String id = 'map_screen';

  static push(BuildContext context, CameraPosition initialCameraPosition) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) =>
        MapScreen(initialCameraPosition: initialCameraPosition)));
  }

  final CameraPosition initialCameraPosition;

  const MapScreen({
    required this.initialCameraPosition,
    Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  final Completer<GoogleMapController> _controllerFuture = Completer<GoogleMapController>();
  late GoogleMapController _controller;

  MapCubit get mapCubit => BlocProvider.of<MapCubit>(context);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('Map'),),

      body: BlocBuilder<MapCubit, MapState>(builder: (ctx, state) {
        return GoogleMap(
          initialCameraPosition: widget.initialCameraPosition,
          mapType: MapType.normal,
          markers: state.markers,
          onMapCreated: _onMapCreated
        );
      }),

      bottomNavigationBar: Toolbar(toolbarItems: [
        ToolBarItem(
          label: 'add_point',
          barLabel: 'add point',
          menuLabel: 'add point',
          icon: AppIcon.addPoint,
          onTap: _onAddPoint,
        ),
        ToolBarItem(
            label: 'clean_map',
            barLabel: 'clean',
            menuLabel: 'clean',
            icon: AppIcon.cleanPoint,
            onTap: _onClean
        ),
        ToolBarItem(
            label: 'save_map',
            barLabel: 'save',
            menuLabel: 'save',
            icon: AppIcon.save,
            onTap: _onSave
        ),
        ToolBarItem(
            label: Toolbar.menuLabel,
            barLabel: 'menu',
            icon: AppIcon.menu,
            onTap: (){}
        ),
      ],),
    );

  }

  _onAddPoint() async {
    final craft = IconCraft();
    await craft.create(context);

    if (craft.complete) {
      final mapIconPoint = MapIconPoint.create(craft, await mapViewCenter);
      await mapCubit.addEventMapPointAsMarker(mapIconPoint, 1);
    }
  }

  _onClean() {
    if (kDebugMode) {
      print('onclean');
    }
  }

  _onSave() {
    if (kDebugMode) {
      print('onsave');
    }
  }

  Future<LatLng> get mapViewCenter async {
    LatLngBounds visibleRegion = await _controller.getVisibleRegion();
    LatLng centerLatLng = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
    );
    return centerLatLng;
  }

  _onMapCreated(GoogleMapController controller) async {
    _controllerFuture.complete(controller);
    _controller = await _controllerFuture.future;
    Log.log('GoogleMap created', source: widget.runtimeType.toString());
  }

}
