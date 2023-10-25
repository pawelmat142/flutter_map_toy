import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_line.dart';
import 'package:flutter_map_toy/global/drawing/drawing_state.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/models/map_icon_model.dart';
import 'package:flutter_map_toy/models/map_model.dart';
import 'package:flutter_map_toy/presentation/dialogs/icon_wizard.dart';
import 'package:flutter_map_toy/presentation/dialogs/map_name_popup.dart';
import 'package:flutter_map_toy/presentation/views/saved_maps_screen.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/icon_util.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_drawing_model.dart';

enum BlocState {
  empty,
  ready
}

class MapState {

  BlocState state;
  String mapModelId;
  Set<Marker> markers;
  Set<MapIconModel> mapIconPoints;
  Set<MapDrawingModel> drawings;
  String selectedMarkerId;
  MapType mapType;
  double rescaleFactor;
  bool drawingMode;
  GoogleMapController? mapController;

  bool get isAnyMarkerSelected => selectedMarkerId.isNotEmpty;
  bool get isAnyIconSelected => mapIconPoints.any((point) => point.id == selectedMarkerId);
  bool get isAnyDrawingSelected => isAnyMarkerSelected && !isAnyIconSelected;

  MapState(
    this.state,
    this.mapModelId,
    this.markers,
    this.mapIconPoints,
    this.drawings,
    this.selectedMarkerId,
    this.mapType,
    this.rescaleFactor,
    this.drawingMode,
    this.mapController,
  );

  MapState copyWith({
    BlocState? state,
    String? mapModelId,
    Set<Marker>? markers,
    Set<MapIconModel>? mapIconPoints,
    Set<MapDrawingModel>? drawings,
    String? selectedMarkerId,
    MapType? mapType,
    double? rescaleFactor,
    bool? drawingMode,
    GoogleMapController? mapController,
  }) {
    Log.log('New MapState', source: runtimeType.toString());
    return MapState(
      state ?? this.state,
      mapModelId ?? this.mapModelId,
      markers ?? this.markers,
      mapIconPoints ?? this.mapIconPoints,
      drawings ?? this.drawings,
      selectedMarkerId ?? this.selectedMarkerId,
      mapType ?? this.mapType,
      rescaleFactor ?? this.rescaleFactor,
      drawingMode ?? this.drawingMode,
      mapController ?? this.mapController,
    );
  }

  Marker? get selectedMarker => selectedMarkerId.isEmpty ? null
      : markers.firstWhere((marker) => marker.markerId.value == selectedMarkerId);

  MapIconModel? get selectedMapIconPoint => selectedMarkerId.isEmpty ? null
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

  MapCubit(): super(MapState(BlocState.empty, '', {}, {}, {}, '', MapType.normal, 1, false, null));

  initMap(GoogleMapController googleMapController) {
    emit(state.copyWith(
      state: BlocState.ready,
      mapController: googleMapController,
      selectedMarkerId: '',
    ));
  }

  cleanState() {
    emit(state.copyWith(
      mapModelId: '',
      markers: {},
      mapIconPoints: {},
      drawings: {},
      selectedMarkerId: '',
      rescaleFactor: 1,
    ));
  }

  //
  // MapState(
  //     this.state,
  //     this.mapModelId,
  //     this.markers,
  //     this.mapIconPoints,
  //     this.drawings,
  //     this.selectedMarkerId,
  //     this.mapType,
  //     this.rescaleFactor,
  //     this.drawingMode,
  //     this.mapController,
  //     );

  setType(MapType mapType) {
    emit(state.copyWith(mapType: mapType));
    Log.log('Selected: ${mapType.toString()}', source: state.runtimeType.toString());
  }

