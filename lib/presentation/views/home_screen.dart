import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/components/controls/blue_button.dart';
import 'package:flutter_map_toy/presentation/components/controls/red_button.dart';
import 'package:flutter_map_toy/presentation/components/new_map_button.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';
import 'package:flutter_map_toy/presentation/views/saved_maps_screen.dart';

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

            const NewMapButton(),
            AppStyle.verticalDefaultDistance,

            BlueButton('saved maps ', onPressed: () {
              //spinner
              Navigator.pushNamed(context, SavedMapsScreen.id);
            }),
            AppStyle.verticalDefaultDistance,

            RedButton('test', onPressed: () {
            },),
            AppStyle.verticalDefaultDistance,

          ],
        ),
      ),
    );
  }

}

