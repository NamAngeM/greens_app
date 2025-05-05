// lib/services/chatbot_service.dart
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:greens_app/models/chatbot_message.dart';
import 'package:uuid/uuid.dart';

/// Service qui gère la communication avec n8n pour le chatbot écologique
class N8nChatbotService extends ChangeNotifier {
  static final N8nChatbotService _instance = N8nChatbotService._internal();
  
  factory N8nChatbotService() {
    return _instance;
  }
  
  N8nChatbotService._internal();
  
  static N8nChatbotService get instance => _instance;
  
  final String _sessionId = const Uuid().v4();
  bool _isInitialized = false;
  String _n8nWebhookUrl = '';
  
  bool get isInitialized => _isInitialized;
  
  /// Initialise le service avec l'URL du webhook n8n
  Future<void> initialize({required String webhookUrl}) async {
    try {
      _n8nWebhookUrl = webhookUrl;
      
      // Vérifier que le webhook est accessible
      final response = await http.get(Uri.parse('$_n8nWebhookUrl/health'));
      
      if (response.statusCode == 200) {
        _isInitialized = true;
        print('N8nChatbotService initialisé avec succès');
      } else {
        print('Erreur lors de l\'initialisation de N8nChatbotService: ${response.statusCode}');
        _isInitialized = false;
      }
    } catch (e) {
      print('Exception lors de l\'initialisation de N8nChatbotService: $e');
      _isInitialized = false;
    }
  }
  
