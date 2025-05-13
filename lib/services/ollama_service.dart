import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Service pour interagir avec Ollama (LLM local)
class OllamaService {
  // Singleton pattern
  static final OllamaService _instance = OllamaService._internal();
  factory OllamaService() => _instance;
  OllamaService._internal();

  // Configuration par défaut
  String _baseUrl = 'http://192.168.1.97:11434';
  String _defaultModel = 'llama3';
  bool _isInitialized = false;

  // Getters
  bool get isInitialized => _isInitialized;
  String get baseUrl => _baseUrl;
  String get defaultModel => _defaultModel;

  /// Initialiser le service Ollama
  Future<void> initialize({String? baseUrl, String? defaultModel}) async {
    try {
      if (baseUrl != null) _baseUrl = baseUrl;
      if (defaultModel != null) _defaultModel = defaultModel;
      
      // Tester la connexion avec une requête simple
      final response = await http.get(
        Uri.parse('$_baseUrl/api/tags'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 20), // Augmenter le timeout à 20 secondes
        onTimeout: () {
          print('Délai d\'attente dépassé lors de la connexion à Ollama');
          throw Exception('Délai d\'attente dépassé lors de la connexion à Ollama');
        },
      );
      
      if (response.statusCode == 200) {
        print('OllamaService initialisé avec succès');
        _isInitialized = true;
      } else {
        print('Échec de l\'initialisation d\'OllamaService: ${response.statusCode} ${response.body}');
        _isInitialized = false;
      }
    } catch (e) {
      print('Exception lors de l\'initialisation de OllamaService: $e');
      _isInitialized = false;
    }
  }

  /// Générer une réponse à partir du modèle Ollama
  Future<String> generateResponse(String prompt) async {
    try {
      if (!_isInitialized) {
        return "Désolé, le service Ollama n'est pas disponible actuellement.";
      }
      
      final requestBody = {
        'model': _defaultModel,
        'prompt': prompt,
        'stream': false,
        'options': {
          'num_ctx': 4096,  // Contexte plus large
          'num_predict': 1024  // Limiter la longueur de réponse
        }
      };
      
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(
        const Duration(seconds: 90), // Augmenter le timeout à 90 secondes pour la génération
        onTimeout: () {
          print('Délai d\'attente dépassé lors de la génération de réponse par Ollama');
          throw Exception('La génération de réponse a pris trop de temps. Veuillez réessayer avec un message plus court.');
        },
      );
      
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data['response'] ?? "Désolé, je n'ai pas pu générer de réponse.";
      } else {
        print('Erreur lors de la génération de réponse: ${response.statusCode} ${response.body}');
        return "Une erreur s'est produite lors de la génération de la réponse.";
      }
    } catch (e) {
      print('Exception lors de la génération de réponse: $e');
      return "Une erreur s'est produite: $e";
    }
  }

  /// Récupérer la liste des modèles disponibles
  Future<List<String>> getAvailableModels() async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return [];
      }
    }

    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/tags'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Vérifier si le format JSON a 'models' ou directement un tableau
        if (data is Map && data.containsKey('models') && data['models'] is List) {
          return List<String>.from(
            (data['models'] as List).map((model) => model['name'].toString())
          );
        } else if (data is List) {
          // Format alternatif où la réponse est directement un tableau
          return List<String>.from(
            data.map((model) => model['name'] ?? model['model'] ?? '').where((name) => name.isNotEmpty)
          );
        }
        
        // Si aucun format reconnu, imprimer la réponse pour investigation
        print('Format de réponse Ollama non reconnu: $data');
        return [];
      } else {
        print('Erreur récupération modèles: ${response.statusCode} - ${response.body}');
        return [];
      }
    } catch (e) {
      print('Exception récupération modèles: $e');
      return [];
    }
  }
} 