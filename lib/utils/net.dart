import 'package:dio/dio.dart';
import 'package:reader/config/net_config.dart';

export 'package:dio/dio.dart';

class Net extends Dio {
  Net([BaseOptions options]) : super(options) {
    this.interceptors.addAll(NetConfig.interceptors);
  }
}

Net net = Net(NetConfig.options);
