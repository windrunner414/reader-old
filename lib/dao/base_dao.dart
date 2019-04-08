import 'package:reader/utils/task_cancel_token.dart';

class BaseDao {
  final TaskCancelToken cancelToken;

  BaseDao({this.cancelToken});
}
