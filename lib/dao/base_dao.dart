import 'package:reader/utils/task_cancel_token.dart';
import 'package:flutter/material.dart' show mustCallSuper, required;

class BaseDao {
  final TaskCancelToken cancelToken;

  @mustCallSuper
  BaseDao({@required this.cancelToken});
}
