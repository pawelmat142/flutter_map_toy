import 'dart:async';
import 'dart:ui';

class TimerHandler {

  Timer? timer;

  late Duration duration;

  TimerHandler({required int milliseconds}) {
    duration = Duration(milliseconds: milliseconds);
  }

  handle(VoidCallback callback) {
    if (timer != null && timer!.isActive) {
      timer!.cancel();
    }
    timer = Timer(duration, callback);
  }

}