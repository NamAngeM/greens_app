import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:greens_app/models/chatbot_message.dart';

/// Service pour interagir avec l'API Gemini de Google
class GeminiService {
  // Singleton pattern
  static final GeminiService _instance = GeminiService._internal();
  factory GeminiService() => _instance;
  static GeminiService get instance => _instance;

  // Configuration
  String _apiKey = '';
  String _model = 'gemini-pro';
  bool _isInitialized = false;
  
  // Endpoint de l'API Gemini
final String _baseUrl = 'https://generativelanguage.googleapis.com/v1';
  
  // Getters
  bool get isInitialized => _isInitialized;
  String get model => _model;

  GeminiService._internal();

  /// Initialise le service Gemini avec une clé API
  Future<void> initialize({
    required String apiKey,
    String model = 'gemini-pro',
  }) async {
    try {
      _apiKey = apiKey;
      _model = model;
      
      // Vérifier si l'API est accessible
      final testResponse = await _testConnection();
      if (testResponse) {
        _isInitialized = true;
        print('GeminiService initialisé avec succès');
        print('  - Modèle: $_model');
      } else {
        print('GeminiService: échec de la connexion à l\'API');
        _isInitialized = false;
      }
    } catch (e) {
      print('Exception lors de l\'initialisation de GeminiService: $e');
      _isInitialized = false;
    }
  }

