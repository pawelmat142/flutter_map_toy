import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/components/controls/primary_button.dart';
import 'package:flutter_map_toy/presentation/components/icon_tile.dart';
import 'package:flutter_map_toy/presentation/dialogs/app_modal.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_icon.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';
import 'package:flutter_map_toy/services/log.dart';

class IconCraft {

  IconData? iconData;
  Color? color;
  double? size;
  String? id;

  bool get complete => dialogComplete && id is String;

  bool get incomplete => !complete;

  bool get dialogComplete {
    return iconData is IconData && color is Color && size is double;
  }

  Future create(BuildContext context) async {
    await _setIconData(context);
    _generateId();
    Log.log('creator finished, craft is ${complete ? 'complete' : 'UNCOMPLETED'}', source: runtimeType.toString());
  }

  startEditDialog(BuildContext context) async {
    if (!dialogComplete) throw 'craft incomplete!';
    await _setIconSize(context);
  }

  _setIconData(BuildContext context) async {
    final tileSize = _getModalTileSize(context);
    final result = await AppModal.show(context,
        children: [Wrap(
        spacing: AppStyle.wrapSpacing,
        runSpacing: AppStyle.wrapSpacing,
        children: AppIcon.mapFlutterIcons.asMap().map((index, icon) => MapEntry(index, IconTile(
            icon: icon,
            onPressed: () => Navigator.pop(context, AppIcon.mapFlutterIcons[index]),
            size: tileSize,
            color: color,
          ))).values.toList()
      )]);

    if (result is IconData) {
      iconData = result;
      // ignore: use_build_context_synchronously
      await _setIconColor(context);
    }
  }

  _setIconColor(BuildContext context) async {
    var isBacked = false;
    final tileSize = _getModalTileSize(context);
    final result = await AppModal.show(context,
      onBack: () => isBacked = true,
      children: [Wrap(
        spacing: AppStyle.wrapSpacing,
        runSpacing: AppStyle.wrapSpacing,
        children: AppColor.mapFlutterIconColors.asMap().map((index, color) => MapEntry(index, IconTile(
          icon: iconData,
          color: color,
          onPressed: () => Navigator.pop(context, AppColor.mapFlutterIconColors[index]),
          size: tileSize,
        ))).values.toList()
      )]);
    if (result is Color) {
      color = result;
      // ignore: use_build_context_synchronously
      await _setIconSize(context);
    }
    if (isBacked) {
      // ignore: use_build_context_synchronously
      await _setIconData(context);
    }
  }

  _setIconSize(BuildContext context) async {
    var isBacked = false;
    final result = await AppModal.show(context,
        onBack: () => isBacked = true,
        children: [IconCraftSizeDialogContent(craft: this)]);
    if (result is double) {
      size = result;
    }
    if (isBacked) {
      // ignore: use_build_context_synchronously
      await _setIconColor(context);
    }
  }

  static _getModalTileSize(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenWidth = size.width;
    const itemsPerRow = 4;
    return (screenWidth - itemsPerRow*AppStyle.wrapSpacing - 2*AppStyle.defaultPaddingVal) / itemsPerRow;
  }

  _generateId() {
    final rng = Random();
    final result = '${rng.nextInt(1000).toString()}_${color.hashCode.toString()}';
    Log.log('Generated EventMapPointIconId: $result', source: runtimeType.toString());
    id = result;
  }

}

class IconCraftSizeDialogContent extends StatefulWidget {

  final IconCraft craft;

  const IconCraftSizeDialogContent({
    required this.craft,
    Key? key}) : super(key: key);

  @override
  State<IconCraftSizeDialogContent> createState() => _IconCraftSizeDialogContentState();
}

class _IconCraftSizeDialogContentState extends State<IconCraftSizeDialogContent> {

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

  @override
  void dispose() {
    widget.craft.size = _size;
    super.dispose();
  }

  _setSize(double value) {
    setState(() {
      _size = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
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
        ]);
  }
}
