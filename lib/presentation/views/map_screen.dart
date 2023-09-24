import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/components/toolbar.dart';
import 'package:flutter_map_toy/presentation/styles/app_icon.dart';
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

      bottomNavigationBar: Toolbar(toolbarItems: [
        ToolBarItem(
          label: 'add_point',
          barLabel: 'add point',
          menuLabel: 'add point',
          icon: AppIcon.addPoint,
          onTap: _onAddPoint,
        ),
        ToolBarItem(
            label: 'clean_map',
            barLabel: 'clean',
            menuLabel: 'clean',
            icon: AppIcon.cleanPoint,
            onTap: (){}
        ),
        ToolBarItem(
            label: 'save_map',
            barLabel: 'save',
            menuLabel: 'save',
            icon: AppIcon.save,
            onTap: (){}
        ),
        ToolBarItem(
            label: Toolbar.menuLabel,
            barLabel: 'menu',
            icon: AppIcon.menu,
            onTap: (){}
        ),
      ],),
    );

  }

  _onAddPoint() {
    print('todo');
  }

  _onClean() {
    print('onclean');
  }

  _onSave() {
    print('onsave');
  }

  _onMapCreated(GoogleMapController controller) async {
    _controllerFuture.complete(controller);
    _controller = await _controllerFuture.future;
    Log.log('GoogleMap created', source: widget.runtimeType.toString());
  }

}
