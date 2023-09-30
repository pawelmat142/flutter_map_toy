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
  String selectedMarkerId;

  MapState(
    this.state,
    this.markers,
    this.mapIconPoints,
    this.selectedMarkerId,
  );

  MapState copyWith({
    BlocState? state,
    Set<Marker>? markers,
    Set<MapIconPoint>? mapIconPoints,
    String? selectedMarkerId
  }) {
    Log.log('New MapState', source: runtimeType.toString());
    return MapState(
      state ?? this.state,
      markers ?? this.markers,
      mapIconPoints ?? this.mapIconPoints,
      selectedMarkerId ?? this.selectedMarkerId
    );
  }

}

class MapCubit extends Cubit<MapState> {

  MapCubit(): super(MapState(BlocState.ready, {}, {}, ''));

  addEventMapPointAsMarker(MapIconPoint mapIconPoint, double rescaleFactor) async {
    final mapIconPoints = state.mapIconPoints;
    mapIconPoints.add(mapIconPoint);

    final marker = await MapUtil.getMarkerFromIcon(mapIconPoint.rescale(rescaleFactor));
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

  resizeEventMap(double rescaleFactor) async {

    if (state.mapIconPoints.isEmpty) return;

    final futures = state.mapIconPoints.map((mapIconPoint) {
      return MapUtil.getMarkerFromIcon(mapIconPoint.rescale(rescaleFactor));
    }).toList();

    final List<Marker> markers = await Future.wait(futures);

    emit(state.copyWith(
        markers: markers.toSet(),
    ));
    Log.log('MapIconPoint markers rescaled with factor: $rescaleFactor', source: runtimeType.toString());
  }

  selectMarker(String markerId) {
    Log.log('Selecting marker with id: $markerId', source: runtimeType.toString());
    emit(state.copyWith(
      selectedMarkerId: markerId
    ));
  }

  moveMarker(LatLng point) {
    Log.log('Moving marker: ${state.selectedMarkerId} to lat: ${point.latitude}, lng: ${point.longitude}');
    emit(state.copyWith(markers: state.markers
        .map((m) => m.copyWith(positionParam: m.markerId.value == state.selectedMarkerId ? point : m.position))
        .toSet()));
  }

}