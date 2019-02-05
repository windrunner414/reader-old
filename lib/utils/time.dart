class Time {
  static String twoDigits(int n) => n < 10 ? "0$n" : "$n";
  static String get hourMinute {
    DateTime now = DateTime.now();
    return "${twoDigits(now.hour)}:${twoDigits(now.minute)}";
  }
}