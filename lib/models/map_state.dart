import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/extensions.dart';
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
  MapType mapType;

  MapState(
    this.state,
    this.markers,
    this.mapIconPoints,
    this.selectedMarkerId,
    this.mapType,
  );

  MapState copyWith({
    BlocState? state,
    Set<Marker>? markers,
    Set<MapIconPoint>? mapIconPoints,
    String? selectedMarkerId,
    double? zoom,
    MapType? mapType,
  }) {
    Log.log('New MapState', source: runtimeType.toString());
    return MapState(
      state ?? this.state,
      markers ?? this.markers,
      mapIconPoints ?? this.mapIconPoints,
      selectedMarkerId ?? this.selectedMarkerId,
      mapType ?? this.mapType
    );
  }

  Marker? get selectedMarker => selectedMarkerId.isEmpty ? null
      : markers.firstWhere((marker) => marker.markerId.value == selectedMarkerId);

}

class MapCubit extends Cubit<MapState> {

  MapCubit(): super(MapState(BlocState.ready, {}, {}, '', MapType.normal));

  setType(MapType mapType) {
    emit(state.copyWith(mapType: mapType));
    Log.log('Selected: ${mapType.toString()}', source: state.runtimeType.toString());
  }

  addEventMapPointAsMarker(MapIconPoint mapIconPoint, double rescaleFactor) async {
    final mapIconPoints = state.mapIconPoints;
    mapIconPoints.add(mapIconPoint);

    final marker = await MapUtil.getMarkerFromIcon(mapIconPoint.rescale(rescaleFactor));
    final markers = state.markers;
    markers.add(marker);
    emit(state.copyWith(
      selectedMarkerId: '',
      mapIconPoints: mapIconPoints,
      markers: markers
    ));
    Log.log('Added marker with id: ${mapIconPoint.id}', source: runtimeType.toString());
  }

  cleanMarkers() {
    emit(state.copyWith(
      selectedMarkerId: '',
      mapIconPoints: {},
      markers: {}
    ));
    Log.log('Markers cleaned', source: state.runtimeType.toString());
  }

  resizeMarker(double rescaleFactor) async {
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

  replaceMarker(LatLng point, { required double rescaleFactor, required markerId }) async {
    Log.log('Moving marker: $markerId to lat: ${point.latitude}, lng: ${point.longitude}', source: state.runtimeType.toString());
    final points = state.mapIconPoints.map((p) {
      if (p.id == markerId) {
        p.coordinates = point.coordinates;
      }
      return p;
    });
    emit(state.copyWith(
        markers: await _markersFromPoints(points, rescaleFactor: rescaleFactor),
        mapIconPoints: points.toSet())
    );
  }

  Future<Set<Marker>> _markersFromPoints(
      Iterable<MapIconPoint> points,
      { required double rescaleFactor }
    ) async {
    final futures = points.map((mapIconPoint) {
      return MapUtil.getMarkerFromIcon(mapIconPoint.rescale(rescaleFactor));
    });
    final markers = await Future.wait(futures);
    return markers.toSet();
  }

}