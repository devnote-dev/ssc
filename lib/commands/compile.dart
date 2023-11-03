import 'package:args/command_runner.dart';

import 'package:ssc/ssc.dart';

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
    final tokens = lexer.lex();
    print(tokens);

    final parser = Parser(tokens);
    final program = parser.parse();
    Visitor(program).visit();

    print(program.statements);

    return 0;
  }
}
