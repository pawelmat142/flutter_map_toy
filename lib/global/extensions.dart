import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:navigation_history_observer/navigation_history_observer.dart';

extension StringExtension on String {

  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

extension LatLngExtension on LatLng {

  List<double> get coordinates => [ longitude, latitude ];
}

extension DateTimeExtension on DateTime {

  static final formatter = DateFormat('kk:mm dd-MM-yyyy');

  String get format => formatter.format(this);
}

extension ColorExtension on Color {

  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }
}

extension Navi on Navigator {

  static GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  static Iterable<Route<dynamic>> get routes => NavigationHistoryObserver().history;
  static Iterable<String?> get path => routes.map((Route route) => route.settings.name);

  static bool inStack(String screenId) => routes.any((Route route) => route.settings.name == screenId);

  static remove(BuildContext context, String screenId) {
    Navigator.pop(context, (Route route) => route.settings.name == screenId);
  }

}