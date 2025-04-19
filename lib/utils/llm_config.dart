import 'package:shared_preferences/shared_preferences.dart';

/// Classe utilitaire pour gérer la configuration du LLM
class LlmConfig {
  static const String _apiUrlKey = 'llm_api_url';
  static const String _defaultApiUrl = 'http://localhost:3000/api'; // URL de l'API Node.js

  /// Valider si une URL est correctement formée
  static bool isValidApiUrl(String url) {
    if (url.isEmpty) return false;
    
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Récupérer l'URL de l'API stockée dans les préférences
  static Future<String> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiUrlKey) ?? _defaultApiUrl;
  }

  /// Sauvegarder l'URL de l'API dans les préférences
  static Future<void> saveApiUrl(String url) async {
    if (!isValidApiUrl(url)) {
      throw Exception('URL invalide: $url');
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiUrlKey, url);
  }

  /// Réinitialiser l'URL de l'API à sa valeur par défaut
  static Future<void> resetApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiUrlKey, _defaultApiUrl);
  }
} 