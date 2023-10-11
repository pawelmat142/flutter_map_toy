import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/models/map_icon_point.dart';
import 'package:flutter_map_toy/presentation/dialogs/icon_wizard.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/icon_util.dart';
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

  MapIconPoint? get selectedMapIconPoint => selectedMarkerId.isEmpty ? null
      : mapIconPoints.firstWhere((point) => point.id == selectedMarkerId);

}

class MapCubit extends Cubit<MapState> {

  MapCubit(): super(MapState(BlocState.ready, {}, {}, '', MapType.normal));

  setType(MapType mapType) {
    emit(state.copyWith(mapType: mapType));
    Log.log('Selected: ${mapType.toString()}', source: state.runtimeType.toString());
  }

  addMarker(BuildContext context, {
    required LatLng mapViewCenter,
    required double rescaleFactor
  }) async {

    final iconWizard = IconWizard(wizardContext: context);
    await iconWizard.start(context);

    final craft = iconWizard.craft;

    print("craft");
    print(craft);

    if (craft.incomplete) throw 'addMarker: craft.incomplete';

    final mapIconPoint = IconUtil.mapIconPointFromCraft(craft, mapViewCenter);
    state.mapIconPoints.add(mapIconPoint);

    emit(state.copyWith(
        selectedMarkerId: '',
        mapIconPoints: state.mapIconPoints,
        markers: await _markersFromPoints(state.mapIconPoints, rescaleFactor: rescaleFactor)
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
    emit(state.copyWith(
        markers: await _markersFromPoints(state.mapIconPoints, rescaleFactor: rescaleFactor),
    ));
    Log.log('MapIconPoint markers rescaled with factor: $rescaleFactor', source: runtimeType.toString());
  }

  selectMarker(Marker? marker) {
    final markerId = marker == null ? '' : marker.markerId.value;
    if (markerId == state.selectedMarkerId) return;
    Log.log('Selecting marker with id: $markerId', source: runtimeType.toString());
    emit(state.copyWith(
      selectedMarkerId: markerId
    ));
  }

  replaceMarker(LatLng point, { required double rescaleFactor, required markerId }) async {
    Log.log('Moving marker: $markerId to lat: ${point.latitude}, lng: ${point.longitude}', source: state.runtimeType.toString());
    for (var mapIconPoint in state.mapIconPoints) {
      if (mapIconPoint.id == markerId) mapIconPoint.coordinates = point.coordinates;
    }
    emit(state.copyWith(
        mapIconPoints: state.mapIconPoints,
        markers: await _markersFromPoints(state.mapIconPoints, rescaleFactor: rescaleFactor),
    ));
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

  updateMarker(BuildContext context, {
    required double rescaleFactor
  }) async {

    final mapIconPoint = state.selectedMapIconPoint;
    if (mapIconPoint == null) throw 'mapIconPoint == null ';

    final craft = IconUtil.craftFromMapIconPoint(mapIconPoint);
    await craft.startEditDialog(context);

    final points = state.mapIconPoints.map((point) {
      if (point.id == craft.id) {
        point = IconUtil.mapIconPointFromCraft(craft,
            IconUtil.pointFromCoordinates(mapIconPoint.coordinates)
        );
      }
      return point;
    });

    emit(state.copyWith(
      mapIconPoints: points.toSet(),
      markers: await _markersFromPoints(points, rescaleFactor: rescaleFactor),
    ));
  }

}