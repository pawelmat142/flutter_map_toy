import 'package:flutter_map_toy/services/location_service.dart';
import 'package:flutter_map_toy/services/map_service.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

abstract class AppGetIt {

  static void init() {

    getIt.registerSingleton<LocationService>(LocationService());
    getIt.registerSingleton<MapService>(MapService());

  }
  
}