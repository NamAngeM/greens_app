import 'package:flutter/material.dart';
import 'dart:async';
import 'package:greens_app/models/chatbot_message.dart';
import 'package:greens_app/services/gemini_service.dart';
import 'package:uuid/uuid.dart';

/// Service de chatbot qui utilise exclusivement l'API Gemini de Google
class GeminiChatbotService extends ChangeNotifier {
  // Singleton pattern
  static final GeminiChatbotService _instance = GeminiChatbotService._internal();
  factory GeminiChatbotService() => _instance;
  static GeminiChatbotService get instance => _instance;

  // Service Gemini
  final GeminiService _geminiService = GeminiService.instance;
  
  // État
  bool _isInitialized = false;
  final List<ChatbotMessage> _messages = [];
  bool _isProcessing = false;
  final String _sessionId = const Uuid().v4();
  
  // Getters
  bool get isInitialized => _isInitialized;
  List<ChatbotMessage> get messages => List.unmodifiable(_messages);
  bool get isProcessing => _isProcessing;
  String get sessionId => _sessionId;

  GeminiChatbotService._internal();

  /// Initialiser le service
  Future<void> initialize({required String apiKey}) async {
    try {
      // Initialiser le service Gemini
      await _geminiService.initialize(apiKey: apiKey);
      
      _isInitialized = _geminiService.isInitialized;
      
      if (_isInitialized) {
        print('GeminiChatbotService initialisé avec succès');
        print('  - Modèle: ${_geminiService.model}');
      } else {
        print('GeminiChatbotService: échec de l\'initialisation');
      }
      
      notifyListeners();
    } catch (e) {
      print('Exception lors de l\'initialisation de GeminiChatbotService: $e');
      _isInitialized = false;
      notifyListeners();
    }
  }

  /// Envoyer un message et obtenir une réponse
  Future<ChatbotMessage> sendMessage(String message, {ChatbotMessage? initialMessage}) async {
    try {
      _isProcessing = true;
      notifyListeners();
      
      // Si un message initial est fourni, utiliser directement ce message
      if (initialMessage != null) {
        _messages.add(initialMessage);
        _isProcessing = false;
        notifyListeners();
        return initialMessage;
      }
      
      // Créer le message utilisateur
      final userMessage = ChatbotMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_user',
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      );
      
      // Ajouter le message utilisateur
      _messages.add(userMessage);
      notifyListeners();
      
      ChatbotMessage botResponse;
      
      if (_isInitialized) {
        // Construire le contexte de la conversation pour Gemini
        final context = _buildConversationContext();
        
        // Envoyer le message à Gemini avec le contexte
        final String response = await _geminiService.generateResponseWithContext(message, context);
        
        botResponse = ChatbotMessage(
          id: '${DateTime.now().millisecondsSinceEpoch}_gemini',
          text: response,
          isUser: false,
          timestamp: DateTime.now(),
        );
      } else {
        // Mode autonome : aucun service disponible
        botResponse = _getOfflineResponse(message);
      }
      
      // Ajouter la réponse du bot
      _messages.add(botResponse);
      
      _isProcessing = false;
      notifyListeners();
      
      return botResponse;
    } catch (e) {
      print('Exception lors de l\'envoi du message: $e');
      
      // Créer un message d'erreur
      final errorResponse = ChatbotMessage(
        id: '${DateTime.now().millisecondsSinceEpoch}_error',
        text: "Une erreur s'est produite: $e",
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      _messages.add(errorResponse);
      
      _isProcessing = false;
      notifyListeners();
      
      return errorResponse;
    }
  }
  
  /// Construire le contexte de la conversation pour Gemini
  List<Map<String, dynamic>> _buildConversationContext() {
    // Limiter le contexte aux 10 derniers messages pour éviter de dépasser les limites de tokens
    final recentMessages = _messages.length > 10 
        ? _messages.sublist(_messages.length - 10) 
        : _messages;
    
    return recentMessages.map((msg) => {
      'role': msg.isUser ? 'USER' : 'ASSISTANT',
      'content': msg.text,
    }).toList();
  }
  
  /// Obtenir une réponse en mode hors ligne
  ChatbotMessage _getOfflineResponse(String message) {
    String response = "Je suis désolé, mais je ne peux pas vous répondre pour le moment car le service Gemini n'est pas disponible. Veuillez vérifier votre connexion internet et votre clé API.";
    
    if (message.toLowerCase().contains('bonjour') || 
        message.toLowerCase().contains('salut') || 
        message.toLowerCase().contains('hello')) {
      response = "Bonjour ! Je suis désolé, mais je fonctionne actuellement en mode hors ligne. Veuillez vérifier votre connexion internet et votre clé API Gemini.";
    } else if (message.toLowerCase().contains('aide') || 
               message.toLowerCase().contains('help')) {
      response = "Pour utiliser le chatbot, vous devez configurer une clé API Gemini valide. Voici comment faire :\n\n"
                "1. Obtenez une clé API sur https://makersuite.google.com/app/apikey\n"
                "2. Entrez cette clé dans les paramètres du chatbot\n\n"
                "Si vous avez besoin d'aide supplémentaire, consultez la documentation de l'application.";
    }
    
    return ChatbotMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_offline',
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );
  }
  
  /// Effacer l'historique des messages
  void clearHistory() {
    _messages.clear();
    notifyListeners();
  }
  
  /// Ajouter un message manuellement (utile pour les tests)
  void addMessage(ChatbotMessage message) {
    _messages.add(message);
    notifyListeners();
  }
}
