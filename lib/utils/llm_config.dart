import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LlmConfig {
  static const String _apiUrlKey = 'llm_api_url';
  static const String _defaultApiUrl = 'http://localhost:11434/api/generate';
  
  // Récupérer l'URL de l'API depuis les préférences
  static Future<String> getApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_apiUrlKey) ?? _defaultApiUrl;
  }
  
  // Sauvegarder l'URL de l'API dans les préférences
  static Future<bool> saveApiUrl(String apiUrl) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_apiUrlKey, apiUrl);
  }
  
  // Réinitialiser l'URL de l'API à sa valeur par défaut
  static Future<bool> resetApiUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(_apiUrlKey, _defaultApiUrl);
  }
  
  // Vérifier si l'URL fournie est valide
  static bool isValidApiUrl(String url) {
    if (url.isEmpty) {
      print('URL vide détectée');
      return false;
    }
    
    try {
      print('Validation de l\'URL: $url');
      final uri = Uri.parse(url);
      final isValid = uri.isAbsolute && 
             (uri.scheme == 'http' || uri.scheme == 'https');
      
      print('URI analysé: ${uri.toString()}');
      print('Hôte: ${uri.host}, Port: ${uri.port}, Chemin: ${uri.path}');
      print('L\'URL est ${isValid ? "valide" : "invalide"}');
      
      return isValid;
    } catch (e) {
      print('Erreur lors de l\'analyse de l\'URL: $e');
      return false;
    }
  }
} 