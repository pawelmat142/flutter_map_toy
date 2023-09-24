import 'package:google_maps_flutter/google_maps_flutter.dart';

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension LatLngExtension on LatLng {

  static LatLng fromCoordinates(List<double> coordinates) {
    if (coordinates.length != 2) {
      throw 'coordinates length != 2';
    }
    return LatLng(coordinates[1], coordinates[0]);
  }

  List<double> get coordinates => [ longitude, latitude ];
}