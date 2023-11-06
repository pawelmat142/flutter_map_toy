import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_map_toy/services/get_it.dart';
import 'package:flutter_map_toy/services/location_service.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/location_util.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:uuid/uuid.dart';

// ignore: depend_on_referenced_packages
import 'package:google_maps_webservice/places.dart';

enum BlocState {
  initializing,
  ready,
  searching,
}

class LocationSearchState {

  BlocState state;
  String text;
  LatLng localization;
  String sessionToken;
  List<PlacesSearchResult> places;
  List<Prediction> predictions;
  Locale? locale;
  TextEditingController controller;
  FocusNode focusNode;

  bool get initializing => state == BlocState.initializing;

  LocationSearchState(
    this.state,
    this.text,
    this.localization,
    this.sessionToken,
    this.places,
    this.predictions,
    this.locale,
    this.controller,
    this.focusNode,
  );

  LocationSearchState copyWith({
    BlocState? state,
    String? text,
    LatLng? localization,
    List<PlacesSearchResult>? places,
    List<Prediction>? predictions,
  }) {
    return LocationSearchState(
      state ?? this.state,
      text ?? this.text,
      localization ?? this.localization,
      sessionToken,
      places ?? this.places,
      predictions ?? this.predictions,
      locale,
      controller,
      focusNode,
    );
  }

}

class LocationSearchCubit extends Cubit<LocationSearchState> {

  final GoogleMapsPlaces googleMapPlaces;

  static GoogleMapsPlaces get googleMapsPlaces {
    final key = FlutterConfig.get('GOOGLE_MAPS_API_KEY');
    if (key == 'not_found') {
      throw 'GOOGLE_MAPS_API_KEY not found';
    }
    return GoogleMapsPlaces(apiKey: key);
  }

  LocationSearchCubit({
    required this.googleMapPlaces,
  }) : super(LocationSearchState(
      BlocState.initializing,
      '',
      MapUtil.initialPosition,
      const Uuid().v4(),
      [],
      [],
      null,
      TextEditingController(),
      FocusNode()
  ));

  final locationService = getIt.get<LocationService>();

  StreamSubscription? subscription;

  initialization(BuildContext context) async {
    if (state.locale == null) {
      final Locale locale = Localizations.localeOf(context);

      final localization = await locationService.getMyLocation();

      emit(state.copyWith(
        state: BlocState.ready,
        localization: pointFromLocationData(localization),
      )..locale = locale);

      Log.log('Location search state initialized!', source: runtimeType.toString());
    }
  }

  startLocationSubscription(BuildContext context) {
    subscription ??= locationService.onLocationChanged.listen((LocationData locationData) {
      emit(state.copyWith(
        localization: pointFromLocationData(locationData)
      ));
      Log.log('Location changed!, ${state.localization}', source: runtimeType.toString());
    });
  }

  stopLocationSubscription() {
    if (subscription is StreamSubscription) {
      subscription!.cancel();
      subscription = null;
      Log.log('Localization subscription stopped!', source: runtimeType.toString());
    }
  }

  write(String text) {
    emit(state.copyWith(text: text));
    if (state.text.length > 2) {
      search();
    } else {
      cleanResults();
    }
  }

  cleanResults() {
    emit(state.copyWith(
      places: [],
      predictions: [],
    ));
  }

  search({ bool byButton = false }) {
    if (state.locale == null) throw 'locale = null';
    final input = state.text;
    if (input.isEmpty) return;

    googleMapsPlaces.searchByText(input,
      language: byButton ? null : state.locale!.languageCode,
      location: byButton ? null : LocationUtil.locationFromPoint(state.localization)
    ).then((PlacesSearchResponse response) {
      Log.log('PlacesSearchResponse status is ${response.status}', source: runtimeType.toString());

      if (response.isOkay) {
        emit(state.copyWith(
          places: response.results,
        ));
      }

    });
  }

  static LatLng pointFromLocationData(LocationData locationData) {
    if (locationData.latitude is double && locationData.longitude is double) {
      return LatLng(locationData.latitude!, locationData.latitude!);
    }
    throw 'missing latitude or longitude';
  }

}