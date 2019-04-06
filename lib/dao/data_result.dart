import 'package:reader/utils/net.dart';

class DataResult<T> {
  final T data;
  final bool success;
  final String errMsg;

  DataResult({this.data, this.success, this.errMsg}) : assert(success != null);
}

Future<DataResult> performNetTask(Task task) async {
  try {
    return await netWorker.handle(task);
  } catch (_) {
    return DataResult(success: false, errMsg: '加载失败');
  }
}
