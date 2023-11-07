import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';

class NoResults extends StatelessWidget {
  const NoResults({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppStyle.defaultPaddingVal),
        child: Center(child: Text('No results', style: AppStyle.midWhite30)
        )
    );
  }
}
