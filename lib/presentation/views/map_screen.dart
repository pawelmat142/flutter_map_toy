import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map_toy/services/log.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapScreen extends StatefulWidget {
  static const String id = 'map_screen';

  static push(BuildContext context, CameraPosition initialCameraPosition) {
    Navigator.push(context, MaterialPageRoute(builder: (ctx) =>
        MapScreen(initialCameraPosition: initialCameraPosition)));
  }

  final CameraPosition initialCameraPosition;

  const MapScreen({
    required this.initialCameraPosition,
    Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {

  final Completer<GoogleMapController> _controllerFuture = Completer<GoogleMapController>();
  late GoogleMapController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('Map'),),

      body: GoogleMap(
        initialCameraPosition: widget.initialCameraPosition,
        mapType: MapType.normal,
        onMapCreated: _onMapCreated
      ),
    );

  }

  _onMapCreated(GoogleMapController controller) async {
    print('on map created');
    _controllerFuture.complete(controller);
    _controller = await _controllerFuture.future;
    Log.log('GoogleMapController created', source: widget.runtimeType.toString());
  }

}
