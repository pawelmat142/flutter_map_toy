abstract class Time {

  static Future<void> wait(int ms) {
    return Future.delayed(Duration(milliseconds: ms));
  }

}