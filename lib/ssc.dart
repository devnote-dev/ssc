import 'commands/main.dart';

export 'compiler/semantic/visitor.dart';
export 'compiler/syntax/ast.dart';
export 'compiler/syntax/lexer.dart';
export 'compiler/syntax/parser.dart';
export 'compiler/syntax/token.dart';

Future<int> run(List<String> args) => MainCommand().run(args) as Future<int>;
