import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_line.dart';
import 'package:flutter_map_toy/global/drawing/drawing_state.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/global/drawing/map_drawing_model.dart';
import 'package:flutter_map_toy/models/map_icon_model.dart';
import 'package:flutter_map_toy/models/map_model.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/presentation/dialogs/icon_wizard.dart';
import 'package:flutter_map_toy/presentation/dialogs/map_name_popup.dart';
import 'package:flutter_map_toy/presentation/views/home_screen.dart';
import 'package:flutter_map_toy/presentation/views/saved_maps_screen.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/draw_util.dart';
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
        icons: {},
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
        icons: mapIcons,
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
  addIconMarker(BuildContext context) {
    emit(state.copyWith(
      selectedMarkerId: ''
    ));
    final wizard = IconWizard();
    wizard.run(context);
    wizard.onComplete = (craft) async {
      if (craft.incomplete) return;
      final mapIconModel = IconUtil.mapIconPointFromCraft(craft, await state.mapViewCenter);
      final mapIconModels = state.icons;
      mapIconModels.add(mapIconModel);

      emit(state.copyWith(
          selectedMarkerId: '',
          icons: mapIconModels,
          markers: await _getAllMarkers(mapIcons: mapIconModels)
      ));
      Log.log('Added marker with id: ${mapIconModel.id}', source: runtimeType.toString());
    };
  }

  Future<Set<Marker>> _markersFromPoints(
      Iterable<MapIconModel> icons,
      ) async {
    final futures = icons.map((mapIconModel) {
      return MapUtil.getMarkerFromIcon(mapIconModel.rescale(state.rescaleFactor));
    });
    final markers = await Future.wait(futures);
    return markers.toSet();
  }

  updateIconMarker(BuildContext context) {
    final mapIconPoint = state.selectedMapIconPoint;
    if (mapIconPoint == null) throw 'mapIconPoint == null ';

    final craft = IconUtil.craftFromMapIconPoint(mapIconPoint);
    final wizard = IconWizard();
    wizard.run(context, edit: craft);
    wizard.onComplete = (newCraft) async {
      newCraft.id = craft.id;
      final points = state.icons.map((point) {
        if (point.id == newCraft.id) {
          point = IconUtil.mapIconPointFromCraft(newCraft,
              MapUtil.pointFromCoordinates(mapIconPoint.coordinates)
          );
        }
        return point;
      });

      emit(state.copyWith(
        icons: points.toSet(),
        markers: await _getAllMarkers(mapIcons: points),
        selectedMarkerId: '',
      ));
    };
  }

  /// DRAWINGS MANAGEMENT
  ///
  turnDrawingMode({ required BuildContext context, required bool on }) {
    emit(state.copyWith(
      drawingMode: on,
      ctx: context,
      selectedMarkerId: '',
    ));
  }

  addDrawingAsMarker({
    required BuildContext context,
    required List<DrawingLine> drawingLines
  }) async {
    final devicePixelRatio = Platform.isAndroid
        ? MediaQuery.of(context).devicePixelRatio
        : 1.0;

    final drawingModel = await DrawUtil.getModelFromDrawing(
        devicePixelRatio: devicePixelRatio,
        mapController: state.mapController!,
        drawingLines: drawingLines,
    );

    final rescaled = drawingModel.rescale(1/state.rescaleFactor);

    final drawings = state.drawings;
    drawings.add(rescaled);
    emit(state.copyWith(
      drawings: drawings,
      markers: await _getAllMarkers(drawings: drawings),
      drawingMode: false,
      ctx: context,
    ));
  }

  editDrawing(BuildContext context) async {
    final drawingCubit = BlocProvider.of<DrawingCubit>(context);
    final drawings = state.drawings.where((drawing) => drawing.id != state.selectedMarkerId);

    final mapDrawingModel = state.drawings.firstWhere((drawing) => drawing.id == state.selectedMarkerId);

    emit(state.copyWith(
      drawingMode: true,
      ctx: context,
      drawings: drawings.toSet(),
      markers: await _getAllMarkers(drawings: drawings)
    ));
    drawingCubit.emitStateToEditDrawing(mapDrawingModel);
  }

  Future<Set<Marker>> _markersFromDrawings(Iterable<MapDrawingModel> drawings) async {
    final futures = drawings.map((mapDrawingModel) {
      return DrawUtil.getMarkerFromDrawingModel(mapDrawingModel.rescale(state.rescaleFactor));
    });
    final markers = await Future.wait(futures);
    return markers.toSet();
  }


  /// MARKERS MANAGEMENT
  ///
  Future<Set<Marker>> _getAllMarkers({
    Iterable<MapIconModel>? mapIcons,
    Iterable<MapDrawingModel>? drawings,
  }) async {
    return  {
      ...(await _markersFromPoints(mapIcons ?? state.icons)),
      ...(await _markersFromDrawings(drawings ?? state.drawings))
    };
  }

  cleanMarkers() {
    emit(state.copyWith(
        selectedMarkerId: '',
        icons: {},
        drawings: {},
        markers: {},
    ));
    Log.log('Markers cleaned', source: state.runtimeType.toString());
  }

  selectMarker(Marker? marker, BuildContext context) {
    final markerId = marker == null ? '' : marker.markerId.value;
    if (markerId == state.selectedMarkerId) return;
    Log.log('Selecting marker with id: $markerId', source: runtimeType.toString());
    emit(state.copyWith(
      selectedMarkerId: markerId,
      drawingMode: false,
      ctx: context
    ));
  }

  replaceMarker(LatLng point, { required markerId }) async {
    Log.log('Moving marker: $markerId to lat: ${point.latitude}, lng: ${point.longitude}', source: state.runtimeType.toString());
    final mapIconPoints = state.isIcon(markerId) ? state.icons.map((mapIconPoint) {
      if (mapIconPoint.id == markerId) mapIconPoint.coordinates = point.coordinates;
      return mapIconPoint;
    }) : null;

    final drawings = state.isDrawing(markerId) ? state.drawings.map((drawing) {
      if (drawing.id == markerId) drawing.coordinates = point.coordinates;
      return drawing;
    }) : null;

    emit(state.copyWith(
      icons: mapIconPoints?.toSet(),
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

  removeMarker(bool? remove) async {
    if (remove == null || !remove) return;
    if (state.isDrawing(state.selectedMarkerId)) {
      state.drawings.removeWhere((drawing) => drawing.id == state.selectedMarkerId);
    } else {
      state.icons.removeWhere((icon) => icon.id == state.selectedMarkerId);
    }
    emit(state.copyWith(
      selectedMarkerId: '',
      markers: await _getAllMarkers()
    ));
  }

}