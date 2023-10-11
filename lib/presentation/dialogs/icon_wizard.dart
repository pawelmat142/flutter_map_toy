import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/components/controls/primary_button.dart';
import 'package:flutter_map_toy/presentation/components/icon_tile.dart';
import 'package:flutter_map_toy/presentation/dialogs/icon_craft.dart';
import 'package:flutter_map_toy/presentation/dialogs/modal_steps_wizard.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_icon.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';

class IconWizard extends ModalStepsWizard<IconCraft> {

  IconWizard({required super.wizardContext});

  IconCraft craft = IconCraft();

  @override
  bool get complete => craft.complete;

  @override
  initSteps() {
    final tileSize = _getModalTileSize(wizardContext);
    super.steps = [

      WizardStep<IconData>(craft.iconData,
        label: 'one',
        parentWizard: this,
        builder: (ctx) => Wrap(
          spacing: AppStyle.wrapSpacing,
          runSpacing: AppStyle.wrapSpacing,
          children: AppIcon.mapFlutterIcons.asMap().map((index, icon) => MapEntry(index, IconTile(
            icon: icon,
            onPressed: () => Navigator.pop(ctx, AppIcon.mapFlutterIcons[index]),
            size: tileSize,
            color: craft.color,
          ))).values.toList()
        ),
        onSuccess: (result) {
          craft.iconData = result;
          ppprint();
        }
      ),

      WizardStep<Color>(craft.color,
        label: 'two',
        parentWizard: this,
        builder: (ctx) => Wrap(
          spacing: AppStyle.wrapSpacing,
          runSpacing: AppStyle.wrapSpacing,
          children: AppColor.mapFlutterIconColors
              .asMap()
              .map((index, color) => MapEntry(
                  index,
                  IconTile(
                    icon: craft.iconData,
                    onPressed: () => Navigator.pop(
                        ctx, AppColor.mapFlutterIconColors[index]),
                    size: IconWizard._getModalTileSize(ctx),
                    color: color,
                  )))
              .values
            .toList()
        ),
        onSuccess: (result) {
          craft.color = result;
          ppprint();
        },
      ),

      WizardStep<double>(craft.size,
          label: 'three',
          parentWizard: this,
          builder: (ctx) => IconWizardSizeStep(craft: craft),
          onSuccess: (result) {
            craft.size = result;
            ppprint();
          }
      ),
    ];
  }

  ppprint() {
    print('craft.size');
    print(craft.size);
    print('craft.color');
    print(craft.color);
    print('craft.iconData');
    print(craft.iconData);
  }

  static _getModalTileSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    const itemsPerRow = 4;
    return (screenWidth - itemsPerRow*AppStyle.wrapSpacing - 2*AppStyle.defaultPaddingVal) / itemsPerRow;
  }

}
class IconWizardSizeStep extends StatefulWidget {
  final IconCraft craft;

  const IconWizardSizeStep({
    required this.craft,
    Key? key}) : super(key: key);

  @override
  State<IconWizardSizeStep> createState() => _IconWizardSizeStepState();
}

class _IconWizardSizeStepState extends State<IconWizardSizeStep> {

  static const double initialSize = 70;
  static const double maxSize = 100;
  static const double minSize = 40;

  static const IconData defaultIcon = Icons.question_mark_rounded;
  static const Color defaultIconColor = AppColor.white30;

  double get size => widget.craft.size ?? initialSize;
  IconData get iconData => widget.craft.iconData ?? defaultIcon;
  Color get color => widget.craft.color ?? defaultIconColor;

  late double _size;

  @override
  void initState() {
    _size = size;
    super.initState();
  }

  _setSize(double value) {
    setState(() {
      _size = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        Navigator.pop(context, _size);
        return false;
      },
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            SizedBox(
              width: 100,
              height: 100,
              child: Center(
                child: Icon(iconData,
                  color: color,
                  size: _size,
                ),
              ),
            ),
            AppStyle.verticalDefaultDistance,

            Slider(
              value: _size,
              onChanged: _setSize,
              min: minSize,
              max: maxSize,
            ),
            AppStyle.verticalDefaultDistance,

            SizedBox(
                height: 48,
                width: MediaQuery.of(context).size.width,
                child: PrimaryButton('submit',
                  onPressed: () => Navigator.pop(context, _size),
                )
            ),
          ]),
    );
  }
}


