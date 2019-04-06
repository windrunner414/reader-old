import 'package:flutter/material.dart';
import 'package:reader/utils/net.dart';

abstract class StateWithNetManager<T extends StatefulWidget> extends State<T> {
  CancelToken _cancelToken;
  CancelToken get cancelToken => _cancelToken;

  @override
  void initState() {
    super.initState();
    _cancelToken = CancelToken();
  }

  @override
  void dispose() {
    super.dispose();
    _cancelToken.cancel();
  }
}
