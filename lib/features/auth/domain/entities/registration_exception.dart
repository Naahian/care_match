/// A safe registration failure for presentation; contains no request data.
class RegistrationException implements Exception {
  const RegistrationException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
