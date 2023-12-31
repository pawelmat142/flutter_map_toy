import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/drawing/drawing_line.dart';
import 'package:flutter_map_toy/global/drawing/drawing_state.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/global/drawing/map_drawing_model.dart';
import 'package:flutter_map_toy/models/map_icon_model.dart';
import 'package:flutter_map_toy/models/map_model.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/models/marker_info.dart';
import 'package:flutter_map_toy/presentation/dialogs/icon_wizard.dart';
import 'package:flutter_map_toy/presentation/dialogs/popups/app_popup.dart';
import 'package:flutter_map_toy/presentation/dialogs/popups/text_input_popup.dart';
import 'package:flutter_map_toy/presentation/views/home_screen.dart';
import 'package:flutter_map_toy/presentation/views/saved_maps_screen.dart';
import 'package:flutter_map_toy/services/get_it.dart';
import 'package:flutter_map_toy/services/location_service.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/draw_util.dart';
import 'package:flutter_map_toy/utils/icon_util.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:flutter_map_toy/utils/time.dart';
import 'package:flutter_map_toy/utils/timer_handler.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapCubit extends Cubit<MapState> {

  static final cameraMoveEndHandler = TimerHandler(milliseconds: 50);

  final locationService = getIt.get<LocationService>();

  MapCubit(): super(MapState(BlocState.loading, '', {}, {}, {}, '', MapType.satellite, false, null, null, null));

  Future<void> setInitialPosition({ LatLng? point }) async {
    Log.log('Set initial position', source: runtimeType.toString());
    final initialPosition = point is LatLng
      ? CameraPosition(target: point, zoom: MapUtil.kZoomInitial)
      : await locationService.getMyInitialCameraPosition();
    emit(state.copyWith(
      state: BlocState.ready,
      initialCameraPosition: initialPosition,
    ));
  }

  final completer = Completer<GoogleMapController>();

  initMap(GoogleMapController controller) async {
    if (!completer.isCompleted) {
      completer.complete(controller);
      controller = await completer.future;
    }
    emit(state.copyWith(
      state: BlocState.ready,
      selectedMarkerId: '',
      mapController: controller
    ));
    Log.log('Map initialized', source: runtimeType.toString());
    await Time.wait(500);
    MapUtil.animateCameraToMapCenter(state);
  }

  dispose(BuildContext context) {
    emit(state.copyWith(
      state: BlocState.loading,
      mapModelId: '',
      markers: [],
      icons: {},
      drawings: {},
      selectedMarkerId: '',
      drawingMode: false,
      ctx: context,
    )
      ..initialCameraPosition = null
    );
    Log.log('Map disposed!', source: runtimeType.toString());
  }

  setType(MapType mapType) {
    emit(state.copyWith(mapType: mapType));
    Log.log('Selected: ${mapType.toString()}', source: state.runtimeType.toString());
  }

  loadStateFromModel(BuildContext context, MapModel mapModel) async {
    final mapIcons = mapModel.icons;
    final drawings = mapModel.drawings;
    final markers = await _getAllMarkers(context,
        icons: mapIcons,
        drawings: drawings
    );
    emit(state.copyWith(
        state: BlocState.ready,
        mapModelId: mapModel.id,
        drawings: drawings.toSet(),
        icons: mapIcons.toSet(),
        markers: markers,
        selectedMarkerId: '',
        initialCameraPosition: MapUtil.getCameraPosition(MapUtil.pointFromCoordinates(mapModel.mainCoordinates))
    ));
  }

  onSaveMapModel(BuildContext context) async {
    if (state.markers.isEmpty) {
      AppPopup(context)
          .title('There are no marekrs')
          .cancel(null)
          .show();
      return;
    }

    final mapModelName = state.mapModelId.isEmpty
        ? await TextInputPopup(context)
            .title('Please provide map name')
            .cancel('Back')
            .show()
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
    IconWizard()
      .run(context)
      .onComplete = (craft) async {
        if (craft.incomplete) return;
        final mapIconModel = IconUtil.mapIconPointFromCraft(craft,
          point: await state.mapViewCenter,
        );
        final mapIconModels = state.icons;
        mapIconModels.add(mapIconModel);

        emit(state.copyWith(
            selectedMarkerId: '',
            icons: mapIconModels,
            // ignore: use_build_context_synchronously
            markers: await _getAllMarkers(context, icons: mapIconModels)
        ));
        Log.log('Added marker with id: ${mapIconModel.id}', source: runtimeType.toString());
    };
  }

  Iterable<Future<Marker>> _markerFromIconFutures(
    Iterable<MapIconModel> icons,
    BuildContext context,
    double rescaleFactor,
  ) {
    return icons.map((mapIconModel) {
      return IconUtil.getMarkerFromIcon(mapIconModel.rescale(rescaleFactor), context);
    });
  }

  updateIconMarker(BuildContext context) {
    final mapIconPoint = state.selectedMapIconPoint;
    if (mapIconPoint == null) throw 'mapIconPoint == null ';

    final craft = IconUtil.craftFromMapIconPoint(mapIconPoint);
    IconWizard()
      .run(context, edit: craft)
      .onComplete = (newCraft) async {
        newCraft.id = craft.id;
        final points = state.icons.map((point) {
          if (point.id == newCraft.id) {
            point = IconUtil.mapIconPointFromCraft(newCraft,
              point: MapUtil.pointFromCoordinates(mapIconPoint.coordinates),
            );
          }
          return point;
        });

      emit(state.copyWith(
        icons: points.toSet(),
        markers: await _getAllMarkers(context, icons: points),
        selectedMarkerId: '',
      ));
    };
  }

  /// DRAWINGS MANAGEMENT
  ///
  turnOnDrawingMode({ required BuildContext context }) {
    if (state.angle == 0) {
      turnDrawingMode(context: context, on: true);
    } else {
      AppPopup(context)
          .title('You can\'t draw on rotated map')
          .content('Do you want to reset map rotation?')
          .cancel('No').ok('Yes')
          .onOk(() {
            MapUtil.animateCameraToDefaultRotation(state);
            turnDrawingMode(context: context, on: true);
      });
    }
  }
  turnDrawingMode({ required BuildContext context, required bool on }) {
    emit(state.copyWith(
      drawingMode: on,
      ctx: context,
      selectedMarkerId: '',
    ));
  }

  addDrawingAsMarker({
    required BuildContext context,
    required List<DrawingLine> drawingLines,
    String? drawingModelId,
    MarkerInfo? markerInfo
  }) async {
    final markers = state.markers;
    final drawings = state.drawings;
    markers.removeWhere((marker) => marker.markerId.value == drawingModelId);
    drawings.removeWhere((drawing) => drawing.id == drawingModelId);

    DrawUtil.getModelFromDrawing(
      context: context,
      mapController: state.mapController!,
      drawingLines: drawingLines,
      drawingModelId: drawingModelId,
      markerInfo: markerInfo,
    ).then((MapDrawingModel mapDrawingModel) {

      drawings.add(mapDrawingModel.rescale(1/state.rescaleFactor));
      _getAllMarkers(
          context,
          drawings: drawings
      ).then((List<Marker> markers) {
        emit(state.copyWith(
          drawings: drawings,
          markers:  markers,
          drawingMode: false,
          ctx: context,
        ));
      });

    });

  }

  editDrawing(BuildContext context) async {
    final drawingCubit = BlocProvider.of<DrawingCubit>(context);

    final mapDrawingModel = state.drawings
        .firstWhere((drawing) => drawing.id == state.selectedMarkerId)
        .rescale(state.rescaleFactor);

    final drawings = state.drawings;
    drawings.removeWhere((drawing) => drawing.id == state.selectedMarkerId);
    emit(state.copyWith(
      drawings: drawings,
      markers: await _getAllMarkers(context, drawings: drawings)
    ));

    final mapCenter = MapUtil.pointFromCoordinates(mapDrawingModel.coordinates);
    if (state.mapController == null) throw 'state.mapController == null';
    state.mapController!
      .getScreenCoordinate(mapCenter)
      .then((ScreenCoordinate screenCoordinate) {
        final drawingLines = DrawUtil.prepareDrawingOffsetToEdit(
            mapDrawingModel: mapDrawingModel,
            screenCoordinate: screenCoordinate,
            context: context
        );
        drawingCubit.emitStateToEditDrawing(drawingLines, mapDrawingModel.id);
        turnDrawingMode(context: context, on: true);
    });
  }

  Iterable<Future<Marker>> _markerFromDrawingFutures(
      Iterable<MapDrawingModel> drawings,
      BuildContext context,
      double rescaleFactor
    ) {
    return drawings.map((mapDrawingModel) {
      return DrawUtil.getMarkerFromDrawingModel(mapDrawingModel.rescale(rescaleFactor), context);
    });
  }


  /// MARKERS MANAGEMENT
  ///
  Future<List<Marker>> _getAllMarkers(BuildContext context, {
    Iterable<MapIconModel>? icons,
    Iterable<MapDrawingModel>? drawings,
  }) async {
    final rescaleFactor = state.rescaleFactor;
    final markersFutures = _markerFromIconFutures(icons ?? state.icons, context, rescaleFactor);
    final drawingsFutures = _markerFromDrawingFutures(drawings ?? state.drawings, context, rescaleFactor);
    return Future.wait(markersFutures.toList() + drawingsFutures.toList());
  }

  cleanMarkers(BuildContext context) {
    AppPopup(context)
      .title('Are you sure?')
      .content('Map will be cleaned!')
      .onOk(() => emit(state.copyWith(
        selectedMarkerId: '',
        icons: {},
        drawings: {},
        markers: [],
    ))).then((value) {
      Log.log('Markers cleaned', source: state.runtimeType.toString());
    });
  }

  selectMarker(String markerId, BuildContext context) {
    if (markerId == state.selectedMarkerId) return;
    Log.log('Selecting marker with id: $markerId', source: runtimeType.toString());
    emit(state.copyWith(
      selectedMarkerId: markerId,
      drawingMode: false,
      ctx: context
    ));
  }

  replaceMarker(BuildContext context, LatLng point, { required markerId }) async {
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
      markers: await _getAllMarkers(context, icons: mapIconPoints, drawings: drawings),
    ));
  }

  removeMarker(bool? remove, BuildContext context) async {
    if (remove == null || !remove) return;
    if (state.isDrawing(state.selectedMarkerId)) {
      state.drawings.removeWhere((drawing) => drawing.id == state.selectedMarkerId);
    } else {
      state.icons.removeWhere((icon) => icon.id == state.selectedMarkerId);
    }
    emit(state.copyWith(
      selectedMarkerId: '',
      markers: await _getAllMarkers(context)
    ));
  }

  updateCameraPosition(CameraPosition cameraPosition, BuildContext context) async {
    Log.log('New CameraPosition, zoom: ${cameraPosition.zoom}, angle: ${cameraPosition.bearing}');
    emit(state.copyWith(
        cameraPosition: cameraPosition,
    ));
    cameraMoveEndHandler.handle(() {
      //onCameraMoveEnd:
      rescaleMarkers(context).then((_) {
        _unselectMarkerIfOutOfView(context);
      });
    });
  }

  Future<void> rescaleMarkers(BuildContext context) async {
    final markers = await _getAllMarkers(context);
    emit(state.copyWith(
      markers: markers,
    ));
  }

  _unselectMarkerIfOutOfView(BuildContext context) {
    if (state.selectedMarker != null) {
      //workaround solution, also in _onMarkerTap
      //GoogleMaps API doesn't share info about selected marker id or something
      //this solution should integrate google maps marker selection with this app marker selection
      //its not perfect so marker selection may be not synchronized
      state.mapController?.getVisibleRegion().then((visibleRegion) {
        final markerVisible = visibleRegion.contains(state.selectedMarker!.position);
        if (!markerVisible) {
          final selectedMarker = state.selectedMarker;
          selectMarker('', context);
          if (selectedMarker is Marker) {
            state.mapController?.hideMarkerInfoWindow(selectedMarker.markerId);
          }
        }
      });
    }
  }

  setMarkerInfo(BuildContext context, MarkerInfo markerInfo) async {
    final marker = state.selectedMarker;
    if (marker is Marker) {

      Iterable<MapDrawingModel>? drawings;
      Iterable<MapIconModel>? icons;

      if (state.isDrawing(marker.markerId.value)) {
        drawings = state.drawings.map((drawing) {
          if (drawing.id == marker.markerId.value) {
            drawing.name = markerInfo.name;
            drawing.description = markerInfo.description ?? '';
          }
          return drawing;
        });
      }
      if (state.isIcon(marker.markerId.value)) {
        icons = state.icons.map((icon) {
          if (icon.id == marker.markerId.value) {
            icon.name = markerInfo.name;
            icon.description = markerInfo.description ?? '';
          }
          return icon;
        });
      }

      emit(state.copyWith(
        drawings: drawings?.toSet(),
        icons: icons?.toSet(),
        markers: await _getAllMarkers(context, icons: icons, drawings: drawings)
      ));
    }

  }

}