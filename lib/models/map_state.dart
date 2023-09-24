import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/models/map_icon_point.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

enum BlocState {
  empty,
  ready
}

class MapState {

  BlocState state;
  Set<Marker> markers;
  Set<MapIconPoint> mapIconPoints;

  MapState(
    this.state,
    this.markers,
    this.mapIconPoints,
  );

  MapState copyWith({
    BlocState? state,
    Set<Marker>? markers,
    Set<MapIconPoint>? mapIconPoints
  }) {
    return MapState(
      state ?? this.state,
      markers ?? this.markers,
      mapIconPoints ?? this.mapIconPoints
    );
  }

}

class MapCubit extends Cubit<MapState> {

  MapCubit(): super(MapState(BlocState.ready, {}, {}));

  addEventMapPointAsMarker(MapIconPoint mapIconPoint, double rescaleFactor) async {
    final mapIconPoints = state.mapIconPoints;
    mapIconPoints.add(mapIconPoint);

    final marker = await MapUtil.getMarkerFromIcon(mapIconPoint.rescale(1));
    final markers = state.markers;
    markers.add(marker);
    emit(state.copyWith(
      mapIconPoints: mapIconPoints,
      markers: markers
    ));
    Log.log('Added marker with id: ${mapIconPoint.id}', source: runtimeType.toString());
  }

  cleanEventMap() {
    emit(state.copyWith(
        mapIconPoints: {},
        markers: {}
    ));
    Log.log('EventMap is cleaned');
  }

}