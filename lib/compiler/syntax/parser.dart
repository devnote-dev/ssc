import 'ast.dart';
import 'token.dart';
import '../exceptions.dart' show ParseException;

final class Parser {
  final List<Token> _input;
  final List<ParseException> exceptions = [];
  int _index = -1;

  Parser(this._input);

  Program parse() {
    final stmts = <Statement>[];

    while (_remaining()) {
      final stmt = _parse(_next());
      if (stmt == null) break;
      stmts.add(stmt);
    }

    return Program(stmts);
  }

  Statement? _parse(Token token) => switch (token.kind) {
        TokenKind.eof => null,
        TokenKind.set => _parseSet(),
        TokenKind.newline => _parse(_next()),
        _ => _parseExpressionStatement(),
      };

  Statement _parseSet() {
    var token = _next();
    final name = switch (token.kind) {
      TokenKind.ident => _parseIdentifier(token) as Identifier,
      // TODO: maybe warn against 'set set to ...'
      // TokenKind.set =>
      _ => throw ParseException(
          'Expected an identifier to set, not a ${token.kind}'),
    };

    token = _next();
    // TODO: check if modifier is 'as' or 'to'
    if (token.kind != TokenKind.to) {
      throw ParseException("Expected keyword 'to' after 'set'");
    }

    token = _next();
    final value = _parseExpressionStatement() as ExpressionStatement;

    return SetValue(name, value);
  }

  Statement _parseExpressionStatement() {
    final expr = _parseExpression(Precedence.lowest);

    return ExpressionStatement(expr);
  }

  Expression _parseExpression(Precedence prec) {
    var left = _parsePrefixType(_current);
    if (left == null) {
      throw ParseException('Cannot parse prefix type for ${_current.kind}');
    }

    while (true) {
      if (_current.kind == TokenKind.eof) break;

      final next = _next();
      if (prec >= Precedence.from(next.kind)) break;

      final infix = _parseInfixType(next.kind, left!);
      if (infix == null) break;

      left = infix;
    }

    return left!;
  }

  Expression? _parsePrefixType(Token token) => switch (token.kind) {
        TokenKind.ident => _parseIdentifier(token),
        TokenKind.string => _parseString(token),
        TokenKind.integer => _parseInteger(token),
        TokenKind.float => _parseFloat(token),
        _ => null,
      };

  Expression? _parseInfixType(TokenKind kind, Expression expr) =>
      switch (kind) {
        TokenKind.plus ||
        TokenKind.minus ||
        TokenKind.asterisk ||
        TokenKind.slash =>
          _parseInfix(kind, expr),
        _ => null,
      };

  Expression _parseInfix(TokenKind kind, Expression left) {
    final op = switch (kind) {
      TokenKind.plus => Operator.add,
      TokenKind.minus => Operator.subtract,
      TokenKind.asterisk => Operator.multiply,
      TokenKind.slash => Operator.divide,
      _ => throw 'unreachable',
    };

    final token = _next();
    final prec = Precedence.from(token.kind);
    final right = _parseExpression(prec);

    return Infix(left, op, right);
  }

  Expression _parseIdentifier(Token token) {
    var peek = _peek();
    if (peek == null) return Identifier(token.value!);

    if (peek.kind == TokenKind.newline || peek.kind == TokenKind.eof) {
      return Identifier(token.value!);
    }

    return switch (peek.kind) {
      // TODO: add TokenKind.with
      TokenKind.ident ||
      TokenKind.string ||
      TokenKind.integer ||
      TokenKind.float ||
      TokenKind.newline ||
      TokenKind.eof =>
        _parseCall(token),
      _ => Identifier(token.value!),
    };
  }

  Expression _parseCall(Token token) {
    final args = <Expression>[];
    // final named = <String, Expression>{};
    // var usedWith = false;

    var next = _next();
    args.add(_parseExpression(Precedence.lowest));

    next = _next();
    if (next.kind != TokenKind.comma) {
      return Call(Identifier(token.value!), args);
    }

    outer:
    while (_remaining()) {
      if (_current.kind != TokenKind.comma) break;

      switch (_next()) {
        case Token(kind: TokenKind.eof):
          break outer;
        case Token(kind: TokenKind.newline):
          continue;
        default:
          args.add(_parseExpression(Precedence.lowest));
          _index++;
          break;
      }
    }

    return Call(Identifier(token.value!), args);
  }

  Expression _parseString(Token token) => StringLiteral(token.value!);

  Expression _parseInteger(Token token) =>
      IntegerLiteral(int.parse(token.value!));

  Expression _parseFloat(Token token) =>
      FloatLiteral(double.parse(token.value!));

  Token get _current => _input[_index];
  Token? _peek() => _remaining() ? _input[_index + 1] : null;
  Token _next() => _input[++_index];
  bool _remaining() => _index + 1 < _input.length;
}
