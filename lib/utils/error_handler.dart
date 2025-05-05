import 'package:flutter/material.dart';

/// Simple error handler for the application
class AppErrorHandler {
  /// Handle an error and return a user-friendly message
  String handleError(String code, String message) {
    debugPrint('Error [$code]: $message');
    return message;
  }
  
  /// Log an error without returning a message
  void logError(String code, String message) {
    debugPrint('Error [$code]: $message');
  }
}

/// Network-related exceptions
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);
  
  @override
  String toString() => 'NetworkException: $message';
}

/// Authentication-related exceptions
class AuthenticationException implements Exception {
  final String message;
  AuthenticationException(this.message);
  
  @override
  String toString() => 'AuthenticationException: $message';
}