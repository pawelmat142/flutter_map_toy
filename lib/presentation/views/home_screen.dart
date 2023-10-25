import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/models/map_model.dart';
import 'package:flutter_map_toy/models/map_state.dart';
import 'package:flutter_map_toy/presentation/components/controls/primary_button.dart';
import 'package:flutter_map_toy/presentation/components/controls/blue_button.dart';
import 'package:flutter_map_toy/presentation/components/controls/red_button.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';
import 'package:flutter_map_toy/presentation/views/map_screen/map_screen.dart';
import 'package:flutter_map_toy/presentation/views/saved_maps_screen.dart';
import 'package:flutter_map_toy/services/get_it.dart';
import 'package:flutter_map_toy/services/location_service.dart';


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

            PrimaryButton('New map',
              onPressed: () async {
                //TODO navigation issue - saved list many times in stack
                BlocProvider.of<MapCubit>(context).cleanState();
                MapScreen.push(context, await getIt.get<LocationService>().getMyInitialCameraPosition());
              }
            ),

            AppStyle.verticalDefaultDistance,
            BlueButton('blue button',
              onPressed: () {
                Navigator.pushNamed(context, SavedMapsScreen.id);
              },
            ),

            AppStyle.verticalDefaultDistance,
            RedButton('wizard test', onPressed: () {
              MapModel.test();
            },)

          ],
        ),
      ),
    );
  }

}