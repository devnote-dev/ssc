import 'package:args/command_runner.dart';

import '../compiler/lexer.dart';

final class CompileCommand extends Command<int> {
  @override
  final name = 'compile';

  @override
  final description = 'Compiles a Scratch Script';

  @override
  int run() {
    if (argResults!.arguments.isEmpty) {
      print('No arguments provided.');
      return 1;
    }

    // print(argResults!.arguments);
    final lexer = Lexer(argResults!.arguments.join(' '));
    print(lexer.lex());

    return 0;
  }
}
