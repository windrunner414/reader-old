import 'package:dio/dio.dart';
import 'package:reader/config.dart';

export 'package:dio/dio.dart';

class Net extends Dio {
  Net([BaseOptions options]) : super(options);
}

Net net = Net(Config.netOptions);
