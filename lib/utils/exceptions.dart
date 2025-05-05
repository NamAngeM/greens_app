class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
}

class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
}