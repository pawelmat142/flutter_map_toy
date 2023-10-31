import 'package:flutter/material.dart';

class MarkerInfo {
  String name;
  String? description;

  MarkerInfo(this.name);

  String getDescription() {
    return description == null || description!.isEmpty ? '' : description!;
  }

  static Future<MarkerInfo?> dialog(BuildContext context) async {
    final doAddName = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Add drawing name?'),
      actions: [
        TextButton(child: const Text('No'),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(child: const Text('Yes'),
          onPressed: () => Navigator.pop(context, true),
        )
      ],
    ));

    if (doAddName == true) {
      String nameValue = '';

      final name = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
        title: const Text('Enter the name'),
        content: TextField(
          autofocus: true,
          onChanged: (value) => nameValue = value,
        ),
        actions: [
          TextButton(child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(child: const Text('OK'),
            onPressed: () => Navigator.pop(context, nameValue),
          ),
        ],
      ));

      if (name is String && name.isNotEmpty) {

        final doAddDescription = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
          title: const Text('Add description?'),
          actions: [
            TextButton(child: const Text('No'),
              onPressed: () => Navigator.pop(context),
            ),
            TextButton(child: const Text('Yes'),
              onPressed: () => Navigator.pop(context, true),
            )
          ],
        ));

        if (doAddDescription == true) {

          String descriptionValue = '';
          final description = await showDialog<String>(context: context, builder: (ctx) => AlertDialog(
            title: const Text('Enter the description.'),
            content: TextField(
              autofocus: true,
              onChanged: (value) => descriptionValue = value,
            ),
            actions: [
              TextButton(child: const Text('Cancel'),
                onPressed: () => Navigator.pop(context),
              ),
              TextButton(child: const Text('OK'),
                onPressed: () => Navigator.pop(context, descriptionValue),
              ),
            ],
          ));

          if (description is String && description.isNotEmpty) {
            return MarkerInfo(name)
              ..description = description;
          }
        } else {
          return MarkerInfo(name);
        }
      }
    }
    return null;
  }
}