import 'package:flutter_map_toy/services/log.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class LocationService {

  final _location = Location();

  Stream<LocationData> get onLocationChanged => _location.onLocationChanged;

  Future<CameraPosition> getMyInitialCameraPosition() async {
    final myLocation = await getMyLocation();
    return CameraPosition(
        target: LatLng(myLocation.latitude!, myLocation.longitude!),
        zoom: MapUtil.kZoomInitial
    );
  }

  Future<LocationData> getMyLocation() async {
    await _checkService();
    await _checkPermission();

    return _location.getLocation();
  }

  _checkService() async {
    bool serviceEnabled = await _location.serviceEnabled();
    Log.log('location service enabled: $serviceEnabled');

    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        throw Exception('Location service not enabled');
      }
    }
  }

  _checkPermission() async {
    PermissionStatus permissionGranted = await _location.hasPermission();
    Log.log('Location permission granted: $permissionGranted', source: runtimeType.toString());

    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        throw Exception('Location permission denied!');
      }
    }
  }

}