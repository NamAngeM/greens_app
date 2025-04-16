import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Service qui gère l'intégration avec Ollama en local pour le chatbot écologique
class OllamaService {
  static OllamaService? _instance;
  bool _isInitialized = false;
  
  // Configuration Ollama
  final String _baseUrl = 'http://localhost:11434/api/chat';
  final String _modelName = 'gemma'; // Nom du modèle (gemma, llama3, etc.)
  
  /// Constructeur privé
  OllamaService._();
  
  /// Singleton pour le service Ollama
  static OllamaService get instance {
    _instance ??= OllamaService._();
    return _instance!;
  }

  /// Initialiser le service Ollama
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Vérifier que le serveur Ollama est accessible
      final response = await http.get(Uri.parse('http://localhost:11434'));
      
      if (response.statusCode == 200) {
        _isInitialized = true;
        debugPrint('Service Ollama initialisé avec succès');
      } else {
        throw Exception('Impossible de se connecter au serveur Ollama');
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation d\'Ollama: $e');
      _isInitialized = false;
    }
  }

  /// Envoyer une requête à Ollama et obtenir une réponse
  Future<String> getResponse(String text) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return "Désolé, je ne peux pas vous répondre pour le moment. Veuillez vérifier que le serveur Ollama est bien démarré sur votre machine.";
      }
    }

    try {
      // Préparer la requête avec un contexte écologique
      final payload = jsonEncode({
        'model': _modelName,
        'messages': [
          {
            'role': 'system',
            'content': 'Tu es un assistant spécialisé en écologie nommé GreenBot. Tu fournis des informations précises et factuelles sur le développement durable, la protection de l\'environnement, la biodiversité, les énergies renouvelables, l\'économie circulaire et tous les sujets liés à l\'écologie. Tu aimes donner des conseils pratiques et adaptés pour aider les utilisateurs à adopter un mode de vie plus respectueux de l\'environnement.'
          },
          {
            'role': 'user',
            'content': text
          }
        ],
        'stream': false
      });
      
      // Envoyer la requête à Ollama
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: payload
      );
      
      // Analyser la réponse
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['message']['content'] ?? '';
        return content.toString();
      } else {
        debugPrint('Erreur d\'Ollama: ${response.statusCode} - ${response.body}');
        return "Désolé, une erreur s'est produite lors du traitement de votre demande (${response.statusCode}).";
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'appel à Ollama: $e');
      return "Une erreur de communication s'est produite avec le serveur Ollama. Veuillez vérifier que le serveur fonctionne correctement.";
    }
  }
  
  /// Vérifier si le service est initialisé
  bool get isInitialized => _isInitialized;
} 