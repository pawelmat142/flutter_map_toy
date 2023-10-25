import 'package:flutter/material.dart';

class MapNamePopup extends StatelessWidget {

  static Future<String?> show(BuildContext context) {
    return showDialog(context: context, builder: (ctx) {
      return const MapNamePopup();
    });
  }

  //TODO style popup

  const MapNamePopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    String? value;

    return AlertDialog(
      title: const Text('Please provide map name'),

      content: TextField(
        autofocus: true,
        onChanged: (v) => value = v,
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel')
        ),
        TextButton(
          child: const Text('OK'),
          onPressed: () => Navigator.pop(context, value),
        )
      ],
    );
  }
}
