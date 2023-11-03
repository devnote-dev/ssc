import '../syntax/ast.dart';

final class Visitor {
  late final Scope _scope;
  late final List<Statement> _input;

  Visitor(Program program) {
    _scope = program.scope;
    _input = program.statements;
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
        _ => stmt,
      };

  void _visitIdentifier(Identifier expr) {
    if (!_scope.variables.containsKey(expr)) {
      throw VisitorException('Undefined variable or type: $expr');
    }
  }

  // TODO: requires 'Function'
  void _visitCall(Call expr) {}

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

  void _visitSetValue(SetValue stmt) => _visit(stmt.value);
}

final class VisitorException implements Exception {
  final String message;

  const VisitorException(this.message);

  @override
  String toString() => message;
}
