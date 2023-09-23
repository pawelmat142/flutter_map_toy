import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/components/controls/primary_button.dart';
import 'package:flutter_map_toy/presentation/components/controls/secondary_button.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';
import 'package:flutter_map_toy/presentation/views/map_screen.dart';

class HomeScreen extends StatelessWidget {
  static const String id = 'home_screen';

  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('Home'),),

      body: Padding(
        padding: AppStyle.defaultPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [

            PrimaryButton('go to map',
              onPressed: () => Navigator.pushNamed(context, MapScreen.id),
            ),

            AppStyle.verticalDefaultDistance,
            SecondaryButton('secondary button',
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
