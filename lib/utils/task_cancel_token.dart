import 'package:dio/dio.dart' as Dio show CancelToken, DioError;

class TaskCancelToken {
  /// dio cancel token
  final Dio.CancelToken net;

  TaskCancelToken() :
        net = Dio.CancelToken();

  void cancel([String msg]) {
    net.cancel(msg);
  }

  static bool isCancel(e) {
    if (e is Dio.DioError) {
      return Dio.CancelToken.isCancel(e);
    } else {
      return false;
    }
  }
}
