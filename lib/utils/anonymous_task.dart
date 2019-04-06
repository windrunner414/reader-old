import 'package:worker2/worker2.dart';

class AnonymousTask implements Task {
  Function call;
  List positionalArguments;
  Map<Symbol, dynamic> namedArguments;

  AnonymousTask(this.call, {this.positionalArguments, this.namedArguments});
  execute() => Function.apply(call, positionalArguments, namedArguments);
}
