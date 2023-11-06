import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_config/flutter_config.dart';
import 'package:flutter_map_toy/services/get_it.dart';
import 'package:flutter_map_toy/services/location_service.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:uuid/uuid.dart';

// ignore: depend_on_referenced_packages
import 'package:google_maps_webservice/places.dart';

enum BlocState {
  empty,
  ready,
  searching,
}

class LocationSearchState {

  String text;
  LatLng location;
  String sessionToken;
  List<PlacesSearchResult> results;
  List<Prediction> predictions;
  String searchLanguage;
  TextEditingController controller;
  FocusNode focusNode;

  LocationSearchState(
    this.text,
    this.location,
    this.sessionToken,
    this.results,
    this.predictions,
    this.searchLanguage,
    this.controller,
    this.focusNode,
  );

  LocationSearchState copyWith({
    String? text,
    LatLng? location,
    List<PlacesSearchResult>? results,
    List<Prediction>? predictions,
    String? searchLanguage,
  }) {
    return LocationSearchState(
      text ?? this.text,
      location ?? this.location,
      sessionToken,
      results ?? this.results,
      predictions ?? this.predictions,
      searchLanguage ?? this.searchLanguage,
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

  LocationSearchCubit(this.googleMapPlaces) : super(LocationSearchState(
      '',
      MapUtil.initialPosition,
      const Uuid().v4(),
      [],
      [],
      'pl',
      TextEditingController(),
      FocusNode()
  ));

  final locationService = getIt.get<LocationService>();

  startLocationListener() {
    locationService.onLocationChanged.listen((event) { });
  }


  write(String text) {
    emit(state.copyWith(text: text));
    if (state.text.length > 3) {
      search();
    }
  }

  cleanResults() {
    emit(state.copyWith(
      results: [],
      predictions: [],
    ));
  }

  //TODO add location subscription and to query
  //TODO add dynamic language code
  search() {
    final input = state.text;
    if (input.isEmpty) return;

    googleMapsPlaces.searchByText(input,
      language: state.searchLanguage,
    ).then((PlacesSearchResponse response) {
      Log.log('PlacesSearchResponse status is ${response.status}', source: runtimeType.toString());

      if (response.isOkay) {
        emit(state.copyWith(
          results: response.results,
        ));
      }

    });
  }

}