  addIconMarker(BuildContext context, {
    required LatLng mapViewCenter,
  }) {
    final wizard = IconWizard();
    wizard.run(context);
    wizard.onComplete = (craft) async {
      if (craft.incomplete) return;
      final mapIconPoint = IconUtil.mapIconPointFromCraft(craft, mapViewCenter);
      final mapIconPoints = state.mapIconPoints;
      mapIconPoints.add(mapIconPoint);

      emit(state.copyWith(
          selectedMarkerId: '',
          mapIconPoints: mapIconPoints,
          markers: await _getAllMarkers(mapIcons: mapIconPoints)
      ));
      Log.log('Added marker with id: ${mapIconPoint.id}', source: runtimeType.toString());
    };
  }

  cleanMarkers() {
    emit(state.copyWith(
      selectedMarkerId: '',
      mapIconPoints: {},
      drawings: {},
      markers: {}
    ));
    Log.log('Markers cleaned', source: state.runtimeType.toString());
  }

  resizeMarkers() async {
    //TODO resize drawings
    if (state.mapIconPoints.isEmpty) return;
    emit(state.copyWith(
        markers: await _getAllMarkers(),
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

    //TODO replace drawing marker
    final mapIconPoints = state.mapIconPoints.map((mapIconPoint) {
      if (mapIconPoint.id == markerId) mapIconPoint.coordinates = point.coordinates;
      return mapIconPoint;
    });
    emit(state.copyWith(
        mapIconPoints: mapIconPoints.toSet(),
        markers: await _getAllMarkers(mapIcons: mapIconPoints),
    ));
  }

  Future<Set<Marker>> _getAllMarkers({
    Iterable<MapIconModel>? mapIcons,
    Iterable<MapDrawingModel>? drawings,
  }) async {
    return  {
      ...(await _markersFromPoints(mapIcons ?? state.mapIconPoints)),
      ...(drawings ?? state.drawings).map((drawing) => MapUtil.getMarkerFromDrawingModel(drawing))
    };
  }

  Future<Set<Marker>> _markersFromPoints(
      Iterable<MapIconModel> points,
    ) async {
    final futures = points.map((mapIconPoint) {
      return MapUtil.getMarkerFromIcon(mapIconPoint.rescale(state.rescaleFactor));
    });
    final markers = await Future.wait(futures);
    return markers.toSet();
  }

  updateIconMarker(BuildContext context, {
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
              MapUtil.pointFromCoordinates(mapIconPoint.coordinates)
          );
        }
        return point;
      });

      emit(state.copyWith(
        mapIconPoints: points.toSet(),
        markers: await _getAllMarkers(mapIcons: points),
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
    required List<DrawingLine> drawingLines
  }) async {
    turnDrawingMode(context: context, on: false);
    final devicePixelRatio = Platform.isAndroid
        ? MediaQuery.of(context).devicePixelRatio
        : 1.0;

    final drawingModel = await MapUtil.getModelFromDrawing(
      devicePixelRatio: devicePixelRatio,
      mapController: state.mapController!,
      drawingLines: drawingLines
    );

    final drawings = state.drawings;
    drawings.add(drawingModel);
    emit(state.copyWith(
      drawings: drawings,
      markers: await _getAllMarkers(drawings: drawings)
    ));
  }

  loadStateFromModel(MapModel mapModel) async {
    final mapIcons = mapModel.icons.toSet();
    final drawings = mapModel.drawings.toSet();
    emit(state.copyWith(
      mapModelId: mapModel.id,
      drawings: drawings,
      mapIconPoints: mapIcons,
      markers: await _getAllMarkers(mapIcons: mapIcons, drawings: drawings),
      selectedMarkerId: '',
    ));
  }

  onSaveMapModel(BuildContext context) async {
    final mapModelName = state.mapModelId.isEmpty
        ? await MapNamePopup.show(context)
        : MapModel.getById(state.mapModelId)?.name;

    if (mapModelName == null) return;

    final mapModel = await MapModel.createByMapState(
      state: state,
      name: mapModelName,
      id: state.mapModelId.isEmpty ? null : state.mapModelId
    );
    mapModel.save();
    // ignore: use_build_context_synchronously
    Navigator.popAndPushNamed(context, SavedMapsScreen.id);
  }


}