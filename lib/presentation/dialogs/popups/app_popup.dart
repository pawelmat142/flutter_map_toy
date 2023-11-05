import 'package:flutter/material.dart';
import 'package:flutter_map_toy/presentation/styles/app_style.dart';

class AppPopup<T> {

  AppPopup(this.ctx);

  final BuildContext ctx;

  String _title = 'Default title';

  String? _content;

  String _ok = 'OK';

  String? _cancel = 'Cancel';

  VoidCallback? _onOk;

  T? get returnedValue => null;

  AppPopup<T> title(String title) {
    _title = title;
    return this;
  }

  AppPopup<T> content(String content) {
    _content = content;
    return this;
  }

  Widget? getContentWidget() {
    return _content == null ? null : Text(_content!);
  }

  AppPopup<T> cancel(String? cancel) {
    _cancel = cancel;
    return this;
  }

  AppPopup<T> ok(String ok) {
    _ok = ok;
    return this;
  }

  Future<T?> onOk(VoidCallback callback) {
    _onOk = callback;
    return show();
  }

  Future<T?> show() {
    return showDialog<T>(context: ctx, builder: (ctx) {
      return AlertDialog(

        title: Text(_title),

        content: getContentWidget(),

        actions: [

          if (_cancel is String) DialogButton(_cancel!,
              onPressed: () => Navigator.pop(ctx),
          ),

          DialogButton(_ok,
              onPressed: () {
                if (_onOk != null) {
                  Navigator.pop(ctx);
                  _onOk!();
                } else {
                  Navigator.pop(ctx, returnedValue);
                }
              },
          )
        ],

      );
    });
  }

}

class DialogButton extends StatelessWidget {
  final String txt;
  final VoidCallback? onPressed;
  const DialogButton(this.txt, {
    this.onPressed,
    Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextButton(
        onPressed: onPressed,
        child: Text(txt, style: AppStyle.secondaryMedium,)
    );
  }
}
