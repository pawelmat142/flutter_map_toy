import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/models/map_cubit.dart';
import 'package:flutter_map_toy/presentation/components/controls/blue_button.dart';
import 'package:flutter_map_toy/presentation/components/controls/red_button.dart';
import 'package:flutter_map_toy/presentation/components/new_map_button.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';
import 'package:flutter_map_toy/presentation/views/location_search/location_search_screen.dart';
import 'package:flutter_map_toy/presentation/views/map_screen/map_screen.dart';
import 'package:flutter_map_toy/presentation/views/saved_maps_screen.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeScreen extends StatelessWidget {
  static const String id = 'home_screen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      body: Padding(
        padding: AppStyle.defaultPadding,
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            Image.asset('assets/images/icon.png', scale: 2/3,),

            const NewMapButton(),
            AppStyle.verticalDefaultDistance,

            BlueButton('Saved maps ', onPressed: () {
              //spinner
              Navigator.pushNamed(context, SavedMapsScreen.id);
            }),
            AppStyle.verticalDefaultDistance,

            RedButton('find place', onPressed: () {
              Navigator.pushNamed(context, LocationSearchScreen.id).then((point) {
                if (point is LatLng) {
                  BlocProvider.of<MapCubit>(context).setInitialPosition(point: point).then((_) {
                    Navigator.pushNamed(context, MapScreen.id);
                  });
                }
              });
            },),

          ],
        ),
      ),
    );
  }

}

