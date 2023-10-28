import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/wizard/wizard_state.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:uuid/uuid.dart';

class IconCraft {

  static const double maxSize = 500;
  static const double minSize = 100;

  static const double iconCraftDisplayFactor = 0.2;

  static const double defaultSize = 200;
  static const IconData defaultIcon = Icons.question_mark_rounded;
  static const Color defaultIconColor = AppColor.white30;

  static double get iconDisplaySize => maxSize * iconCraftDisplayFactor;

  IconData? iconData;
  Color? color;
  double? size;
  String? id;

  IconCraft() {
    size = defaultSize;
  }

  bool get complete => dialogComplete && id is String;

  bool get incomplete => !complete;

  bool get dialogComplete {
    return iconData is IconData && color is Color && size is double;
  }

  validate() {
    if (incomplete) throw 'craft is incomplete!';
  }

  static IconCraft byWizardBlocState(BuildContext context) {
    final state = BlocProvider.of<WizardCubit>(context).state;
    return IconCraft()
      ..iconData = state.steps[0].stepData ?? defaultIcon
      ..color = state.steps[1].stepData ?? defaultIconColor
      ..size = state.steps[2].stepData ?? defaultSize
      ..id = const Uuid().v1();
  }

  StatelessWidget widget({ bool rescaled = false }) => IconCraftWidget(this, rescaled);
}

class IconCraftWidget extends StatelessWidget {

  final IconCraft craft;
  final bool rescaled;

  const IconCraftWidget(this.craft, this.rescaled,
      {Key? key}) : super(key: key);

  double get displayFactor => rescaled ? IconCraft.iconCraftDisplayFactor : 1;

  @override
  Widget build(BuildContext context) {

    final radius = craft.size!*0.2 * displayFactor;
    final iconSize = craft.size!*0.8 * displayFactor;

    final size = craft.size == null ? null : craft.size! * displayFactor;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
          color: craft.color!.withAlpha(50),
          borderRadius: BorderRadius.circular(radius),
          border: Border.all(
              color: craft.color!,
              width: size!*0.05
          )
      ),
      child: Center(
        child: Icon(craft.iconData, size: iconSize, color: craft.color,),
      ),
    );
  }
}