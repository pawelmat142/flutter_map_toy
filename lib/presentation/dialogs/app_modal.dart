import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';

class AppModal extends StatelessWidget {

  static Future<T?> show<T>(BuildContext context, {
    required List<Widget> children,
    VoidCallback? onBack,
    bool showBack = true,
    AppBar? appBar,
  }) async {
    return showModalBottomSheet<T>(context: context,
        backgroundColor: Colors.transparent,
        isScrollControlled: true,
        builder: (ctx) => AppModal(onBack: onBack, showBack: showBack, appBar: appBar, children: children,)
    );
  }

  final List<Widget> children;
  final VoidCallback? onBack;
  final bool showBack;
  final AppBar? appBar;

  const AppModal({
    required this.children,
    this.onBack,
    required this.showBack,
    this.appBar,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Stack(

        children: [

          Container(
            width: MediaQuery.of(context).size.width,
            padding: const EdgeInsets.fromLTRB(AppStyle.defaultPaddingVal, 0, AppStyle.defaultPaddingVal, AppStyle.defaultPaddingVal),
            decoration: const BoxDecoration(
                color: AppColor.primaryDark,
                borderRadius: BorderRadius.vertical(top: AppStyle.defaultRadius),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Container(
                    height: 6,
                    width: 80,
                    decoration: const BoxDecoration(
                        color: Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(6))
                    ),
                  ),
                ),
                ...children
              ],
            ),
          ),

          showBack ? SizedBox(
            height: 50,
            child: IconButton(onPressed: () {
              Navigator.pop(context);
              if (onBack != null) {
                onBack!();
              }
            }, icon: const Icon(Icons.arrow_back, color: Colors.white,)
            ),
          ) : const SizedBox.shrink(),

        ],
      ),
    );
  }
}