  /// Envoie un message au chatbot via n8n et récupère la réponse
  Future<String> getResponse(String message, {List<Map<String, dynamic>>? context}) async {
    if (!_isInitialized) {
      return "Le service n8n n'est pas initialisé. Veuillez vérifier votre configuration.";
    }
    
    try {
      // Préparer les données à envoyer à n8n
      final payload = {
        'message': message,
        'sessionId': _sessionId,
        'context': context ?? [],
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'eco_chatbot',
      };
      
      // Envoyer la requête à n8n
      final response = await http.post(
        Uri.parse('$_n8nWebhookUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['response'] ?? "Désolé, je n'ai pas pu comprendre votre demande.";
      } else {
        print('Erreur lors de la communication avec n8n: ${response.statusCode}');
        return "Désolé, une erreur s'est produite lors de la communication avec le service n8n.";
      }
    } catch (e) {
      print('Exception lors de la communication avec n8n: $e');
      return "Désolé, une erreur s'est produite: $e";
    }
  }
  
  /// Récupère des suggestions de questions basées sur le contexte actuel
  Future<List<String>> getSuggestions({String? currentTopic}) async {
    if (!_isInitialized) {
      return ["Comment réduire mon empreinte carbone ?", 
              "Quels sont les produits écologiques recommandés ?", 
              "Comment économiser l'eau au quotidien ?"];
    }
    
    try {
      final payload = {
        'sessionId': _sessionId,
        'currentTopic': currentTopic,
        'type': 'suggestions',
      };
      
      final response = await http.post(
        Uri.parse('$_n8nWebhookUrl/suggestions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return List<String>.from(responseData['suggestions'] ?? []);
      } else {
        return ["Comment réduire mon empreinte carbone ?", 
                "Quels sont les produits écologiques recommandés ?", 
                "Comment économiser l'eau au quotidien ?"];
      }
    } catch (e) {
      print('Exception lors de la récupération des suggestions: $e');
      return ["Comment réduire mon empreinte carbone ?", 
              "Quels sont les produits écologiques recommandés ?", 
              "Comment économiser l'eau au quotidien ?"];
    }
  }
  
  /// Exécute une action spécifique via n8n
  Future<String> executeAction(String actionId, Map<String, dynamic> parameters) async {
    if (!_isInitialized) {
      return "Le service n8n n'est pas initialisé. Veuillez vérifier votre configuration.";
    }
    
    try {
      final payload = {
        'actionId': actionId,
        'parameters': parameters,
        'sessionId': _sessionId,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'action',
      };
      
      final response = await http.post(
        Uri.parse('$_n8nWebhookUrl/action'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['response'] ?? "Action exécutée avec succès.";
      } else {
        print('Erreur lors de l\'exécution de l\'action: ${response.statusCode}');
        return "Désolé, l'action n'a pas pu être exécutée.";
      }
    } catch (e) {
      print('Exception lors de l\'exécution de l\'action: $e');
      return "Désolé, une erreur s'est produite lors de l'exécution de l'action: $e";
    }
  }
}

class ChatbotService extends ChangeNotifier {
  static final ChatbotService _instance = ChatbotService._internal();
  
  factory ChatbotService() {
    return _instance;
  }
  
  ChatbotService._internal() : _n8nWebhookUrl = '';
  
  static ChatbotService get instance => _instance;
  
  // Méthode pour créer une instance avec une initialisation asynchrone
  static Future<ChatbotService> createInstance() async {
    return _instance;
  }
  
  final String _n8nWebhookUrl;
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
      
      // Vérifier que le webhook est accessible
      final response = await http.get(Uri.parse('$_webhookUrl/health'));
      
      if (response.statusCode == 200) {
        _isInitialized = true;
        print('ChatbotService initialisé avec succès');
      } else {
        print('Erreur lors de l\'initialisation de ChatbotService: ${response.statusCode}');
        _isInitialized = false;
      }
    } catch (e) {
      print('Exception lors de l\'initialisation de ChatbotService: $e');
      _isInitialized = false;
    }
  }

  /// Envoie un message au chatbot via n8n et récupère la réponse
  Future<String> getResponse(String message, {List<Map<String, dynamic>>? context}) async {
    if (!_isInitialized) {
      return "Le service n8n n'est pas initialisé. Veuillez vérifier votre configuration.";
    }
    
    try {
      // Préparer les données à envoyer à n8n
      final payload = {
        'message': message,
        'sessionId': DateTime.now().millisecondsSinceEpoch.toString(),
        'context': context ?? [],
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'eco_chatbot',
      };
      
      // Envoyer la requête à n8n
      final response = await http.post(
        Uri.parse('$_webhookUrl/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );
      
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['response'] ?? "Désolé, je n'ai pas pu comprendre votre demande.";
      } else {
        print('Erreur lors de la communication avec n8n: ${response.statusCode}');
        return "Désolé, une erreur s'est produite lors de la communication avec le service n8n.";
      }
    } catch (e) {
      print('Exception lors de la communication avec n8n: $e');
      return "Désolé, une erreur s'est produite: $e";
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

      // Préparer les données à envoyer à n8n
      final payload = {
        'message': message,
        'userId': userId,
        'context': {
          'previousMessages': _messages
              .where((msg) => _messages.indexOf(msg) >= _messages.length - 5)
              .map((msg) => {
                    'text': msg.text,
                    'isUser': msg.isUser,
                    'timestamp': msg.timestamp.toIso8601String(),
                  })
              .toList(),
          'timestamp': DateTime.now().toIso8601String(),
        },
      };

      // Envoyer la requête à n8n
      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        // Traiter la réponse
        final responseData = jsonDecode(response.body);
        final botMessage = ChatbotMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: responseData['response'] ?? 'Désolé, je n\'ai pas pu comprendre votre demande.',
          isUser: false,
          timestamp: DateTime.now(),
          suggestions: List<String>.from(responseData['suggestions'] ?? []),
          actions: Map<String, dynamic>.from(responseData['actions'] ?? {}),
        );

        _messages.add(botMessage);
        _isLoading = false;
        notifyListeners();
        return botMessage;
      } else {
        // Gérer l'erreur
        final errorMessage = ChatbotMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'Désolé, une erreur est survenue. Veuillez réessayer plus tard.',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(errorMessage);
        _isLoading = false;
        notifyListeners();
        return errorMessage;
      }
    } catch (e) {
      // Gérer les exceptions
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

  /// Exécute une action spécifique du chatbot
  Future<void> executeAction(String actionId, Map<String, dynamic> parameters) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Préparer les données à envoyer à n8n
      final payload = {
        'actionId': actionId,
        'parameters': parameters,
        'userId': parameters['userId'] ?? '',
      };

      // Envoyer la requête à n8n
      final response = await http.post(
        Uri.parse('$_webhookUrl/action'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200) {
        // Traiter la réponse
        final responseData = jsonDecode(response.body);
        final botMessage = ChatbotMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: responseData['response'] ?? 'Action exécutée avec succès.',
          isUser: false,
          timestamp: DateTime.now(),
        );

        _messages.add(botMessage);
      } else {
        // Gérer l'erreur
        final errorMessage = ChatbotMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'Désolé, l\'action n\'a pas pu être exécutée.',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(errorMessage);
      }
    } catch (e) {
      // Gérer les exceptions
      final errorMessage = ChatbotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Erreur lors de l\'exécution de l\'action: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Efface l'historique des messages
  void clearMessages() {
    _messages.clear();
    notifyListeners();
  }
}