import 'package:args/args.dart';
import 'package:args/command_runner.dart';

import 'compile.dart';

final class MainCommand extends CommandRunner<int> {
  MainCommand() : super('ssc', 'Scratch Script Compiler') {
    addCommand(CompileCommand());
  }

  @override
  Future<int> runCommand(ArgResults topLevelResults) async {
    return await super.runCommand(topLevelResults) ?? 0;
  }
}
