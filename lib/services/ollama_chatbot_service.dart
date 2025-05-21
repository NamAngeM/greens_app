import 'package:flutter/foundation.dart';
import 'package:greens_app/services/ollama_service.dart';

/// Service de chatbot qui utilise Ollama en local
class OllamaChatbotService extends ChangeNotifier {
  static final OllamaChatbotService _instance = OllamaChatbotService._internal();
  factory OllamaChatbotService() => _instance;
  static OllamaChatbotService get instance => _instance;

  // Service Ollama
  final OllamaService _ollamaService = OllamaService.instance;

  // État du service
  bool _isInitialized = false;
  bool _isLoading = false;
  List<Map<String, String>> _conversationHistory = [];

  // Getters
  bool get isInitialized => _isInitialized;
  bool get isLoading => _isLoading;
  List<Map<String, String>> get conversationHistory => _conversationHistory;

  OllamaChatbotService._internal();

  /// Initialise le service de chatbot
  Future<bool> initialize({String model = 'llama2'}) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Initialiser le service Ollama
      _isInitialized = await _ollamaService.initialize(model: model);

      _isLoading = false;
      notifyListeners();

      if (_isInitialized) {
        print('OllamaChatbotService initialisé avec succès');
        print('  - Modèle: ${_ollamaService.model}');
      } else {
        print('OllamaChatbotService: échec de l\'initialisation');
      }

      return _isInitialized;
    } catch (e) {
      print('Exception lors de l\'initialisation de OllamaChatbotService: $e');
      _isInitialized = false;
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  /// Envoie un message au chatbot et obtient une réponse
  Future<Map<String, String>> sendMessage(String message) async {
    if (!_isInitialized) {
      return {
        'id': '${DateTime.now().millisecondsSinceEpoch}_error',
        'role': 'assistant',
        'content': "Le service n'est pas initialisé. Veuillez vérifier que Ollama est en cours d'exécution.",
      };
    }

    try {
      _isLoading = true;
      notifyListeners();

      // Ajouter le message de l'utilisateur à l'historique
      final userMessage = {
        'id': '${DateTime.now().millisecondsSinceEpoch}_user',
        'role': 'user',
        'content': message,
      };
      _conversationHistory.add(userMessage);

      // Envoyer le message à Ollama avec le contexte
      final String response = await _ollamaService.generateResponseWithContext(
        message,
        _conversationHistory,
      );

      // Ajouter la réponse à l'historique
      final assistantMessage = {
        'id': '${DateTime.now().millisecondsSinceEpoch}_assistant',
        'role': 'assistant',
        'content': response,
      };
      _conversationHistory.add(assistantMessage);

      _isLoading = false;
      notifyListeners();

      return assistantMessage;
    } catch (e) {
      print('Exception lors de l\'envoi du message: $e');
      _isLoading = false;
      notifyListeners();

      return {
        'id': '${DateTime.now().millisecondsSinceEpoch}_error',
        'role': 'assistant',
        'content': "Une erreur s'est produite lors de la communication avec le chatbot.",
      };
    }
  }

  /// Efface l'historique de la conversation
  void clearConversation() {
    _conversationHistory.clear();
    notifyListeners();
  }
} 