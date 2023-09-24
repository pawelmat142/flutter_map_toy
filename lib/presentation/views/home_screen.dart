import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/components/controls/primary_button.dart';
import 'package:flutter_map_toy/presentation/components/controls/red_button.dart';
import 'package:flutter_map_toy/presentation/components/controls/blue_button.dart';
import 'package:flutter_map_toy/presentation/dialogs/icon_craft.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';
import 'package:flutter_map_toy/presentation/views/map_screen.dart';
import 'package:flutter_map_toy/services/get_it.dart';
import 'package:flutter_map_toy/services/location_service.dart';
import 'package:flutter_map_toy/utils/map_util.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatelessWidget {
  static const String id = 'home_screen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(title: const Text('Home')),

      body: Padding(
        padding: AppStyle.defaultPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            PrimaryButton('go to map',
              onPressed: () async {
                final myLocation = await getIt.get<LocationService>().getMyLocation();
                if (myLocation.latitude is double && myLocation.longitude is double) {
                  final initialCameraPosition = CameraPosition(
                    target: LatLng(myLocation.latitude!, myLocation.longitude!),
                    zoom: MapUtil.kZoomInitial
                  );
                  // ignore: use_build_context_synchronously
                  MapScreen.push(context, initialCameraPosition);
                }
                if (kDebugMode) {
                  print(myLocation);
                }

              }
            ),

            AppStyle.verticalDefaultDistance,
            BlueButton('blue button',
              onPressed: () {
                if (kDebugMode) {
                  final craft = IconCraft();
                  craft.create(context);
                  // print('xx');
                }
              },
            ),

            AppStyle.verticalDefaultDistance,
            RedButton('red button',
              onPressed: () {
                if (kDebugMode) {
                  print('xx');
                }
              },
            )

          ],
        ),
      ),
    );
  }
}
