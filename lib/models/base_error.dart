class BaseError implements Exception {
  final String message;
  final int? statusCode;
  final dynamic originalError;

  BaseError({
    required this.message,
    this.statusCode,
    this.originalError,
  });

  @override
  String toString() => message;
}
