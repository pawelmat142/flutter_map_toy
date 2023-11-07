import 'package:flutter/material.dart';
import 'package:flutter_map_toy/global/extensions.dart';

class Spinner extends StatelessWidget {

  static const String id = 'spinner';

  static bool get on => Navi.inStack(id);

  static show(BuildContext context) {
    if (!on) {
      Navigator.pushNamed(context, id);
    }
  }

  static pop(BuildContext context) {
    if (on) {
      Navi.remove(context, id);
    }
  }

  const Spinner({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
