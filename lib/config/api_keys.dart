import 'package:flutter/foundation.dart';

/// Classe pour gérer les clés API de manière sécurisée
class ApiKeys {
  // Singleton
  static final ApiKeys _instance = ApiKeys._internal();
  factory ApiKeys() => _instance;
  ApiKeys._internal();

  // Clés API
  static const String _carbonCloudApiKeyDev = 'CARBON_CLOUD_DEV_KEY';
  static const String _carbonCloudApiKeyProd = 'CARBON_CLOUD_PROD_KEY';

  /// Obtenir la clé API CarbonCloud en fonction de l'environnement
  String getCarbonCloudApiKey() {
    // En production, cette clé devrait être récupérée de manière sécurisée
    // par exemple depuis les variables d'environnement ou un service sécurisé
    if (kReleaseMode) {
      // TODO: Implémenter une méthode sécurisée pour récupérer la clé en production
      return _carbonCloudApiKeyProd;
    } else {
      // En développement, utiliser une clé de test
      return _carbonCloudApiKeyDev;
    }
  }

  /// Méthode pour les tests
  @visibleForTesting
  String getTestApiKey() {
    return 'TEST_API_KEY';
  }
}