  /// Teste la connexion à l'API Gemini
  Future<bool> _testConnection() async {
    try {
      final url = Uri.parse('$_baseUrl/models?key=$_apiKey');
      final response = await http.get(url).timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data != null;
      }
      return false;
    } catch (e) {
      print('Erreur lors du test de connexion à Gemini: $e');
      return false;
    }
  }

  /// Génère une réponse à partir d'un prompt
  Future<String> generateResponse(String prompt) async {
    if (!_isInitialized) {
      return "Le service Gemini n'est pas initialisé. Veuillez vérifier votre clé API.";
    }
    
    try {
      final url = Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey');
      
      // Construire le corps de la requête avec le prompt enrichi
      final String enrichedPrompt = _buildEcologicalPrompt(prompt);
      
      final body = jsonEncode({
        "contents": [
          {
            "parts": [
              {
                "text": enrichedPrompt
              }
            ]
          }
        ],
        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 1024,
        }
      });
      
      // Envoyer la requête
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extraire le texte de la réponse
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
        
        return "Désolé, je n'ai pas pu générer une réponse appropriée.";
      } else {
        print('Erreur API Gemini: ${response.statusCode} - ${response.body}');
        return "Une erreur s'est produite lors de la communication avec l'API Gemini (${response.statusCode}).";
      }
    } catch (e) {
      print('Exception lors de la génération de réponse Gemini: $e');
      return "Une erreur s'est produite: $e";
    }
  }

  /// Génère une réponse en tenant compte du contexte de la conversation
  Future<String> generateResponseWithContext(
    String prompt, 
    List<Map<String, dynamic>> context
  ) async {
    if (!_isInitialized) {
      return "Le service Gemini n'est pas initialisé. Veuillez vérifier votre clé API.";
    }
    
    try {
      final url = Uri.parse('$_baseUrl/models/$_model:generateContent?key=$_apiKey');
      
      // Construire le corps de la requête avec le contexte
      final List<Map<String, dynamic>> contents = [];
      
      // Ajouter le message système comme premier message
      contents.add({
        "role": "model",
        "parts": [
          {
            "text": _getSystemPrompt()
          }
        ]
      });
      
      // Ajouter les messages précédents comme contexte
      for (final msg in context) {
        contents.add({
          "role": msg['role'] == 'USER' ? "user" : "model",
          "parts": [
            {
              "text": msg['content'] ?? ""
            }
          ]
        });
      }
      
      // Ajouter le prompt actuel s'il n'est pas vide et n'est pas déjà inclus dans le contexte
      if (prompt.isNotEmpty) {
        contents.add({
          "role": "user",
          "parts": [
            {
              "text": prompt
            }
          ]
        });
      }
      
      // Construire le corps de la requête
      final body = jsonEncode({
        "contents": contents,
        "generationConfig": {
          "temperature": 0.7,
          "topK": 40,
          "topP": 0.95,
          "maxOutputTokens": 1024,
        }
      });
      
      print('Requête Gemini: $body');
      
      // Envoyer la requête
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: body,
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Extraire le texte de la réponse
        if (data['candidates'] != null && 
            data['candidates'].isNotEmpty && 
            data['candidates'][0]['content'] != null &&
            data['candidates'][0]['content']['parts'] != null &&
            data['candidates'][0]['content']['parts'].isNotEmpty) {
          return data['candidates'][0]['content']['parts'][0]['text'];
        }
        
        return "Désolé, je n'ai pas pu générer une réponse appropriée.";
      } else {
        print('Erreur API Gemini: ${response.statusCode} - ${response.body}');
        return "Une erreur s'est produite lors de la communication avec l'API Gemini (${response.statusCode}).";
      }
    } catch (e) {
      print('Exception lors de la génération de réponse Gemini: $e');
      return "Une erreur s'est produite: $e";
    }
  }
  
  /// Construit un prompt enrichi avec des informations écologiques
  String _buildEcologicalPrompt(String userPrompt) {
    final StringBuilder sb = StringBuilder();
    
    // Ajouter le prompt système
    sb.appendLine(_getSystemPrompt());
    
    // Ajouter le prompt utilisateur
    sb.appendLine("\nQuestion de l'utilisateur: $userPrompt");
    
    return sb.toString();
  }
  
  /// Obtient le prompt système qui définit le comportement du chatbot
  String _getSystemPrompt() {
    return """Tu es GreenBot, l'assistant écologique intelligent de l'application Greens, une application dédiée à aider les utilisateurs à adopter un mode de vie plus durable et écologique.

FONCTIONNALITÉS DE L'APPLICATION GREENS:
1. Objectifs écologiques personnalisés (EcoGoal):
   - Types: réduction des déchets, économie d'eau, économie d'énergie, achats durables, transport, personnalisé
   - Fréquences: quotidienne, hebdomadaire, mensuelle
   - Suivi de progression avec pourcentage d'accomplissement

2. Système de badges écologiques (EcoBadge):
   - Catégories: Actions Quotidiennes, Consommation Responsable, Mobilité Durable, Actions Communautaires, Badges Spéciaux
   - Niveaux: Débutant, Intermédiaire, Avancé, Expert
   - Débloqués en réalisant des actions écologiques spécifiques

3. Calcul d'empreinte carbone:
   - Analyse des habitudes de transport, alimentation, logement
   - Inclut l'empreinte numérique (streaming, emails, stockage cloud)
   - Suggestions personnalisées pour réduire son impact

4. Défis communautaires:
   - Participation à des défis écologiques en groupe
   - Classements et comparaisons d'empreinte carbone
   - Impact collectif visualisé et quantifié

5. Catalogue de produits écologiques:
   - Produits durables et éco-responsables
   - Alternatives aux produits conventionnels
   - Scanner de codes-barres pour vérifier l'impact environnemental

CONSIGNES:
- Sois informatif, précis et encourageant dans tes réponses
- Propose des conseils pratiques et applicables au quotidien
- Adapte tes réponses au contexte français (législation, habitudes, etc.)
- Utilise des données scientifiques fiables pour appuyer tes recommandations
- Évite le jargon technique sauf si nécessaire, et explique-le simplement
- Encourage l'utilisateur à utiliser les fonctionnalités de l'application
- Sois positif et motivant, sans culpabiliser l'utilisateur
- Réponds de manière concise et directe, en 2-3 paragraphes maximum

Lorsque tu mentionnes une fonctionnalité de l'application, explique brièvement comment l'utilisateur peut y accéder.""";
  }
}

/// Utilitaire pour construire des chaînes de caractères multilignes
class StringBuilder {
  final StringBuffer _buffer = StringBuffer();
  
  void appendLine(String line) {
    _buffer.writeln(line);
  }
  
  void append(String text) {
    _buffer.write(text);
  }
  
  @override
  String toString() {
    return _buffer.toString();
  }
}
