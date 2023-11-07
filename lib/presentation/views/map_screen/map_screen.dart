import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_widget.dart';
import 'package:flutter_map_toy/models/map_cubit.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/presentation/dialogs/spinner.dart';
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

    return BlocBuilder<MapCubit, MapState>(
      builder: (ctx, state) {
      Log.log('Build MapState: ${state.state.toString()}', source: state.runtimeType.toString());

      if (state.state != BlocState.ready) {
        if (state.initialCameraPosition == null) {
          cubit.setInitialPosition();
        }
        return const Spinner();
      }

      Log.log('Markers: ${state.markers.length}', source: state.runtimeType.toString());
      Log.log('MarkerId: ${state.selectedMarkerId}', source: state.runtimeType.toString());

      return WillPopScope(
        onWillPop: () async {
          cubit.dispose(context);
          return true;
        },
        child: Scaffold(

          body: Stack(
            children: [
              GoogleMap(
                initialCameraPosition: state.initialCameraPosition!,
                mapType: state.mapType,
                markers: state.markers,
                onCameraMove: (position) => cubit.updateCameraPosition(position, context),
                onMapCreated: cubit.initMap,
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

}
