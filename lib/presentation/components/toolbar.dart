import 'package:flutter/material.dart';
import 'package:flutter_map_toy/global/extensions.dart';
import 'package:flutter_map_toy/presentation/dialogs/app_modal.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';

class ToolBarItem {
  ToolBarItem({
    required this.label,
    this.barLabel,
    this.menuLabel,
    required this.icon,
    this.disabled = false,
    required this.onTap,
    this.color = Colors.white,
  });
  String label;
  String? barLabel;
  String? menuLabel;
  IconData icon;
  bool disabled;
  VoidCallback onTap;
  Color color;
}

class Toolbar extends StatelessWidget {

  static const String menuLabel = 'menu';

  final List<ToolBarItem> toolbarItems;
  final List<ToolBarItem>? menuItems;

  const Toolbar({
    required this.toolbarItems,
    this.menuItems,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      elevation: 10,
      backgroundColor: AppColor.primaryDark,
      selectedItemColor: AppColor.white,
      unselectedItemColor: AppColor.white80,
      selectedLabelStyle: AppStyle.listTileSubtitle,
      unselectedLabelStyle: AppStyle.listTileSubtitle,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: (i) => _onItemTap(i, context),
      items: onlyToolbarItems.map((i) => BottomNavigationBarItem(
        icon: Icon(i.icon,
          color: i.disabled ? AppColor.primary : i.color),
          label: i.barLabel!.capitalize(),
      )).toList(),
    );
  }

  _onItemTap(int i, BuildContext context) {
    final item = onlyToolbarItems[i];
    if (item.label == menuLabel) {
      _onToolbarMenu(context);
    } else {
      final ToolBarItem tappedItem = onlyToolbarItems[i];
      if (tappedItem.disabled) return;
      tappedItem.onTap();
    }
  }

  List<ToolBarItem> get onlyToolbarItems => toolbarItems
      .where((item) => item.barLabel != null)
      .toList();

  _onToolbarMenu(BuildContext context) {
    AppModal.show(context, showBack: false, children: menuItems
        ?.map((i) => _toolbarItemToTile(i, context))
        .toList() ?? []);
  }

  ListTile _toolbarItemToTile(ToolBarItem item, BuildContext context) {
    return ListTile(
        title: Text(item.menuLabel!.capitalize(),
          style: AppStyle.listTileTitle.copyWith(color: AppColor.white)
        ),
        leading: Icon(item.icon, size: 32, color: AppColor.secondary),
        onTap: () {
          Navigator.pop(context);
          item.onTap();
        });
  }
}
