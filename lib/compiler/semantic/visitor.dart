import 'builtins.dart';
import '../syntax/ast.dart';
import '../exceptions.dart' show VisitorException;

final class Visitor {
  late final Scope _scope;
  late final List<Statement> _input;

  Visitor(Program program) {
    _scope = program.scope;
    _input = program.statements;

    _scope.types[builtinPrint.name] = builtinPrint;
  }

  void visit() {
    for (final stmt in _input) {
      _visit(stmt);
    }
  }

  void _visit(Statement stmt) => switch (stmt) {
        ExpressionStatement(expr: Identifier expr) => _visitIdentifier(expr),
        ExpressionStatement(expr: Call expr) => _visitCall(expr),
        ExpressionStatement(expr: Infix expr) => _visitInfix(expr),
        SetValue st => _visitSetValue(st),
        _ => (),
      };

  void _visitIdentifier(Identifier expr) {
    if (!_scope.variables.containsKey(expr)) {
      throw VisitorException('Undefined variable or type: $expr');
    }
  }

  void _visitCall(Call expr) {
    var func = _scope.types[expr.function];
    if (func == null) {
      throw VisitorException("Undefined function '${expr.function}'");
    }

    if (func.type() != 'function' && func.type() != 'builtin') {
      throw VisitorException('Cannot call type ${func.type()} as a function');
    }

    func = func as FunctionBase;
    if (expr.args.length != func.params.length) {
      final buffer = StringBuffer("Function '${func.name}' takes ");

      if (func.params.isEmpty) {
        buffer.write('no');
      } else {
        buffer.write(func.params.length);
      }

      buffer.write(' arguments but was given ${expr.args.length}');
      throw VisitorException(buffer.toString());
    }

    for (var i = 0; i < func.params.length; i++) {
      final expected = func.params[i];
      final got = expr.args[i];

      // ignore: unrelated_type_equality_checks
      if (expected.typeName != got.type()) {
        throw VisitorException(
            'Expected parameter ${i + 1} to be type ${expected.typeName}, not type ${got.type()}');
      }
    }
  }

  void _visitInfix(Infix expr) {
    if (!expr.operator.comparable) {
      if (!expr.left.accepts(expr.right)) {
        throw VisitorException(
            'Cannot ${expr.operator} types ${expr.left.type()} and ${expr.right.type()}');
      }
    }

    switch (expr.left.type()) {
      case 'string':
        if (expr.operator != Operator.add) {
          throw VisitorException(
              'Operation ${expr.operator} not supported for type string');
        }
        break;
      // case 'array': ...
    }
  }

  void _visitSetValue(SetValue stmt) {
    _visit(stmt.value);
    _scope.variables[stmt.name] = stmt.value.expr;
  }
}
