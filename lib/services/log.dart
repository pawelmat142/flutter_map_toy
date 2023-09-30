import 'package:flutter/foundation.dart';

abstract class Log {

  static log(String log, { String? source }) {
    if (kDebugMode) {
      print('[${DateTime.now().toString()}] ${source == null ? '' : '[$source] '}$log');
    }
  }

  static error(String log, { String? source }) {
    if (kDebugMode) {
      print('[${DateTime.now().toString()}] [ERROR] ${source == null ? '' : '[$source] '}$log');
    }
  }

  static warn(String log, { String? source }) {
    if (kDebugMode) {
      print('[${DateTime.now().toString()}] [WARN] ${source == null ? '' : '[$source] '}$log');
    }
  }

}