import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_widget.dart';
import 'package:flutter_map_toy/models/map_cubit.dart';
import 'package:flutter_map_toy/models/map_model.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/presentation/views/map_screen/map_toolbar.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/timer_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatelessWidget {

  static const String id = 'map_screen';
  static final cameraMoveEndHandler = TimerHandler(milliseconds: 50);

  const MapScreen({ Key? key }) : super(key: key);

  String _getAppBarTitle(MapState state) {
    String? result;
    if (state.mapModelId.isNotEmpty) {
      result = MapModel.getById(state.mapModelId)?.name;
    }
    return result ?? 'New map';
  }

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

          appBar: AppBar(title: Text(_getAppBarTitle(state)),),

          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: state.initialCameraPosition!,
                mapType: state.mapType,
                markers: _prepareMarkers(state, cubit, context),
                onCameraMove: (position) => cubit.updateCameraPosition(position, context),
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
    mapCubit.selectMarker('', context);
  }

  Set<Marker> _prepareMarkers(MapState state, MapCubit cubit, BuildContext context) {
    return state.markers;
  }

}
