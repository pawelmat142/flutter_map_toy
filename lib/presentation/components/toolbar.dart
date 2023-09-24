import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/styles/app_color.dart';

class ToolBarItem {
  ToolBarItem({
    required this.label,
    this.barLabel,
    this.menuLabel,
    required this.icon,
    required this.onTap
  });
  String label;
  String? barLabel;
  String? menuLabel;
  IconData icon;
  VoidCallback onTap;
}

class Toolbar extends StatelessWidget {

  static const String menuLabel = 'menu';

  final List<ToolBarItem> toolbarItems;

  const Toolbar({
    required this.toolbarItems,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: onlyToolbarItems.indexWhere((toolbarItem) => toolbarItem.label == menuLabel),
      elevation: 10,
      backgroundColor: AppColor.primaryDark,
      selectedItemColor: AppColor.secondary,
      unselectedItemColor: AppColor.white80,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed,
      onTap: (i) => _onItemTap(i, context),
      items: onlyToolbarItems
          .map((i) => BottomNavigationBarItem(
          icon: Icon(i.icon),
          label: i.barLabel!))
          .toList(),
    );
  }

  _onItemTap(int i, BuildContext context) {
    final item = onlyToolbarItems[i];
    if (item.label == menuLabel) {
      _onToolbarMenu(context);
    } else {
      onlyToolbarItems[i].onTap();
    }
  }

  List<ToolBarItem> get onlyToolbarItems => toolbarItems
      .where((item) => item.barLabel != null)
      .toList();

  _onToolbarMenu(BuildContext context) {
    print('todo');
    // FlareModal.show(context, showBack: false, children: toolbarItems
    //     .where((i) => i.menuKey != null)
    //     .map((i) => _toolbarItemToTile(i, context))
    //     .toList());
  }

  ListTile _toolbarItemToTile(ToolBarItem item, BuildContext context) {
    return ListTile(title: Text(item.menuLabel!),
        leading: Icon(item.icon, size: 35, color: AppColor.green),
        onTap: () {
          Navigator.pop(context);
          item.onTap();
        });
  }
}
