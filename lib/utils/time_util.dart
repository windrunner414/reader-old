class TimeUtil {
  static String _twoDigits(int n) => n < 10 ? "0$n" : "$n";

  static String get hourMinute {
    DateTime now = DateTime.now();
    return '${_twoDigits(now.hour)}:${_twoDigits(now.minute)}';
  }

  static int get now => DateTime.now().millisecondsSinceEpoch;

  static String toYmdHis(int millisecondsSinceEpoch) {
    DateTime time = DateTime.fromMillisecondsSinceEpoch(millisecondsSinceEpoch);
    return '${time.year}-${_twoDigits(time.month)}-${_twoDigits(time.day)} '
      + '${_twoDigits(time.hour)}:${_twoDigits(time.minute)}:${_twoDigits(time.second)}';
  }
}