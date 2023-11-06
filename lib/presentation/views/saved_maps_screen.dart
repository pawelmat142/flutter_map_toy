import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/models/map_cubit.dart';
import 'package:flutter_map_toy/models/map_model.dart';
import 'package:flutter_map_toy/presentation/components/new_map_button.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';
import 'package:flutter_map_toy/presentation/views/map_screen/map_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SavedMapsScreen extends StatelessWidget {

  static const String id = 'saved_maps_screen';

  const SavedMapsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final mapCubit = BlocProvider.of<MapCubit>(context);

    return Scaffold(

      appBar: AppBar(title: const Text('saved maps'),),

      body: ValueListenableBuilder(
        valueListenable: MapModel.hiveBox.listenable(),
        builder: (context, box, widget) {

          final values = box.values.toList();
          values.sort((a, b) => b.modified.compareTo(a.modified));

          return ListView.separated(
              itemBuilder: (ctx, index) {
                var mapModel = values[index];

                return ListTile(
                  title: Text(mapModel.name, style: AppStyle.listTileTitle),
                  subtitle: Text(mapModel.modified.format),
                  onTap: () {
                    Navigator.pushNamed(context, MapScreen.id);
                    mapCubit.loadStateFromModel(context, mapModel);
                  },
                  onLongPress: () {
                    mapModel.delete();
                  },
                );
              },
              separatorBuilder: (ctx, index) {
                return const Divider(height: 1, color: AppColor.primaryDark,);
              },
              itemCount: box.keys.length
          );
        },
      ),

      bottomNavigationBar: const Padding(
        padding: EdgeInsets.symmetric(
          horizontal: AppStyle.defaultPaddingVal,
          vertical: AppStyle.defaultPaddingVal/4
        ),
        child: NewMapButton()
      )
    );
  }
}
