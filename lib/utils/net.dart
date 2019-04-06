import 'package:dio/dio.dart';
import 'package:worker2/worker2.dart';
import 'package:reader/config.dart';

export 'package:dio/dio.dart';
export 'package:worker2/worker2.dart';

class Net extends Dio {
  Net([BaseOptions options]) : super(options);
}

Net net = Net(Config.netOptions);
Worker netWorker = Worker(poolSize: Config.netIsolateNum, spawnLazily: true);
