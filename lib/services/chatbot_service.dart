// lib/services/chatbot_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:greens_app/models/chatbot_message.dart';
import 'package:uuid/uuid.dart';

/// Modèle pour représenter le contexte d'une conversation
class ChatContext {
  final String message;
  final String sessionId;
  final List<Map<String, dynamic>> previousMessages;
  final DateTime timestamp;
  final String type;

  ChatContext({
    required this.message,
    required this.sessionId,
    required this.previousMessages,
    required this.timestamp,
    this.type = 'eco_chatbot',
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'sessionId': sessionId,
      'context': previousMessages,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
    };
  }
}

/// Service qui gère la communication avec n8n pour le chatbot écologique
class ChatbotService extends ChangeNotifier {
  static final ChatbotService _instance = ChatbotService._internal();
  
  factory ChatbotService() {
    return _instance;
  }
  
  ChatbotService._internal() : _sessionId = const Uuid().v4();
  
  static ChatbotService get instance => _instance;
  
  // Méthode pour créer une instance avec une initialisation asynchrone
  static Future<ChatbotService> createInstance() async {
    return _instance;
  }
  
  final String _sessionId;
  String _webhookUrl = '';
  final List<ChatbotMessage> _messages = [];
  bool _isLoading = false;
  bool _isInitialized = false;

  List<ChatbotMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  /// Initialise le service avec l'URL du webhook n8n
  Future<void> initialize({required String webhookUrl}) async {
    try {
      _webhookUrl = webhookUrl;
      
      // On considère le service comme initialisé sans vérification préalable
      // car l'endpoint /health n'est pas standard dans tous les webhooks n8n
      _isInitialized = true;
      print('ChatbotService initialisé avec succès: $_webhookUrl');
      
      // Envoyer un message de test pour vérifier la connexion
      try {
        final testContext = ChatContext(
          message: 'test_connection',
          sessionId: _sessionId,
          previousMessages: [],
          timestamp: DateTime.now(),
          type: 'connection_test',
        );
        
        final response = await http.post(
          Uri.parse(_webhookUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(testContext.toJson()),
        ).timeout(const Duration(seconds: 5));
        
        print('Test de connexion n8n: ${response.statusCode} - ${response.body}');
      } catch (e) {
        // On ne change pas l'état d'initialisation même si le test échoue
        print('Test de connexion n8n échoué, mais le service reste initialisé: $e');
      }
    } catch (e) {
      print('Exception lors de l\'initialisation de ChatbotService: $e');
      _isInitialized = false;
    }
  }

  /// Envoie un message au chatbot via n8n et récupère la réponse
  Future<String> getResponse(String message, {List<Map<String, dynamic>>? context}) async {
    if (!_isInitialized) {
      return "Le service n'est pas initialisé. Veuillez vérifier votre configuration.";
    }
    
    try {
      // Préparer le contexte de la conversation
      final chatContext = ChatContext(
        message: message,
        sessionId: _sessionId,
        previousMessages: context ?? [],
        timestamp: DateTime.now(),
      );
      
      print('Envoi de la requête à n8n: $_webhookUrl');
      print('Payload: ${jsonEncode(chatContext.toJson())}');
      
      // Envoyer la requête à n8n
      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(chatContext.toJson()),
      ).timeout(const Duration(seconds: 30));
      
      print('Réponse de n8n: ${response.statusCode}');
      print('Corps de la réponse: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final responseData = jsonDecode(response.body);
          return responseData['response'] ?? "J'ai bien reçu votre message, mais je n'ai pas de réponse spécifique.";
        } catch (e) {
          // Si la réponse n'est pas du JSON valide, retourner le corps de la réponse directement
          return response.body;
        }
      } else {
        print('Erreur lors de la communication avec n8n: ${response.statusCode}');
        return "Désolé, une erreur s'est produite lors de la communication avec le service (code ${response.statusCode}).";
      }
    } catch (e) {
      print('Exception lors de la communication avec n8n: $e');
      return "Désolé, une erreur s'est produite lors de la communication: $e";
    }
  }

  /// Envoie un message au chatbot via n8n et récupère la réponse
  Future<ChatbotMessage> sendMessage(String message, {String userId = ''}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Ajouter le message de l'utilisateur à la liste
      final userMessage = ChatbotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);
      notifyListeners();

      // Récupérer la réponse via getResponse
      final responseText = await getResponse(message, 
        context: _messages
          .where((msg) => _messages.indexOf(msg) >= _messages.length - 5)
          .map((msg) => {
                'text': msg.text,
                'isUser': msg.isUser,
                'timestamp': msg.timestamp.toIso8601String(),
              })
          .toList()
      );

      // Créer le message de réponse
      final botMessage = ChatbotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: responseText,
        isUser: false,
        timestamp: DateTime.now(),
        suggestions: [], // Pas de suggestions pour l'instant
        actions: {}, // Pas d'actions pour l'instant
      );

      _messages.add(botMessage);
      _isLoading = false;
      notifyListeners();
      return botMessage;
    } catch (e) {
      // Gérer l'erreur
      final errorMessage = ChatbotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Désolé, une erreur est survenue: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );

      _messages.add(errorMessage);
      _isLoading = false;
      notifyListeners();
      return errorMessage;
    }
  }

  /// Efface l'historique des messages
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
  
  /// Récupère des suggestions de questions basées sur le contexte actuel
  Future<List<String>> getSuggestions() async {
    if (!_isInitialized) {
      return [
        "Comment réduire mon empreinte carbone ?", 
        "Quels sont les produits écologiques recommandés ?", 
        "Comment économiser l'eau au quotidien ?"
      ];
    }
    
    try {
      final context = ChatContext(
        message: '',
        sessionId: _sessionId,
        previousMessages: _messages
          .take(5)
          .map((msg) => {
                'text': msg.text,
                'isUser': msg.isUser,
                'timestamp': msg.timestamp.toIso8601String(),
              })
          .toList(),
        timestamp: DateTime.now(),
        type: 'suggestions',
      );
      
      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(context.toJson()),
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        if (responseData['suggestions'] != null && responseData['suggestions'] is List) {
          return List<String>.from(responseData['suggestions']);
        }
      }
    } catch (e) {
      print('Erreur lors de la récupération des suggestions: $e');
    }
    
    // Suggestions par défaut en cas d'erreur
    return [
      "Comment réduire mon empreinte carbone ?", 
      "Quels sont les produits écologiques recommandés ?", 
      "Comment économiser l'eau au quotidien ?"
    ];
  }
}