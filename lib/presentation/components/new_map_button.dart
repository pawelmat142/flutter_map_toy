import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/models/map_cubit.dart';
import 'package:flutter_map_toy/presentation/components/controls/primary_button.dart';
import 'package:flutter_map_toy/presentation/views/home_screen.dart';
import 'package:flutter_map_toy/presentation/views/map_screen/map_screen.dart';

class NewMapButton extends StatelessWidget {
  const NewMapButton({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return PrimaryButton('New map', onPressed: () {
      BlocProvider.of<MapCubit>(context).dispose(context);
      Navigator.pushNamedAndRemoveUntil(context,
          MapScreen.id,
          ModalRoute.withName(HomeScreen.id)
      );
    });
  }
}
