import '../syntax/ast.dart';

final _printParams = List.generate(
    3,
    (index) =>
        Parameter(Identifier('value$index'), Identifier('anything'), false));

final builtinPrint = BuiltinType(
    const Identifier('print'), _printParams, const Identifier('integer'),
    (args) {
  print(args.join(' '));
  return IntegerLiteral(0);
});
