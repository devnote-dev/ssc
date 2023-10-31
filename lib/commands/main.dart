import 'package:args/args.dart';
import 'package:args/command_runner.dart';

class MainCommand extends CommandRunner<int> {
  MainCommand() : super('ssc', 'Scratch Script Compiler');

  @override
  Future<int> runCommand(ArgResults topLevelResults) async {
    return await super.runCommand(topLevelResults) ?? 0;
  }
}
