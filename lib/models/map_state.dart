import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_point.dart';
import 'package:flutter_map_toy/global/drawing/drawing_state.dart';
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
  double rescaleFactor;
  bool drawingMode;
  GoogleMapController? mapController;

  MapState(
    this.state,
    this.markers,
    this.mapIconPoints,
    this.selectedMarkerId,
    this.mapType,
    this.rescaleFactor,
    this.drawingMode,
    this.mapController,
  );

  MapState copyWith({
    BlocState? state,
    Set<Marker>? markers,
    Set<MapIconPoint>? mapIconPoints,
    String? selectedMarkerId,
    double? zoom,
    MapType? mapType,
    double? rescaleFactor,
    bool? drawingMode,
    GoogleMapController? mapController,
  }) {
    Log.log('New MapState', source: runtimeType.toString());
    return MapState(
      state ?? this.state,
      markers ?? this.markers,
      mapIconPoints ?? this.mapIconPoints,
      selectedMarkerId ?? this.selectedMarkerId,
      mapType ?? this.mapType,
      rescaleFactor ?? this.rescaleFactor,
      drawingMode ?? this.drawingMode,
      mapController ?? this.mapController,
    );
  }

  Marker? get selectedMarker => selectedMarkerId.isEmpty ? null
      : markers.firstWhere((marker) => marker.markerId.value == selectedMarkerId);

  MapIconPoint? get selectedMapIconPoint => selectedMarkerId.isEmpty ? null
      : mapIconPoints.firstWhere((point) => point.id == selectedMarkerId);

  Future<LatLng> get mapViewCenter async {
    final visibleRegion = await mapController!.getVisibleRegion();
    return LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
    );
  }

}

class MapCubit extends Cubit<MapState> {

  MapCubit(): super(MapState(BlocState.empty, {}, {}, '', MapType.normal, 1, false, null));

  initMap(GoogleMapController googleMapController) {
    emit(state.copyWith(
      state: BlocState.ready,
      mapController: googleMapController,
      selectedMarkerId: '',
    ));
  }

  setType(MapType mapType) {
    emit(state.copyWith(mapType: mapType));
    Log.log('Selected: ${mapType.toString()}', source: state.runtimeType.toString());
  }

  addMarker(BuildContext context, {
    required LatLng mapViewCenter,
  }) {
    final wizard = IconWizard();
    wizard.run(context);
    wizard.onComplete = (craft) async {
      if (craft.incomplete) return;
      final mapIconPoint = IconUtil.mapIconPointFromCraft(craft, mapViewCenter);
      state.mapIconPoints.add(mapIconPoint);

      emit(state.copyWith(
          selectedMarkerId: '',
          mapIconPoints: state.mapIconPoints,
          markers: await _markersFromPoints(state.mapIconPoints, rescaleFactor: state.rescaleFactor)
      ));
      Log.log('Added marker with id: ${mapIconPoint.id}', source: runtimeType.toString());
    };
  }


  cleanMarkers() {
    emit(state.copyWith(
      selectedMarkerId: '',
      mapIconPoints: {},
      markers: {}
    ));
    Log.log('Markers cleaned', source: state.runtimeType.toString());
  }

  resizeMarkers() async {
    if (state.mapIconPoints.isEmpty) return;
    emit(state.copyWith(
        markers: await _markersFromPoints(state.mapIconPoints, rescaleFactor: state.rescaleFactor),
    ));
    Log.log('MapIconPoint markers rescaled with factor: ${state.rescaleFactor}', source: runtimeType.toString());
  }

  selectMarker(Marker? marker) {
    final markerId = marker == null ? '' : marker.markerId.value;
    if (markerId == state.selectedMarkerId) return;
    Log.log('Selecting marker with id: $markerId', source: runtimeType.toString());
    emit(state.copyWith(
      selectedMarkerId: markerId
    ));
  }

  replaceMarker(LatLng point, { required markerId }) async {
    Log.log('Moving marker: $markerId to lat: ${point.latitude}, lng: ${point.longitude}', source: state.runtimeType.toString());
    for (var mapIconPoint in state.mapIconPoints) {
      if (mapIconPoint.id == markerId) mapIconPoint.coordinates = point.coordinates;
    }
    emit(state.copyWith(
        mapIconPoints: state.mapIconPoints,
        markers: await _markersFromPoints(state.mapIconPoints, rescaleFactor: state.rescaleFactor),
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
  }) {

    final mapIconPoint = state.selectedMapIconPoint;
    if (mapIconPoint == null) throw 'mapIconPoint == null ';

    final craft = IconUtil.craftFromMapIconPoint(mapIconPoint);
    final wizard = IconWizard();
    wizard.run(context, edit: craft);
    wizard.onComplete = (newCraft) async {
      newCraft.id = craft.id;
      final points = state.mapIconPoints.map((point) {
        if (point.id == newCraft.id) {
          point = IconUtil.mapIconPointFromCraft(newCraft,
              IconUtil.pointFromCoordinates(mapIconPoint.coordinates)
          );
        }
        return point;
      });

      emit(state.copyWith(
        mapIconPoints: points.toSet(),
        markers: await _markersFromPoints(points, rescaleFactor: rescaleFactor),
      ));
    };
  }

  updateRescaleFactor(double rescaleFactor) {
    emit(state.copyWith(rescaleFactor: rescaleFactor));
  }

  turnDrawingMode({ required BuildContext context, required bool on }) {
    if (state.drawingMode == on) return;
    final drawingCubit = BlocProvider.of<DrawingCubit>(context);
    drawingCubit.turn(on: on);
    emit(state.copyWith(drawingMode: on));
    _validateDrawingMode(context);
  }

  _validateDrawingMode(BuildContext context) {
    final drawingState = BlocProvider.of<DrawingCubit>(context).state;
    if (drawingState.on == state.drawingMode) return;
    throw 'Drawing state mode error!';
  }

  addDrawingAsMarker({
    required BuildContext context,
    required List<DrawingPoint> drawingPoints
  }) async {
    turnDrawingMode(context: context, on: false);
    final devicePixelRatio = Platform.isAndroid
        ? MediaQuery.of(context).devicePixelRatio
        : 1.0;

    final marker = await MapUtil.getMarkerFromDrawing(
      devicePixelRatio: devicePixelRatio,
      mapController: state.mapController!,
      drawingPoints: drawingPoints
    );
    final markers = state.markers;
    markers.add(marker);
    emit(state.copyWith(
        markers: markers,
    ));
  }

}