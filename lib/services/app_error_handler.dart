import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service pour gérer les erreurs de l'application de manière centralisée
/// Permet un affichage cohérent des erreurs et facilite la gestion des retry
class AppErrorHandler {
  // Singleton pattern
  static final AppErrorHandler _instance = AppErrorHandler._internal();
  factory AppErrorHandler() => _instance;
  AppErrorHandler._internal();

  /// Affiche un message d'erreur à l'utilisateur
  void showErrorSnackBar(BuildContext context, String message, {
    bool allowRetry = false,
    VoidCallback? onRetry,
    Color backgroundColor = Colors.red,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 4),
        action: allowRetry && onRetry != null ? SnackBarAction(
          label: 'Réessayer',
          textColor: Colors.white,
          onPressed: onRetry,
        ) : null,
      ),
    );
  }

  /// Gère les erreurs Firebase Auth et retourne un message adapté
  String handleAuthError(FirebaseAuthException error) {
    switch (error.code) {
      case 'user-not-found':
        return 'Utilisateur non trouvé. Vérifiez votre adresse email.';
      case 'wrong-password':
        return 'Mot de passe incorrect. Veuillez réessayer.';
      case 'invalid-email':
        return 'Adresse email invalide.';
      case 'user-disabled':
        return 'Ce compte a été désactivé. Contactez le support.';
      case 'email-already-in-use':
        return 'Cette adresse email est déjà utilisée par un autre compte.';
      case 'operation-not-allowed':
        return 'Cette opération n\'est pas autorisée.';
      case 'weak-password':
        return 'Le mot de passe est trop faible. Utilisez au moins 6 caractères.';
      case 'requires-recent-login':
        return 'Cette opération est sensible et nécessite une authentification récente. Reconnectez-vous.';
      default:
        return 'Une erreur est survenue: ${error.message}';
    }
  }

  /// Gère les erreurs Firestore et retourne un message adapté
  String handleFirestoreError(FirebaseException error) {
    switch (error.code) {
      case 'permission-denied':
        return 'Vous n\'avez pas les permissions nécessaires pour cette opération.';
      case 'not-found':
        return 'Document non trouvé.';
      case 'already-exists':
        return 'Ce document existe déjà.';
      case 'failed-precondition':
        return 'Cette opération a échoué car les conditions préalables ne sont pas remplies.';
      case 'unavailable':
        return 'Le service est temporairement indisponible. Vérifiez votre connexion.';
      default:
        return 'Une erreur Firestore est survenue: ${error.message}';
    }
  }

  /// Gère les erreurs réseau et retourne un message adapté
  String handleNetworkError(dynamic error) {
    return 'Erreur de connexion. Vérifiez votre connexion internet et réessayez.';
  }

  /// Fonction générique pour gérer les erreurs dans les Future avec retry
  Future<T> handleFutureWithRetry<T>(
    Future<T> Function() future, {
    int maxRetries = 3,
    Duration retryDelay = const Duration(seconds: 2),
  }) async {
    int attempts = 0;
    while (attempts < maxRetries) {
      try {
        return await future();
      } catch (e) {
        attempts++;
        if (attempts >= maxRetries) {
          rethrow;
        }
        await Future.delayed(retryDelay * attempts);
      }
    }
    throw Exception('Failed after $maxRetries retries');
  }

  /// Returns a user-friendly error message based on the error code
  String handleError(String errorCode, [String? customMessage]) {
    // If a custom message is provided, use it
    if (customMessage != null && customMessage.isNotEmpty) {
      return customMessage;
    }
    
    // Map of error codes to user-friendly messages
    final Map<String, String> errorMessages = {
      'ServiceNotInitialized': 'Le service n\'est pas initialisé. Veuillez réessayer plus tard.',
      'NetworkError': 'Erreur de connexion réseau. Vérifiez votre connexion internet.',
      'ServerError': 'Erreur du serveur. Veuillez réessayer plus tard.',
      'ModelNotFound': 'Le modèle demandé n\'est pas disponible.',
      'InvalidRequest': 'Requête invalide. Veuillez vérifier vos paramètres.',
      'Timeout': 'La requête a pris trop de temps. Veuillez réessayer.',
      'Unknown': 'Une erreur inconnue s\'est produite. Veuillez réessayer plus tard.',
    };
    
    // Return the mapped error message or a default one if not found
    return errorMessages[errorCode] ?? 
           errorMessages['Unknown'] ?? 
           'Une erreur s\'est produite. Veuillez réessayer plus tard.';
  }

  /// Logs an error to the console and returns a user-friendly message
  String logAndHandleError(String errorCode, dynamic error, [String? customMessage]) {
    debugPrint('❌ Error [$errorCode]: $error');
    return handleError(errorCode, customMessage);
  }
}