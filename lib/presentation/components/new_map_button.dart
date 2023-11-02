import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/models/map_cubit.dart';
import 'package:flutter_map_toy/presentation/components/controls/primary_button.dart';
import 'package:flutter_map_toy/presentation/views/home_screen.dart';
import 'package:flutter_map_toy/presentation/views/map_screen/map_screen.dart';
import 'package:flutter_map_toy/services/get_it.dart';
import 'package:flutter_map_toy/services/location_service.dart';

class NewMapButton extends StatelessWidget {
  const NewMapButton({Key? key}) : super(key: key);
  //TODO spinner
  @override
  Widget build(BuildContext context) {
    return PrimaryButton('New map', onPressed: () {
      final mapCubit = BlocProvider.of<MapCubit>(context);
      getIt.get<LocationService>().getMyInitialCameraPosition().then((position) {
        mapCubit.emitNewMapState(position);
        Navigator.pushNamedAndRemoveUntil(context,
            MapScreen.id,
            ModalRoute.withName(HomeScreen.id)
        );
      });
    });
  }
}
