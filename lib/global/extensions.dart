import 'package:google_maps_flutter/google_maps_flutter.dart';

extension StringExtension on String {

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension LatLngExtension on LatLng {

  List<double> get coordinates => [ longitude, latitude ];
}