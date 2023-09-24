import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';

class IconTile extends StatelessWidget {

  final VoidCallback? onLongPress;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double size;
  final bool active;
  final Color? color;

  const IconTile({Key? key,
    this.onLongPress,
    this.onPressed,
    this.icon,
    this.size = 60,
    this.active = false,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
      width: size,
      child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.primary,
            // shape: RoundedRectangleBorder(
            //   borderRadius: BorderRadius.circular(AppStyle.defaultRadiusVal)
            // )
          ),
          child: icon == null ? null : Icon(icon,
            size: size/1.7,
            color: color,
          )
      ),
    );
  }
}