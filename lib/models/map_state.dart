import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_state.dart';
import 'package:flutter_map_toy/models/map_icon_model.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../global/drawing/map_drawing_model.dart';

enum BlocState {
  empty,
  ready
}

class MapState {

  BlocState state;
  String mapModelId;
  Set<Marker> markers;
  Set<MapIconModel> icons;
  Set<MapDrawingModel> drawings;
  String selectedMarkerId;
  MapType mapType;
  double rescaleFactor;
  bool drawingMode;
  GoogleMapController? mapController;
  CameraPosition? initialCameraPosition;
  double? initialDiagonalDistance;

  bool get isAnyMarkerSelected => selectedMarkerId.isNotEmpty;
  bool get isAnyIconSelected => icons.any((point) => point.id == selectedMarkerId);
  bool get isAnyDrawingSelected => isAnyMarkerSelected && !isAnyIconSelected;

  Marker? get selectedMarker => selectedMarkerId.isEmpty ? null
      : markers.firstWhere((marker) => marker.markerId.value == selectedMarkerId);

  MapIconModel? get selectedMapIconPoint => selectedMarkerId.isEmpty ? null
      : icons.firstWhere((point) => point.id == selectedMarkerId);

  Future<LatLng> get mapViewCenter async {
    final visibleRegion = await mapController!.getVisibleRegion();
    return LatLng(
      (visibleRegion.northeast.latitude + visibleRegion.southwest.latitude) / 2,
      (visibleRegion.northeast.longitude + visibleRegion.southwest.longitude) / 2,
    );
  }

  bool isIcon(String markerId) {
    return icons.any((point) => point.id == markerId);
  }

  bool isDrawing(String markerId) {
    return drawings.any((drawing) => drawing.id == markerId);
  }

  MapState(
    this.state,
    this.mapModelId,
    this.markers,
    this.icons,
    this.drawings,
    this.selectedMarkerId,
    this.mapType,
    this.rescaleFactor,
    this.drawingMode,
    this.mapController,
    this.initialCameraPosition,
    this.initialDiagonalDistance,
  );

  MapState copyWith({
    BlocState? state,
    String? mapModelId,
    Set<Marker>? markers,
    Set<MapIconModel>? icons,
    Set<MapDrawingModel>? drawings,
    String? selectedMarkerId,
    MapType? mapType,
    double? rescaleFactor,
    bool? drawingMode,
    GoogleMapController? mapController,
    CameraPosition? initialCameraPosition,
    BuildContext? ctx,
    double? initialDiagonalDistance,
  }) {
    if (drawingMode is bool) {
      if (ctx == null) throw 'context is needed when change drawingMode!';
      // if (this.drawingMode == drawingMode) return this;
      final drawingCubit = BlocProvider.of<DrawingCubit>(ctx);
      _validateDrawingMode(drawingCubit);
      drawingCubit.turn(on: drawingMode);
    }
    return MapState(
      state ?? this.state,
      mapModelId ?? this.mapModelId,
      markers ?? this.markers,
      icons ?? this.icons,
      drawings ?? this.drawings,
      selectedMarkerId ?? this.selectedMarkerId,
      mapType ?? this.mapType,
      rescaleFactor ?? this.rescaleFactor,
      drawingMode ?? this.drawingMode,
      mapController ?? this.mapController,
      initialCameraPosition ?? this.initialCameraPosition,
      initialDiagonalDistance ?? this.initialDiagonalDistance,
    );
  }

  _validateDrawingMode(DrawingCubit drawingCubit) {
    if (drawingCubit.state.on == drawingMode) return;
    throw 'Drawing state mode error!';
  }
}