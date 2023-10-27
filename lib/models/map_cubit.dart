import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_line.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/models/map_drawing_model.dart';
import 'package:flutter_map_toy/models/map_icon_model.dart';
import 'package:flutter_map_toy/models/map_model.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/presentation/dialogs/icon_wizard.dart';
import 'package:flutter_map_toy/presentation/dialogs/map_name_popup.dart';
import 'package:flutter_map_toy/presentation/views/home_screen.dart';
import 'package:flutter_map_toy/presentation/views/saved_maps_screen.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/icon_util.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapCubit extends Cubit<MapState> {

  MapCubit(): super(MapState(BlocState.empty, '', {}, {}, {}, '', MapType.normal, 1, false, null, null, null));


  initMap(GoogleMapController controller) async {
    final completer = Completer<GoogleMapController>();
    completer.complete(controller);
    controller = await completer.future;
    final diagonalDistance = await MapUtil.calcMapViewDiagonalDistance(controller);
    if (diagonalDistance == 0) {
      Future.delayed(const Duration(milliseconds: 500), () {
        initMap(controller);
      });
    } else {
      emit(state.copyWith(
        state: BlocState.ready,
        mapController: controller,
        selectedMarkerId: '',
        initialDiagonalDistance: diagonalDistance
      ));
    }
  }

  setInitialCameraPosition(CameraPosition initialCameraPosition) {
    emit(state.copyWith(initialCameraPosition: initialCameraPosition));
  }

  emitNewMapState(CameraPosition initialCameraPosition) {
    emit(state.copyWith(
        mapModelId: '',
        markers: {},
        mapIconPoints: {},
        drawings: {},
        selectedMarkerId: '',
        rescaleFactor: 1,
        initialCameraPosition: initialCameraPosition,
    ));
  }

  setType(MapType mapType) {
    emit(state.copyWith(mapType: mapType));
    Log.log('Selected: ${mapType.toString()}', source: state.runtimeType.toString());
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
        initialCameraPosition: MapUtil.getCameraPosition(MapUtil.pointFromCoordinates(mapModel.mainCoordinates))
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
    Navigator.pushNamedAndRemoveUntil(context,
        SavedMapsScreen.id,
        ModalRoute.withName(HomeScreen.id)
    );
  }


  /// ICONS MANAGEMENT
  ///
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

  /// DRAWINGS MANAGEMENT
  ///
  turnDrawingMode({ required BuildContext context, required bool on }) {
    emit(state.copyWith(
      drawingMode: on,
      ctx: context,
    ));
  }

  addDrawingAsMarker({
    required BuildContext context,
    required List<DrawingLine> drawingLines
  }) async {
    final devicePixelRatio = Platform.isAndroid
        ? MediaQuery.of(context).devicePixelRatio
        : 1.0;

    final drawingModel = await MapUtil.getModelFromDrawing(
        devicePixelRatio: devicePixelRatio,
        mapController: state.mapController!,
        drawingLines: drawingLines,
    );

    final drawings = state.drawings;
    drawings.add(drawingModel);
    emit(state.copyWith(
      drawings: drawings,
      markers: await _getAllMarkers(drawings: drawings),
      drawingMode: false,
      ctx: context,
    ));
  }


  /// MARKERS MANAGEMENT
  ///
  Future<Set<Marker>> _getAllMarkers({
    Iterable<MapIconModel>? mapIcons,
    Iterable<MapDrawingModel>? drawings,
  }) async {
    return  {
      ...(await _markersFromPoints(mapIcons ?? state.mapIconPoints)),
      ...(drawings ?? state.drawings).map((drawing) => MapUtil.getMarkerFromDrawingModel(drawing))
    };
  }

  cleanMarkers() {
    emit(state.copyWith(
        selectedMarkerId: '',
        mapIconPoints: {},
        drawings: {},
        markers: {},
    ));
    Log.log('Markers cleaned', source: state.runtimeType.toString());
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
    final mapIconPoints = state.isIcon(markerId) ? state.mapIconPoints.map((mapIconPoint) {
      if (mapIconPoint.id == markerId) mapIconPoint.coordinates = point.coordinates;
      return mapIconPoint;
    }) : null;

    final drawings = state.isDrawing(markerId) ? state.drawings.map((drawing) {
      if (drawing.id == markerId) drawing.coordinates = point.coordinates;
      return drawing;
    }) : null;

    emit(state.copyWith(
      mapIconPoints: mapIconPoints?.toSet(),
      drawings: drawings?.toSet(),
      markers: await _getAllMarkers(mapIcons: mapIconPoints, drawings: drawings),
    ));
  }

  updateRescaleFactor() async {
    final distance = await MapUtil.calcMapViewDiagonalDistance(state.mapController!);
    final factor = state.initialDiagonalDistance! / distance;
    if (factor != state.rescaleFactor) {
      state.rescaleFactor = factor;
      emit(state.copyWith(
          rescaleFactor: factor,
          markers: await _getAllMarkers()
      ));
    }
  }

}