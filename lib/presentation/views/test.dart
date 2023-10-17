import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/components/drawing/drawing_widget.dart';

class Test extends StatelessWidget {

  static const String id = 'test';

  const Test({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar: AppBar(title: const Text('test'),),

      body: const DrawingWidget()
    );
  }
}