import 'package:dio/dio.dart' as Dio show CancelToken, DioError;

class TaskCancelToken {
  /// dio cancel token
  final Dio.CancelToken http = Dio.CancelToken();

  void cancel([String msg]) {
    http.cancel(msg);
  }

  static bool isCancel(e) {
    if (e is Dio.DioError) {
      return Dio.CancelToken.isCancel(e);
    } else {
      return false;
    }
  }
}
