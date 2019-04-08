import 'package:flutter/material.dart';
import 'package:reader/utils/task_cancel_token.dart';

mixin TaskCancelTokenProviderStateMixin<T extends StatefulWidget> on State<T> {
  TaskCancelToken _cancelToken;
  TaskCancelToken get cancelToken => _cancelToken;

  @override
  void initState() {
    _cancelToken = TaskCancelToken();
    super.initState();
  }

  @override
  void dispose() {
    _cancelToken.cancel();
    super.dispose();
  }
}
