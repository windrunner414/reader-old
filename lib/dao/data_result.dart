import 'package:reader/utils/worker_util.dart';
import 'package:reader/utils/net.dart' show Response;
import 'package:reader/utils/task_cancel_token.dart';

const DATABASE_QUERY_FAILED = DataResult(status: DataResultStatus.ERROR, msg: '数据库查询操作失败');
const DATABASE_UPDATE_FAILED = DataResult(status: DataResultStatus.ERROR, msg: '数据库更新操作失败');
const REQUEST_CANCELED = DataResult(status: DataResultStatus.CANCELED, msg: '请求已取消');
const REQUEST_FAILED = DataResult(status: DataResultStatus.ERROR, msg: '加载失败');
const OPERATION_SUCCESS = DataResult(status: DataResultStatus.SUCCESS);

enum DataResultStatus {
  SUCCESS,
  ERROR,
  CANCELED,
}

class DataResult<T> {
  final T data;
  final DataResultStatus status;
  final String msg;

  const DataResult({this.data, this.status, this.msg}) : assert(status != null);
}

Future<DataResult> requestAndParse({
  Future<Response> Function() request,
  Function(String) parse,
}) async {
  assert(request != null);
  assert(parse != null);

  try {
    Response response = await request();
    return DataResult(
      data: await WorkerUtil.run(parse, positionalArguments: [response.data]),
      status: DataResultStatus.SUCCESS,
    );
  } catch (e) {
    return TaskCancelToken.isCancel(e) ? REQUEST_CANCELED : REQUEST_FAILED;
  }
}
