import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/dialogs/popups/app_popup.dart';

class TextInputPopup extends AppPopup<String> {

  TextInputPopup(super.ctx);

  TextEditingController controller = TextEditingController();

  TextInputPopup text(String? txt) {
    controller.text = txt ?? '';
    return this;
  }

  @override
  TextInputPopup content(String content) {
    throw 'content cannot be used for TextInputPopup';
  }

  @override
  Widget getContentWidget() {
    return TextField(
      controller: controller,
      autofocus: true,
    );
  }

  @override
  String? get returnedValue {
    return controller.text;
  }

}