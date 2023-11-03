final class Program {
  final scope = Scope(null);
  List<Statement> statements;

  Program(this.statements);
}

final class Scope {
  final Scope? parent;
  // final classes = <Identifier, Class>{};
  // final functions = <Identifier, Function>{};
  final variables = <Identifier, Expression>{};

  Scope(this.parent);
}

sealed class Node {
  String type();
}

sealed class Expression extends Node {}

extension Accept on Expression {
  bool accepts(Expression other) => false;
}

sealed class Statement extends Node {}

final class Identifier implements Expression {
  final String value;

  const Identifier(this.value);

  @override
  String type() => 'identifier';

  @override
  String toString() => value;
}

final class StringLiteral implements Expression {
  final String value;

  const StringLiteral(this.value);

  @override
  String type() => 'string';

  bool accepts(Expression other) => other.type() == 'string';

  @override
  String toString() {
    final delim = value.contains('"') ? "'" : '"';

    return '$delim$value$delim';
  }
}

final class IntegerLiteral implements Expression {
  final int value;

  const IntegerLiteral(this.value);

  @override
  String type() => 'integer';

  bool accepts(Expression other) =>
      other.type() == 'integer' || other.type() == 'float';

  @override
  String toString() => value.toString();
}

final class FloatLiteral implements Expression {
  final double value;

  const FloatLiteral(this.value);

  @override
  String type() => 'float';

  bool accepts(Expression other) =>
      other.type() == 'float' || other.type() == 'integer';

  @override
  String toString() => value.toString();
}

final class Call implements Expression {
  final Expression function;
  final List<Expression> args;

  const Call(this.function, this.args);

  @override
  String type() => 'call';

  @override
  String toString() {
    final buffer = StringBuffer(function)..write('(');

    if (args.isNotEmpty) {
      buffer.write(args[0].type());
      for (final arg in args.skip(1)) {
        buffer.writeAll([', ', arg.type()]);
      }
    }

    buffer.write(')');

    return buffer.toString();
  }
}

enum Operator {
  add,
  subtract,
  multiply,
  divide;

  @override
  String toString() => switch (this) {
        add => '+',
        subtract => '-',
        multiply => '*',
        divide => '/',
      };
}

final class Infix implements Expression {
  final Expression left;
  final Operator operator;
  final Expression right;

  const Infix(this.left, this.operator, this.right);

  @override
  String type() => 'infix';

  @override
  String toString() => '$left $operator $right';
}

final class ExpressionStatement implements Statement {
  final Expression expr;

  const ExpressionStatement(this.expr);

  @override
  String type() => expr.type();

  @override
  String toString() => expr.toString();
}

final class SetType implements Statement {
  final Identifier name;
  final Identifier typeName;
  Statement? resolvedType;

  SetType(this.name, this.typeName, [this.resolvedType]);

  @override
  String type() => 'set type';

  @override
  String toString() => typeName.value;
}

final class SetValue implements Statement {
  final Identifier name;
  final ExpressionStatement value;

  const SetValue(this.name, this.value);

  @override
  String type() => 'set value';

  @override
  String toString() => value.toString();
}
