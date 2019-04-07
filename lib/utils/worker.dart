import 'package:worker2/worker2.dart';
import 'package:reader/config.dart';

export 'package:worker2/worker2.dart';

Worker taskWorker = Worker(poolSize: Config.taskWorkerNum, spawnLazily: true);

class AnonymousTask implements Task {
  Function call;
  List positionalArguments;
  Map<Symbol, dynamic> namedArguments;

  AnonymousTask(this.call, {this.positionalArguments, this.namedArguments});
  execute() => Function.apply(call, positionalArguments, namedArguments);
}
