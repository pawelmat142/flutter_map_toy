import 'dart:async';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_state.dart';
import 'package:flutter_map_toy/models/map_icon_model.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/drawing/map_drawing_model.dart';

enum BlocState {
  empty,
  ready,
  loading,
  initializing
}

class MapState {

  BlocState state;
  String mapModelId;
  Set<Marker> markers;
  Set<MapIconModel> icons;
  Set<MapDrawingModel> drawings;
  String selectedMarkerId;
  MapType mapType;
  // double rescaleFactor;
  bool drawingMode;
  GoogleMapController? mapController;
  CameraPosition? initialCameraPosition;
  CameraPosition? cameraPosition;
  Completer<GoogleMapController> mapCompleter;

  bool get isAnyMarkerSelected => selectedMarkerId.isNotEmpty;
  bool get isAnyIconSelected => icons.any((point) => point.id == selectedMarkerId);
  bool get isAnyDrawingSelected => isAnyMarkerSelected && !isAnyIconSelected;

  Marker? get selectedMarker => selectedMarkerId.isEmpty ? null
      : markers.firstWhere((marker) => marker.markerId.value == selectedMarkerId);

  MapIconModel? get selectedMapIconPoint => selectedMarkerId.isEmpty ? null
      : icons.firstWhere((point) => point.id == selectedMarkerId);

  Future<LatLng> get mapViewCenter async {
    if (mapController == null) throw 'mapController == null';
    final visibleRegion = await mapController!.getVisibleRegion();
    return LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
    );
  }

  double get angle => cameraPosition?.bearing ?? 0;

  double get rescaleFactor => cameraPosition is CameraPosition ? pow(2, MapUtil.kZoomInitial - cameraPosition!.zoom).toDouble() : 1;

  bool get initializing => state == BlocState.initializing;

  bool isIcon(String markerId) {
    return icons.any((point) => point.id == markerId);
  }

  bool isDrawing(String markerId) {
    return drawings.any((drawing) => drawing.id == markerId);
  }

  unselectMarker() async {
    final marker = selectedMarker;
    if (marker is Marker) {
      final isSelected = await mapController?.isMarkerInfoWindowShown(marker.markerId) ?? false;
      if (isSelected) {
        mapController?.hideMarkerInfoWindow(marker.markerId);
      }
    }
  }

  MapState(
    this.state,
    this.mapModelId,
    this.markers,
    this.icons,
    this.drawings,
    this.selectedMarkerId,
    this.mapType,
    this.drawingMode,
    this.mapController,
    this.initialCameraPosition,
    this.cameraPosition,
    this.mapCompleter,
  );

  MapState copyWith({
    BlocState? state,
    String? mapModelId,
    List<Marker>? markers,
    Set<MapIconModel>? icons,
    Set<MapDrawingModel>? drawings,
    String? selectedMarkerId,
    MapType? mapType,
    bool? drawingMode,
    GoogleMapController? mapController,
    CameraPosition? initialCameraPosition,
    BuildContext? ctx,
    CameraPosition? cameraPosition,
  }) {
    if (drawingMode is bool) {
      if (ctx == null) throw 'context is needed when change drawingMode!';
      // if (this.drawingMode == drawingMode) return this;
      final drawingCubit = BlocProvider.of<DrawingCubit>(ctx);
      // _validateDrawingMode(drawingCubit);
      drawingCubit.turn(on: drawingMode);
    }
    return MapState(
      state ?? this.state,
      mapModelId ?? this.mapModelId,
      markers?.toSet() ?? this.markers,
      icons ?? this.icons,
      drawings ?? this.drawings,
      selectedMarkerId ?? this.selectedMarkerId,
      mapType ?? this.mapType,
      drawingMode ?? this.drawingMode,
      mapController ?? this.mapController,
      initialCameraPosition ?? this.initialCameraPosition,
      cameraPosition ?? this.cameraPosition,
      mapCompleter
    );
  }

}