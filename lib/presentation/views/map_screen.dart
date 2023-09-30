import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/presentation/components/toolbar.dart';
import 'package:flutter_map_toy/presentation/styles/app_icon.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:flutter_map_toy/utils/timer_handler.dart';
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

  MapCubit get mapCubit => BlocProvider.of<MapCubit>(context);
  MapState get mapState => mapCubit.state;

  final Completer<GoogleMapController> _controllerFuture = Completer<GoogleMapController>();
  late GoogleMapController _controller;
  final cameraMoveHandler = TimerHandler(milliseconds: 50);

  double _initialViewDiagonalDistance = 0;
  double zoom = MapUtil.kZoomInitial;
  double _rescaleFactor = 1;
  late LatLngBounds _visibleRegion;

  double get rescaleFactor => _rescaleFactor;
  LatLngBounds get visibleRegion => _visibleRegion;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(builder: (ctx, state) {

      Log.log('Build MapState, markers: ${state.markers.length}', source: mapState.runtimeType.toString());

      return Scaffold(

        appBar: AppBar(title: Text(state.selectedMarkerId.toString()),),

        body: GoogleMap(
          initialCameraPosition: widget.initialCameraPosition,
          mapType: state.mapType,
          markers: _prepareMarkers(state),
          onCameraMove: _onCameraMove,
          onMapCreated: _onMapCreated,
          onTap: _onMapTap,
        ),

        bottomNavigationBar: Toolbar(toolbarItems: [
          ToolBarItem(
            label: 'add_point',
            barLabel: 'add point',
            menuLabel: 'add point',
            icon: AppIcon.addPoint,
            onTap: _onAddMarker,
          ),
          ToolBarItem(
            label: 'edit_marker',
            barLabel: 'edit',
            icon: AppIcon.editPoint,
            disabled: state.selectedMarkerId.isEmpty,
            onTap: _onEditMarker,
          ),
          ToolBarItem(
              label: 'clean_map',
              menuLabel: 'clean markers',
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
        ],),
      );
    });
  }

  _onMapTap(LatLng point) async {
    if (mapState.selectedMarkerId.isEmpty) return;
    mapCubit.selectMarker(null);
    // mapCubit.replaceMarker(point, rescaleFactor: await rescaleFactor);
  }

  _onMarkerTap(Marker marker) {
    mapCubit.selectMarker(marker);
  }

  _onAddMarker() async {
    mapCubit.addMarker(context,
      mapViewCenter: await mapViewCenter,
      rescaleFactor: rescaleFactor
    );
  }

  _onEditMarker() async {
    mapCubit.updateMarker(context, rescaleFactor: rescaleFactor);
  }

  _onClean() {
    mapCubit.cleanMarkers();
  }

  _onSave() {
    if (kDebugMode) {
      print('onsave');
    }
  }

  Future<LatLng> get mapViewCenter async {
    LatLngBounds visibleRegion = this.visibleRegion;
    LatLng centerLatLng = LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
    );
    return centerLatLng;
  }

  _onCameraMove(CameraPosition cameraPosition) {
    //workaround
    cameraMoveHandler.handle(() => _onCameraMoveEnd(cameraPosition));
  }

  _onCameraMoveEnd(CameraPosition cameraPosition) async {
    final newZoom = cameraPosition.zoom;
    if (newZoom != zoom) {
      await _updateRescaleFactor();
      mapCubit.resizeMarker(rescaleFactor);
      zoom = newZoom;
      Log.log('CameraPosition zoom changed: ${newZoom.toString()}', source: widget.runtimeType.toString());
    }
    await _updateVisibleRegion();
    _unselectMarkerIfOutOfView();
  }

  _unselectMarkerIfOutOfView() {
    if (mapState.selectedMarker != null) {
      //workaround solution, also in _onMarkerTap
      //GoogleMaps API doesn't share info about selected marker id or something
      //this solution should integrate google maps marker selection with this app marker selection
      //its not perfect so marker selection may be not synchronized
      final markerVisible = visibleRegion.contains(mapState.selectedMarker!.position);
      if (!markerVisible) {
        mapCubit.selectMarker(null);
      }
    }
  }

  _onMapCreated(GoogleMapController controller) async {
    _controllerFuture.complete(controller);
    _controller = await _controllerFuture.future;
    await _getInitialDiagonalDistance();
    await _updateVisibleRegion();
    mapCubit.selectMarker(null);
    Log.log('GoogleMap created', source: widget.runtimeType.toString());
  }

  _getInitialDiagonalDistance() {
    Future.delayed(const Duration(milliseconds: 500), () async {
      _initialViewDiagonalDistance = await MapUtil.calcMapViewDiagonalDistance(_controller);
      if (_initialViewDiagonalDistance == 0) {
        _getInitialDiagonalDistance();
      } else {
        Log.log('Initial diagonal distance: $_initialViewDiagonalDistance', source: widget.runtimeType.toString());
      }
    });
  }

  Set<Marker> _prepareMarkers(MapState state) {
    return state.markers.map((marker) => Marker(
        markerId: marker.markerId,
        position: marker.position,
        icon: marker.icon,
        onTap: () => _onMarkerTap(marker),
        draggable: true,
        onDragEnd: (point) async {
            mapCubit.replaceMarker(point, rescaleFactor: rescaleFactor, markerId: marker.markerId.value);
        },
    )).toSet();
  }

  _updateRescaleFactor() async {
    final distance = await MapUtil.calcMapViewDiagonalDistance(_controller);
    Log.log('Calculated diagonal distance: ${distance.toString()}', source: widget.runtimeType.toString());
    _rescaleFactor = _initialViewDiagonalDistance / distance;
  }

  _updateVisibleRegion() async {
    _visibleRegion = await _controller.getVisibleRegion();
    Log.log('Visible region updated', source: widget.runtimeType.toString());
  }


}
