import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_widget.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/presentation/views/map_screen/map_toolbar.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:flutter_map_toy/utils/timer_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {

  static const String id = 'map_screen';

  const MapScreen({ Key? key }) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  //TODO refactor to stateless

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
    // _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MapCubit, MapState>(builder: (ctx, state) {

      if (state.initialCameraPosition == null) {
        return const SizedBox.shrink();
      }

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
                initialCameraPosition: state.initialCameraPosition!,
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
      mapCubit.resizeMarkers();
      zoom = newZoom;
      Log.log('CameraPosition zoom changed: ${newZoom.toString()}', source: widget.runtimeType.toString());
    }
    _unselectMarkerIfOutOfView();
  }

  _unselectMarkerIfOutOfView() async {
    if (mapState.selectedMarker != null) {
      //workaround solution, also in _onMarkerTap
      //GoogleMaps API doesn't share info about selected marker id or something
      //this solution should integrate google maps marker selection with this app marker selection
      //its not perfect so marker selection may be not synchronized
      final visibleRegion = await _controller.getVisibleRegion();
      final markerVisible = visibleRegion.contains(mapState.selectedMarker!.position);
      if (!markerVisible) {
        mapCubit.selectMarker(null);
      }
    }
  }

  _onMapCreated(GoogleMapController controller) async {
    _controllerFuture.complete(controller);
    _controller = await _controllerFuture.future;
    mapCubit.initMap(_controller);
    setState((){});
    await _getInitialDiagonalDistance();
    Log.log('GoogleMap created', source: widget.runtimeType.toString());
  }

  _getInitialDiagonalDistance() {
    return Future.delayed(const Duration(milliseconds: 500), () async {
      _initialViewDiagonalDistance = await MapUtil.calcMapViewDiagonalDistance(_controller);
      if (_initialViewDiagonalDistance == 0) {
        return _getInitialDiagonalDistance();
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
        onDragEnd: (point) {
            mapCubit.replaceMarker(point, markerId: marker.markerId.value);
        },
    )).toSet();
  }

  _updateRescaleFactor() async {
    final distance = await MapUtil.calcMapViewDiagonalDistance(_controller);
    Log.log('Calculated diagonal distance: ${distance.toString()}', source: widget.runtimeType.toString());
    mapCubit.updateRescaleFactor(_initialViewDiagonalDistance / distance);
  }

}
