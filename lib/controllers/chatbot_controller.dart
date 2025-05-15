import 'package:flutter/material.dart';
import 'package:greens_app/models/chatbot_message.dart';
import 'package:greens_app/services/chatbot_ai_service.dart';

/// Contrôleur pour gérer les interactions avec le chatbot
class ChatbotController with ChangeNotifier {
  final ChatbotAIService _chatbotService = ChatbotAIService.instance;
  
  // Singleton
  static final ChatbotController _instance = ChatbotController._privateConstructor();
  
  factory ChatbotController() {
    return _instance;
  }
  
  ChatbotController._privateConstructor();
  
  static ChatbotController get instance => _instance;
  
  // Getters
  bool get isInitialized => _chatbotService.isConfigured;
  bool get isLoading => _chatbotService.isLoading;
  List<ChatbotMessage> get messages => _chatbotService.messages;
  
  /// Initialise le service chatbot avec les clés d'API
  Future<bool> initialize({required String huggingfaceApiKey}) async {
    try {
      await _chatbotService.initialize(
        huggingfaceApiKey: huggingfaceApiKey,
      );
      
      notifyListeners();
      return _chatbotService.isConfigured;
    } catch (e) {
      print('Erreur lors de l\'initialisation du chatbot: $e');
      return false;
    }
  }
  
  /// Envoie un message au chatbot et attend la réponse
  Future<ChatbotMessage> sendMessage(String message) async {
    try {
      final response = await _chatbotService.sendMessage(message);
      notifyListeners();
      return response;
    } catch (e) {
      print('Erreur lors de l\'envoi du message: $e');
      // Créer un message d'erreur
      final errorMessage = ChatbotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Désolé, une erreur est survenue lors de l\'envoi du message: $e',
        isUser: false,
        timestamp: DateTime.now(),
      );
      return errorMessage;
    }
  }
  
  /// Efface tous les messages
  void clearMessages() {
    messages.clear();
    notifyListeners();
  }
  
  /// Ajoute un message de bienvenue en mode hors ligne
  void addWelcomeMessageOffline() {
    messages.add(ChatbotMessage(
      id: 'offline_welcome',
      text: 'Bonjour ! Je suis EcoBot en mode hors ligne. Je peux vous donner des informations générales sur l\'écologie.',
      isUser: false,
      timestamp: DateTime.now(),
      suggestedActions: [
        'Comment réduire mon empreinte carbone ?',
        'Conseils pour économiser l\'énergie',
        'Comment recycler correctement ?',
      ],
    ));
    notifyListeners();
  }
  
  /// Ajoute un message de bienvenue pour Mistral
  void addWelcomeMessageMistral() {
    messages.add(ChatbotMessage(
      id: 'mistral_welcome',
      text: 'Bonjour ! Je suis EcoBot, propulsé par Mistral. Je peux vous aider en français pour toutes vos questions sur l\'écologie et le développement durable.',
      isUser: false,
      timestamp: DateTime.now(),
      suggestedActions: [
        'Comment réduire mon empreinte carbone ?',
        'Conseils pour économiser l\'énergie',
        'Comment recycler correctement ?',
      ],
    ));
    notifyListeners();
  }
} 