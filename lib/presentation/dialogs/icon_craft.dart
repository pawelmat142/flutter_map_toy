import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/presentation/dialogs/wizard/wizard_state.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:uuid/uuid.dart';

class IconCraft {

  static const double maxSize = 100;
  static const double minSize = 20;

  static const double defaultSize = 70;
  static const IconData defaultIcon = Icons.question_mark_rounded;
  static const Color defaultIconColor = AppColor.white30;

  IconData? iconData;
  Color? color;
  double? size;
  String? id;

  bool get complete => dialogComplete && id is String;

  bool get incomplete => !complete;

  bool get dialogComplete {
    return iconData is IconData && color is Color && size is double;
  }

  validate() {
    if (incomplete) throw 'craft is incomplete!';
  }

  static IconCraft byWizardBlocState(BuildContext context) {
    final craft = IconCraft();
    final state = BlocProvider.of<WizardCubit>(context).state;
    craft.iconData = state.steps[0].stepData ?? defaultIcon;
    craft.color = state.steps[1].stepData ?? defaultIconColor;
    craft.size = state.steps[2].stepData ?? defaultSize;
    craft.id = const Uuid().v1();
    return craft;
  }

  StatelessWidget get widget => IconCraftWidget(this);
}

class IconCraftWidget extends StatelessWidget {

  final IconCraft craft;

  const IconCraftWidget(this.craft,
      {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final radius = craft.size!*0.2;
    final iconSize = craft.size!*0.8;

    return Container(
      width: craft.size,
      height: craft.size,
      decoration: BoxDecoration(
          color: craft.color!.withAlpha(50),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
              color: craft.color!,
              width: craft.size!*0.05
          )
      ),
      child: Center(
        child: Icon(craft.iconData, size: iconSize, color: craft.color,),
      ),
    );
  }
}