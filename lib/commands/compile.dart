import 'dart:io';

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
      print('Missing file argument.');
      return 1;
    }

    final source = File(argResults!.arguments.first);
    if (!source.existsSync()) {
      print('File not found: ${source.path}');
      return 1;
    }

    // print(argResults!.arguments);
    final lexer = Lexer(source.readAsStringSync());
    final tokens = lexer.lex();
    // print(tokens);

    final parser = Parser(tokens);
    final program = parser.parse();

    Visitor(program).visit();
    program.statements.forEach(print);

    return 0;
  }
}
