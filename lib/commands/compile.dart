import 'package:args/command_runner.dart';

final class CompileCommand extends Command<int> {
  @override
  final name = 'compile';

  @override
  final description = 'Compiles a Scratch Script';

  @override
  int run() => 0;
}
