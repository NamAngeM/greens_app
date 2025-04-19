import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/llm_config.dart';
import 'ollama_service.dart';
import 'package:flutter/foundation.dart';

/// Service pour interagir avec le modèle de langage Ollama
class LlmService {
  late final String _apiUrl;
  final _ollamaService = OllamaService.instance;
  
  // Instance singleton du service (pour la compatibilité avec l'ancien code)
  static final LlmService _instance = LlmService();
  
  // Accéder à l'instance singleton (pour la compatibilité avec l'ancien code)
  static LlmService get instance => _instance;
  
  LlmService() {
    _init();
  }
  
  Future<void> _init() async {
    _apiUrl = await LlmConfig.getApiUrl();
  }
  
  // Méthode d'initialisation statique (pour la compatibilité avec l'ancien code)
  static Future<void> initialize() async {
    final url = await LlmConfig.getApiUrl();
    OllamaService.instance.updateApiUrl(url);
    await OllamaService.instance.initialize();
  }
  
  // Mise à jour de l'URL API (pour la compatibilité avec l'ancien code)
  void updateApiUrl(String url) {
    _apiUrl = url;
    _ollamaService.updateApiUrl(url);
  }
  
  // Test de connexion avec URL spécifique (pour la compatibilité avec l'ancien code)
  static Future<bool> testConnectionWithUrl(String apiUrl) async {
    try {
      // Créer une instance temporaire d'OllamaService pour tester la connexion
      final tempOllamaService = OllamaService.instance;
      tempOllamaService.updateApiUrl(apiUrl);
      await tempOllamaService.initialize();
      return tempOllamaService.isInitialized;
    } catch (e) {
      return false;
    }
  }
  
  Future<bool> testConnection() async {
    try {
      await _ollamaService.initialize();
      return _ollamaService.isInitialized;
    } catch (e) {
      return false;
    }
  }
  
  Future<Map<String, dynamic>> generateResponse(
    String prompt, 
    {String modelName = 'llama3', 
    double temperature = 0.7, 
    double topP = 0.9}
  ) async {
    try {
      // Utiliser OllamaService pour générer la réponse avec gestion des timeouts
      final response = await _ollamaService.generateResponse(
        prompt,
        modelName,
        temperature: temperature,
        topP: topP
      );
      
      return response;
    } catch (e) {
      return {
        'success': false,
        'message': 'Erreur: $e'
      };
    }
  }
  
  Future<String> generateLlmResponse(String prompt) async {
    try {
      final response = await generateResponse(prompt);
      
      if (response['success'] == true) {
        // Vérifier s'il y a eu un timeout
        if (response['timeout'] == true) {
          return "⚠️ ${response['message']}";
        }
        return response['message'];
      } else {
        return "Erreur: ${response['message']}";
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la génération de la réponse LLM: $e');
      return "Une erreur est survenue lors de la communication avec le serveur. Veuillez vérifier que le serveur Ollama est en cours d'exécution et qu'il est correctement configuré.";
    }
  }
  
  // Méthode pour la compatibilité avec l'ancien code
  Future<String> askEcologicalQuestion(String text) async {
    return await generateLlmResponse(text);
  }
}