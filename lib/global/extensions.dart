import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

extension StringExtension on String {

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension LatLngExtension on LatLng {

  List<double> get coordinates => [ longitude, latitude ];
}

extension DateTimeExtension on DateTime {

  static final formatter = DateFormat('kk:mm dd-MM-yyyy');

  String get format => formatter.format(this);
}