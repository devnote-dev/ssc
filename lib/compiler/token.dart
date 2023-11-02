enum TokenKind {
  /// Primitives
  ident,
  string,

  /// Operators
  plus,
  minus,
  asterisk,
  slash,

  /// Declarations
  // get,
  set,
  // global,
  // from,
  to,
  // on,
  // in,
  // as,
  // with,

  /// Modules
  // import,
  // export,

  /// Constructs
  // define,
  // native,
  // function,
  // class,
  // that,
  // returns,
  // using,
  // explicit,
  // default,
  // where,
  // end,

  /// Conditionals
  // if,
  // then,
  // else,
  // repeat,
  // for,
  // try,
  // catch,

  comma,
  space,
  newline,
  illegal,
  eof;

  bool get needsQuotes =>
      this == ident || this == string || this == space || this == illegal;

  @override
  String toString() => switch (this) {
        ident => 'identifier',
        string => 'string',
        plus => 'plus',
        minus => 'minus',
        asterisk => 'asterisk',
        slash => 'slash',
        set => 'set',
        to => 'to',
        comma => 'comma',
        space => 'space',
        newline => 'newline',
        illegal => 'illegal',
        eof => 'EOF',
      };
}

final class Token {
  final TokenKind kind;
  final String? value;

  const Token(this.kind, [this.value]);

  @override
  bool operator ==(Object other) {
    if (other is! Token) return false;
    return kind == other.kind && value == other.value;
  }

  @override
  int get hashCode => kind.hashCode ^ value.hashCode;

  @override
  String toString() {
    final buffer = StringBuffer('Token(')..write(kind);

    if (value != null) {
      buffer.write(', ');
      if (kind.needsQuotes) {
        buffer.writeAll(['"', value, '"']);
      } else {
        buffer.write(value);
      }
    }
    buffer.write(')');

    return buffer.toString();
  }
}

enum Precedence {
  lowest,
  equals,
  lessGreater,
  sum,
  product,
  prefix;

  static Precedence from(TokenKind kind) => switch (kind) {
        TokenKind.plus || TokenKind.minus => sum,
        TokenKind.asterisk || TokenKind.slash => product,
        _ => lowest,
      };

  bool operator >=(Precedence other) => index >= other.index;
}
