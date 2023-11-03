import '../syntax/ast.dart';

final _printParams = List.generate(
    3,
    (index) =>
        Parameter(Identifier('value$index'), Identifier('anything'), false));

final builtinPrint = BuiltinType(
    Identifier('print'), _printParams, Identifier('integer'), (args) {
  print(args.join(' '));
  return IntegerLiteral(0);
});
