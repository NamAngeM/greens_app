import 'package:shared_preferences/shared_preferences.dart';

/// Classe de configuration pour les paramètres du LLM
class LlmConfig {
  static const String _apiUrlKey = 'ollama_api_url';
  static const String _defaultApiUrl = 'http://localhost:11434';
  
  /// Récupère l'URL de l'API stockée ou l'URL par défaut si aucune n'est définie
  static Future<String> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiUrlKey) ?? _defaultApiUrl;
  }
  
  /// Sauvegarde l'URL de l'API
  static Future<void> saveApiUrl(String url) async {
    if (!isValidApiUrl(url)) {
      throw Exception('URL invalide');
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiUrlKey, url);
  }
  
  /// Réinitialise l'URL de l'API à sa valeur par défaut
  static Future<void> resetApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_apiUrlKey, _defaultApiUrl);
  }
  
  /// Vérifie si l'URL fournie est valide pour l'API
  static bool isValidApiUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.isAbsolute && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }
} 