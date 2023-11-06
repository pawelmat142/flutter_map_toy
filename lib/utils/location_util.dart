import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore: depend_on_referenced_packages
import 'package:google_maps_webservice/places.dart';

abstract class LocationUtil {

  static Location locationFromPoint(LatLng point) => Location(
      lat: point.latitude,
      lng: point.longitude
  );

  static LatLng pointFromLocation(Location location) => LatLng(location.lat, location.lng);

}