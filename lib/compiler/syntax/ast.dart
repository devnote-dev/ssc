final class Program {
  final scope = Scope(null);
  List<Statement> statements;

  Program(this.statements);
}

final class Scope {
  final Scope? parent;
  final types = <Identifier, Statement>{};
  final variables = <Identifier, Expression>{};

  Scope(this.parent);
}

sealed class Node {
  String type();
}

sealed class Expression extends Node {
  bool accepts(Expression other);
}

final class Identifier implements Expression {
  final String value;

  const Identifier(this.value);

  @override
  String type() => 'identifier';

  @override
  bool accepts(Expression other) => false;

  @override
  String toString() => value;
}

final class StringLiteral implements Expression {
  final String value;

  const StringLiteral(this.value);

  @override
  String type() => 'string';

  @override
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

  @override
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

  @override
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
  bool accepts(Expression other) => false;

  @override
  String toString() {
    final buffer = StringBuffer(function);

    if (args.isNotEmpty) {
      buffer
        ..write(' with ')
        ..write(args.join(', '));
    }

    return buffer.toString();
  }
}

enum Operator {
  add,
  subtract,
  multiply,
  divide;

  // TODO: change to
  // bool get comparable => this == equals || ...;
  bool get comparable =>
      !(this == add || this == subtract || this == multiply || this == divide);

  @override
  String toString() => switch (this) {
        add => 'add',
        subtract => 'subtract',
        multiply => 'multiply',
        divide => 'divide',
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
  bool accepts(Expression other) => false;

  @override
  String toString() => '$left $operator $right';
}

sealed class Statement extends Node {}

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
  String toString() => 'set $name as $typeName';
}

final class SetValue implements Statement {
  final Identifier name;
  final ExpressionStatement value;

  const SetValue(this.name, this.value);

  @override
  String type() => 'set value';

  @override
  String toString() => 'set $name to $value';
}

final class Parameter extends Statement {
  final Identifier name;
  final Identifier typeName;
  final Expression? defaultValue;
  final bool explicit;

  Parameter(this.name, this.typeName, this.explicit, {this.defaultValue});

  @override
  String type() => 'parameter';

  @override
  String toString() {
    final buffer = StringBuffer();
    if (explicit) buffer.write('explicit ');

    buffer.writeAll([name, ' as ', typeName]);
    if (defaultValue != null) buffer.writeAll([' with default ', typeName]);

    return buffer.toString();
  }
}

sealed class FunctionBase extends Statement {
  final Identifier name;
  final List<Parameter> params;
  final Identifier returnType;

  FunctionBase(this.name, this.params, this.returnType);

  @override
  String toString() {
    final buffer = StringBuffer('function $name');

    if (params.isNotEmpty) {
      buffer
        ..write(' using ')
        ..write(params.join(', '));
    }

    buffer.write(' that returns $returnType');

    return buffer.toString();
  }
}

final class FunctionType extends FunctionBase {
  final List<Statement> body;

  FunctionType(
      Identifier name, List<Parameter> params, Identifier returnType, this.body)
      : super(name, params, returnType);

  @override
  String type() => 'function';
}

final class BuiltinType extends FunctionBase {
  final Expression Function(List<Expression> args) call;

  BuiltinType(
      Identifier name, List<Parameter> params, Identifier returnType, this.call)
      : super(name, params, returnType);

  @override
  String type() => 'builtin';
}
