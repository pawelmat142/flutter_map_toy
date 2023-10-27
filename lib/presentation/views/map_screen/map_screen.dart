import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_widget.dart';
import 'package:flutter_map_toy/models/map_cubit.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/presentation/views/map_screen/map_toolbar.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/timer_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {

  static const String id = 'map_screen';
  static final cameraMoveEndHandler = TimerHandler(milliseconds: 50);

  const MapScreen({ Key? key }) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final cubit = BlocProvider.of<MapCubit>(context);

    return BlocBuilder<MapCubit, MapState>(builder: (ctx, state) {

      if (state.initialCameraPosition == null) {
        return const SizedBox.shrink();
      }
      Log.log('Build MapState, markers: ${state.markers.length}', source: state.runtimeType.toString());
      Log.log('Build MapState, markerId: ${state.selectedMarkerId}', source: state.runtimeType.toString());

      return WillPopScope(
        onWillPop: () async {
          cubit.turnDrawingMode(context: context, on: false);
          return true;
        },
        child: Scaffold(

          //TODO title
          appBar: AppBar(title: Text(state.selectedMarkerId.toString()),),

          body: Stack(
            children: [

              GoogleMap(
                initialCameraPosition: state.initialCameraPosition!,
                mapType: state.mapType,
                markers: _prepareMarkers(state, cubit, context),
                onCameraMove: (position) => _onCameraMove(position, cubit, state, context),
                onMapCreated: (controller) => cubit.initMap(controller),
                onTap: (point) => _onMapTap(point, cubit, state, context),
              ),

              const DrawingWidget(),

            ],
          ),

          bottomNavigationBar: const MapToolbar()
        ),
      );
    });
  }

  _onMapTap(LatLng point, MapCubit mapCubit, MapState state, BuildContext context) async {
    if (state.selectedMarkerId.isEmpty) return;
    mapCubit.selectMarker(null, context);
  }

  _onCameraMove(CameraPosition cameraPosition, MapCubit cubit, MapState state, BuildContext context) {
    //workaround
    cameraMoveEndHandler.handle(() {
      //onCameraMoveEnd:
      cubit.updateRescaleFactor().then((_) {
        _unselectMarkerIfOutOfView(cubit, state, context);
      });
    });
  }

  _unselectMarkerIfOutOfView(MapCubit cubit, MapState state, BuildContext context) {
    if (state.selectedMarker != null) {
      //workaround solution, also in _onMarkerTap
      //GoogleMaps API doesn't share info about selected marker id or something
      //this solution should integrate google maps marker selection with this app marker selection
      //its not perfect so marker selection may be not synchronized
      state.mapController?.getVisibleRegion().then((visibleRegion) {
        final markerVisible = visibleRegion.contains(state.selectedMarker!.position);
        if (!markerVisible) {
          cubit.selectMarker(null, context);
        }
      });
    }
  }

  Set<Marker> _prepareMarkers(MapState state, MapCubit cubit, BuildContext context) {
    return state.markers.map((marker) => Marker(
        markerId: marker.markerId,
        position: marker.position,
        icon: marker.icon,
        onTap: () => _onMarkerTap(marker, cubit, context),
        draggable: true,
        onDragEnd: (point) {
          cubit.replaceMarker(point, markerId: marker.markerId.value);
        },
    )).toSet();
  }

  _onMarkerTap(Marker marker, MapCubit mapCubit, BuildContext context) {
    mapCubit.selectMarker(marker, context);
  }
}
