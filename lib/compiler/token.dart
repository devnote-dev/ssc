enum TokenKind {
  /// Primitives
  ident,
  string,

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

  space,
  newline,
  illegal,
  eof;

  bool get needsQuotes => this == ident || this == string || this == illegal;

  @override
  String toString() => switch (this) {
        ident => 'identifier',
        string => 'string',
        set => 'set',
        to => 'to',
        space => 'space',
        newline => 'newline',
        illegal => 'illegal',
        eof => 'EOF',
      };
}

final class Token {
  final TokenKind kind;
  final String? value;

  Token(this.kind, [this.value]);

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