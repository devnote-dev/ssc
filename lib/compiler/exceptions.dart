final class ParseException implements Exception {
  final String message;

  const ParseException(this.message);

  @override
  String toString() => message;
}

final class VisitorException implements Exception {
  final String message;

  const VisitorException(this.message);

  @override
  String toString() => message;
}
