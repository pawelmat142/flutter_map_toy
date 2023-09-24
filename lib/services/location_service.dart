import 'package:flutter_map_toy/services/log.dart';
import 'package:location/location.dart';

class LocationService {

  final _location = Location();

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