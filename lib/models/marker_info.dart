import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/dialogs/popups/text_input_popup.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MarkerInfo {
  String name;
  String? description;

  MarkerInfo(this.name);

  String getDescription() {
    return description == null || description!.isEmpty ? '' : description!;
  }

  static Future<MarkerInfo?> dialog(BuildContext context, Marker marker) {
    final infoWindow = marker.infoWindow;
    return TextInputPopup(context)
        .text(infoWindow.title?.trim())
        .title('Enter the name').show()
        .then((name) {
          if (name is String) {
            final markerInfo = MarkerInfo(name);
            return TextInputPopup(context)
                .text(infoWindow.snippet?.trim())
                .title('Enter the description').show()
                .then((description) {
                  return markerInfo
                    ..description = description is String
                      ? description
                      : infoWindow.snippet;
                });
          }
          return null;
        });
  }

}