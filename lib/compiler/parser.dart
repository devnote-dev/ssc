import 'ast.dart';
import 'token.dart';

final class Parser {
  final List<Token> _input;
  final List<ParseException> exceptions = [];
  int _index = -1;

  Parser(this._input);

  List<Statement> parse() {
    final stmts = <Statement>[];

    while (true) {
      final stmt = _parse(_next());
      if (stmt == null) break;
      stmts.add(stmt);
    }

    return stmts;
  }

  Statement? _parse(Token token) => switch (token.kind) {
        TokenKind.eof => null,
        TokenKind.set => _parseSet(),
        TokenKind.space || TokenKind.newline => _parse(_next()),
        _ => _parseExpressionStatement(),
      };

  Statement _parseSet() {
    var token = _nextNoSpace();
    final name = switch (token.kind) {
      TokenKind.ident => _parseIdentifier(token) as Identifier,
      // TODO: maybe warn against 'set set to ...'
      // TokenKind.set =>
      _ => throw ParseException(
          'Expected an identifier to set, not a ${token.kind}'),
    };

    token = _nextNoSpace();
    // TODO: check if modifier is 'as' or 'to'
    if (token.kind != TokenKind.to) {
      throw ParseException("Expected keyword 'to' after 'set'");
    }

    token = _nextNoSpace();
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
      if (_current.kind == TokenKind.eof) {
        throw ParseException('Unexpected End of File');
      }

      final peek = _peek();
      if (peek == null || prec >= Precedence.from(peek.kind)) break;

      final infix = _parseInfixType(peek.kind, left!);
      if (infix == null) break;

      left = infix;
    }

    return left!;
  }

  Expression? _parsePrefixType(Token token) => switch (token.kind) {
        TokenKind.ident => _parseIdentifier(token),
        TokenKind.string => _parseString(token),
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
    _nextNoSpace(); // skip the current operator token
    final op = switch (kind) {
      TokenKind.plus => Operator.add,
      TokenKind.minus => Operator.subtract,
      TokenKind.asterisk => Operator.multiply,
      TokenKind.slash => Operator.divide,
      _ => throw 'unreachable',
    };

    final token = _nextNoSpace();
    final prec = Precedence.from(token.kind);
    final right = _parseExpression(prec);

    return Infix(left, op, right);
  }

  Expression _parseIdentifier(Token token) => Identifier(token.value!);

  Expression _parseString(Token token) => StringLiteral(token.value!);

  Token get _current => _input[_index];
  Token? _peek() => _remaining() ? _input[_index + 1] : null;
  Token _next() => _input[++_index];
  bool _remaining() => _index + 1 < _input.length;

  Token _nextNoSpace() {
    var next = _next();
    while (next.kind == TokenKind.space || next.kind == TokenKind.newline) {
      next = _next();
    }

    return next;
  }
}

final class ParseException implements Exception {
  final String message;

  const ParseException(this.message);

  @override
  String toString() => message;
}
