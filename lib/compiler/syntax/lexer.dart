import 'token.dart';

const _operators = {
  42, // '*'
  43, // '+'
  45, // '-'
  47, // '/'
};

final class Lexer {
  late final List<int> _input;
  late final bool _withSpace;
  int _index = -1;

  Lexer(String source, {bool withSpace = false}) {
    _input = source.runes.toList()..add(0);
    _withSpace = withSpace;
  }

  List<Token> lex() {
    final tokens = <Token>[];

    outer:
    while (_remaining()) {
      final next = _next();

      switch (next) {
        case 0:
          tokens.add(Token(TokenKind.eof));
          break outer;
        case 10:
          tokens.add(Token(TokenKind.newline));
          break;
        case 32:
          if (_withSpace) tokens.add(_lexSpace());
          break;
        case 34 || 39:
          tokens.add(_lexString());
          break;
        case 44:
          tokens.add(Token(TokenKind.comma));
          break;
        case >= 48 && <= 57:
          tokens.add(_lexNumber());
          break;
        case _ when _operators.contains(next):
          tokens.add(_lexOperator());
          break;
        case >= 65 && <= 90 || >= 97 && <= 122:
          tokens.add(_lexIdent());
          break;
        default:
          tokens.add(Token(TokenKind.illegal,
              "Unexpected token: ${String.fromCharCode(next)}"));
          break;
      }
    }

    return tokens;
  }

  Token _lexSpace() {
    final start = _index;
    while (_remaining() && _next() == 32) {}

    return Token(TokenKind.space, _getRange(start, _index--));
  }

  Token _lexIdent() {
    final start = _index;

    while (_remaining()) {
      final next = _next();
      if (next >= 65 && next <= 90 || next >= 97 && next <= 122) continue;
      break;
    }
    final value = _getRange(start, _index--);

    return switch (value) {
      'set' => Token(TokenKind.set),
      'to' => Token(TokenKind.to),
      _ => Token(TokenKind.ident, value),
    };
  }

  Token _lexString() {
    final start = _index + 1;
    final delim = _input[_index];
    var closed = false;

    while (_remaining() && _next() != delim) {
      if (_next() == delim) {
        closed = true;
        break;
      }
    }

    if (closed) {
      return Token(TokenKind.string, _getRange(start, _index));
    } else {
      return Token(TokenKind.illegal, 'Unterminated quote string');
    }
  }

  Token _lexNumber() {
    final start = _index;
    var float = false;

    while (_remaining()) {
      final next = _next();
      if (next >= 48 && next <= 57) continue;
      if (next == 46) {
        if (float) return Token(TokenKind.illegal, 'Invalid float number');
        float = true;
      }
      break;
    }
    final kind = float ? TokenKind.float : TokenKind.integer;

    return Token(kind, _getRange(start, _index--));
  }

  Token _lexOperator() {
    final start = _index;
    while (_remaining() && _operators.contains(_next())) {}

    final value = _getRange(start, _index--);
    return switch (value) {
      '+' => Token(TokenKind.plus),
      '-' => Token(TokenKind.minus),
      '*' => Token(TokenKind.asterisk),
      '/' => Token(TokenKind.slash),
      _ => Token(TokenKind.illegal, 'Invalid operator: $value'),
    };
  }

  int _next() => _input[++_index];
  bool _remaining() => _index + 1 < _input.length;
  String _getRange(int start, int stop) =>
      String.fromCharCodes(_input.sublist(start, stop));
}
