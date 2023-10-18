import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/presentation/components/drawing/drawing_widget.dart';
import 'package:flutter_map_toy/presentation/views/map_screen/map_toolbar.dart';
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

  @override
  void initState() {
    super.initState();
    mapCubit.turnDrawingMode(context: context, on: false);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(builder: (ctx, state) {

      Log.log('Build MapState, markers: ${state.markers.length}', source: mapState.runtimeType.toString());

      return WillPopScope(
        onWillPop: () async {
          mapCubit.turnDrawingMode(context: context, on: false);
          return true;
        },
        child: Scaffold(

          appBar: AppBar(title: Text(state.selectedMarkerId.toString()),),

          body: Stack(
            children: [

              GoogleMap(
                initialCameraPosition: widget.initialCameraPosition,
                mapType: state.mapType,
                markers: _prepareMarkers(state),
                onCameraMove: _onCameraMove,
                onMapCreated: _onMapCreated,
                onTap: _onMapTap,
              ),

              const DrawingWidget(),

            ],
          ),

          bottomNavigationBar: const MapToolbar()
        ),
      );
    });
  }

  _onMapTap(LatLng point) async {
    if (mapState.selectedMarkerId.isEmpty) return;
    mapCubit.selectMarker(null);
  }

  _onMarkerTap(Marker marker) {
    mapCubit.selectMarker(marker);
  }

  _onCameraMove(CameraPosition cameraPosition) {
    //workaround
    cameraMoveHandler.handle(() => _onCameraMoveEnd(cameraPosition));
  }

  _onCameraMoveEnd(CameraPosition cameraPosition) async {
    final newZoom = cameraPosition.zoom;
    if (newZoom != zoom) {
      await _updateRescaleFactor();
      mapCubit.resizeMarker(mapState.rescaleFactor);
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
      final markerVisible = mapState.visibleRegion?.contains(mapState.selectedMarker!.position) ?? false;
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
            mapCubit.replaceMarker(point, rescaleFactor: state.rescaleFactor, markerId: marker.markerId.value);
        },
    )).toSet();
  }

  _updateRescaleFactor() async {
    final distance = await MapUtil.calcMapViewDiagonalDistance(_controller);
    Log.log('Calculated diagonal distance: ${distance.toString()}', source: widget.runtimeType.toString());
    mapCubit.updateRescaleFactor(_initialViewDiagonalDistance / distance);
  }

  _updateVisibleRegion() async {
    mapCubit.updateVisibleRegion(await _controller.getVisibleRegion());
    Log.log('Visible region updated', source: widget.runtimeType.toString());
  }

}
