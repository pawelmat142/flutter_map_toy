import 'package:flutter/material.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/models/map_model.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:hive_flutter/hive_flutter.dart';

class SavedMapsScreen extends StatelessWidget {

  static const String id = 'saved_maps_screen';

  const SavedMapsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('saved maps'),),

      body: ValueListenableBuilder(
        valueListenable: MapModel.hiveBox.listenable(),
        builder: (context, box, widget) {
          final boxLength = box.keys.length;
          return ListView.separated(
              itemBuilder: (ctx, index) {
                var mapModel = box.getAt(index);

                return mapModel == null ? const SizedBox.shrink() : ListTile(
                  title: Text(mapModel.name),
                  subtitle: Text(mapModel.modified?.format ?? ''),
                  onLongPress: () {
                    mapModel.delete();
                  },
                );
              },
              separatorBuilder: (ctx, index) {
                return const Divider(height: 1, color: AppColor.primaryDark,);
              },
              itemCount: boxLength
          );
        },
      ),
    );
  }
}
