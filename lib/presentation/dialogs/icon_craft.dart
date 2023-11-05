import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/global/wizard/wizard_state.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_icon.dart';
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

  double get displayFactor => rescaled ? IconCraft.iconCraftDisplayFactor : 1;

  final IconCraft craft;
  final bool rescaled;

  const IconCraftWidget(
      this.craft,
      this.rescaled,
      {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    final double size = craft.size! * displayFactor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Icon(AppIcon.marker,
            size: size,
            color: craft.color!.darken(.2),
          ),
          Icon(AppIcon.marker,
            size: size*0.95,
            color: craft.color!,
          ),

          Padding(
            padding: EdgeInsets.only(bottom: size*0.2),
            child: Container(
              color: craft.color!,
              child: Icon(craft.iconData!,
                size: size*0.4,
                color: AppColor.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}

