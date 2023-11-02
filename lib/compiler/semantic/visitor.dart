import '../syntax/ast.dart';

final class Visitor {
  final List<Statement> _input;
  int _index = -1;

  Visitor(this._input);

  List<Statement> visit() {
    final stmts = <Statement>[];

    while (_remaining()) {
      stmts.add(_visit(_next()));
    }

    return stmts;
  }

  Statement _visit(Statement stmt) => switch (stmt) {
        ExpressionStatement(expr: Identifier expr) => _visitIdentifier(expr),
        ExpressionStatement(expr: Call expr) => _visitCall(expr),
        ExpressionStatement(expr: Infix expr) => _visitInfix(expr),
        SetType st => _visitSetType(st),
        _ => stmt,
      };

  Statement _visitIdentifier(Identifier expr) {
    // TODO: check if this is a variable or function call
    throw 'not implemented';
  }

  Statement _visitCall(Call expr) {
    // TODO: function table lookup stuff
    throw 'not implemented';
  }

  Statement _visitInfix(Infix expr) {
    // TODO: do the other stuff first
    throw 'not implemented';
  }

  Statement _visitSetType(SetType stmt) {
    if (stmt.resolvedType != null) return stmt;
    // TODO: type table lookup stuff
    throw 'not implemented';
  }

  Statement _next() => _input[++_index];
  bool _remaining() => _index + 1 < _input.length;
}
