import 'dart:convert';
import 'package:http/http.dart' as http;
import '../utils/llm_config.dart';

/// Service pour interagir avec le modèle de langage Ollama
class LlmService {
  /// URL de base pour l'API Ollama
  String? baseUrl;
  
  /// Instance singleton du service
  static LlmService? _instance;
  
  /// Accéder à l'instance
  static LlmService get instance {
    _instance ??= LlmService._internal();
    return _instance!;
  }
  
  /// Constructeur privé
  LlmService._internal();
  
  /// Initialise le service avec l'URL de l'API
  static Future<void> initialize() async {
    final url = await LlmConfig.getApiUrl();
    instance.baseUrl = url;
  }
  
  /// Met à jour l'URL de l'API
  void updateApiUrl(String url) {
    baseUrl = url;
  }
  
  /// Teste la connexion avec l'URL actuelle
  Future<bool> testConnection() async {
    if (baseUrl == null) {
      await initialize();
    }
    
    return await testConnectionWithUrl(baseUrl!);
  }
  
  /// Teste la connexion à l'API Ollama avec l'URL fournie
  static Future<bool> testConnectionWithUrl(String apiUrl) async {
    try {
      // Vérifie si l'URL est valide
      if (!LlmConfig.isValidApiUrl(apiUrl)) {
        return false;
      }

      // Construction de l'URL complète pour l'endpoint de liste des modèles
      final url = Uri.parse('$apiUrl/api/tags');
      
      // Envoi d'une requête GET pour vérifier la connexion
      final response = await http.get(url).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('Timeout', 408),
      );

      // Vérification de la réponse HTTP
      return response.statusCode == 200;
    } catch (e) {
      // En cas d'erreur, la connexion a échoué
      return false;
    }
  }
  
  /// Récupère la liste des modèles disponibles
  Future<List<String>> getAvailableModels() async {
    if (baseUrl == null) {
      await initialize();
    }
    
    try {
      final response = await http.get(Uri.parse('$baseUrl/api/tags'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final models = data['models'] as List;
        return models.map((model) => model['name'].toString()).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
  
  /// Envoie une requête au modèle et récupère la réponse
  Future<String> sendPrompt(String prompt, String model) async {
    if (baseUrl == null) {
      await initialize();
    }
    
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': model,
          'prompt': prompt,
          'stream': false,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? 'Pas de réponse';
      } else {
        return 'Erreur: ${response.statusCode}';
      }
    } catch (e) {
      return 'Erreur de connexion: $e';
    }
  }
}