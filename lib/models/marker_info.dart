import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerInfo {
  String name;
  String? description;

  MarkerInfo(this.name);

  String getDescription() {
    return description == null || description!.isEmpty ? '' : description!;
  }

  static Future<MarkerInfo?> dialog(BuildContext context, Marker marker) async {
    MarkerInfo? result;
    final infoWindow = marker.infoWindow;

    final nameController = TextEditingController(text: infoWindow.title);
    final name = await showDialog<String>(context: context, builder: (ctx) =>
        AlertDialog(
          title: const Text('Enter the name'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Tap OK to set description'),
              TextField(
                autofocus: true,
                controller: nameController,
              ),
            ],
          ),
          actions: [
            TextButton(child: const Text('Cancel'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(child: const Text('OK'),
              onPressed: () => Navigator.pop(context, nameController.text),
            ),
          ],
        ));

    if (name is String && name.isNotEmpty) {
      result = MarkerInfo(name);

      final descriptionController = TextEditingController(text: infoWindow.snippet);
      final description = await showDialog<String>(
          context: context, builder: (ctx) =>
          AlertDialog(
            title: const Text('Enter the description.'),
            content: TextField(
              autofocus: true,
              controller: descriptionController,
            ),
            actions: [
              TextButton(child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(child: const Text('OK'),
                onPressed: () => Navigator.pop(context, descriptionController.text),
              ),
            ],
          ));

      if (description is String && description.isNotEmpty) {
        result.description = description;
      }
    }
    return result;
  }

}