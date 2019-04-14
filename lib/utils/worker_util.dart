import 'package:worker2/worker2.dart';
import 'package:reader/config/worker_config.dart';

class WorkerUtil {
  WorkerUtil._();

  static final Worker taskWorker = Worker(
    poolSize: WorkerConfig.taskWorkerNum,
    spawnLazily: WorkerConfig.taskWorkerSpawnLazily,
  );

  static Future<T> run<T>(Function call, {
    List positionalArguments,
    Map<Symbol, dynamic> namedArguments,
  }) async {
    return await taskWorker.handle(_AnonymousTask(
      call,
      positionalArguments: positionalArguments,
      namedArguments: namedArguments,
    ));
  }
}

class _AnonymousTask implements Task {
  Function call;
  List positionalArguments;
  Map<Symbol, dynamic> namedArguments;

  _AnonymousTask(this.call, {this.positionalArguments, this.namedArguments});

  execute() => Function.apply(call, positionalArguments, namedArguments);
}
