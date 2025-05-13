import 'package:flutter/material.dart';
import 'dart:async';
import 'package:greens_app/services/rasa_service.dart';
import 'package:greens_app/services/ollama_service.dart';
import 'package:greens_app/models/chatbot_message.dart';
import 'package:uuid/uuid.dart';

/// Service hybride qui combine Rasa et Ollama pour créer un chatbot puissant
class HybridChatbotService extends ChangeNotifier {
  // Singleton pattern
  static final HybridChatbotService _instance = HybridChatbotService._internal();
  factory HybridChatbotService() => _instance;
  static HybridChatbotService get instance => _instance;

  // Services
  final RasaService _rasaService = RasaService();
  final OllamaService _ollamaService = OllamaService();
  
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
  
  // Nouveaux getters pour accéder à la disponibilité des services
  bool get isRasaAvailable => _rasaService.isInitialized;
  bool get isOllamaAvailable => _ollamaService.isInitialized;

  HybridChatbotService._internal();

  /// Initialiser le service
  Future<void> initialize({
    String? rasaUrl,
    String? ollamaUrl,
    String? ollamaModel,
  }) async {
    try {
      // Essayer d'initialiser Rasa mais ne pas bloquer si ça échoue
      try {
        await _rasaService.initialize(baseUrl: rasaUrl);
      } catch (e) {
        print('Avertissement: Impossible d\'initialiser Rasa: $e');
        // Continuer sans Rasa
      }
      
      // Essayer d'initialiser Ollama mais ne pas bloquer si ça échoue
      try {
        await _ollamaService.initialize(
          baseUrl: ollamaUrl,
          defaultModel: ollamaModel,
        );
      } catch (e) {
        print('Avertissement: Impossible d\'initialiser Ollama: $e');
        // Continuer sans Ollama
      }
      
      _isInitialized = _rasaService.isInitialized || _ollamaService.isInitialized;
      
      if (_isInitialized) {
        print('HybridChatbotService initialisé avec succès');
        print('  - Rasa disponible: ${_rasaService.isInitialized}');
        print('  - Ollama disponible: ${_ollamaService.isInitialized}');
      } else {
        print('HybridChatbotService: aucun service de backend n\'est disponible');
      }
      
      notifyListeners();
    } catch (e) {
      print('Exception lors de l\'initialisation de HybridChatbotService: $e');
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
      
      // Traitement hybride: utiliser Rasa si disponible, sinon utiliser Ollama
      if (_rasaService.isInitialized) {
        // 1. Traiter avec Rasa pour obtenir l'intention et les actions
        final rasaResponses = await _rasaService.sendMessage(
          message,
          senderId: _sessionId,
        );
        
        // Vérifier si on doit enrichir la réponse avec Ollama
        final shouldEnrich = _shouldEnrichWithLLM(rasaResponses);
        
        if (shouldEnrich && _ollamaService.isInitialized) {
          // 2. Enrichir la réponse avec Ollama
          final String rasaText = _extractTextFromRasaResponses(rasaResponses);
          final String ollamaPrompt = _buildOllamaPrompt(message, rasaText);
          final String enrichedResponse = await _ollamaService.generateResponse(ollamaPrompt);
          
          // Remplacer le texte Rasa par la réponse enrichie d'Ollama
          for (final response in rasaResponses) {
            if (response.containsKey('text')) {
              response['text'] = enrichedResponse;
              break; // Ne remplacer que la première réponse textuelle
            }
          }
        }
        
        // Traiter la réponse Rasa (enrichie ou non)
        botResponse = _rasaService.processRasaResponse(rasaResponses, _sessionId);
      } else if (_ollamaService.isInitialized) {
        // Utiliser uniquement Ollama si Rasa n'est pas disponible
        final String ollamaPrompt = _buildOllamaPrompt(message, null);
        final String response = await _ollamaService.generateResponse(ollamaPrompt);
        
        botResponse = ChatbotMessage(
          id: '${DateTime.now().millisecondsSinceEpoch}_ollama',
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
  
  /// Déterminer si une réponse Rasa doit être enrichie avec le LLM
  bool _shouldEnrichWithLLM(List<Map<String, dynamic>> rasaResponses) {
    // Si la réponse contient un marqueur spécifique
    for (final response in rasaResponses) {
      if (response.containsKey('text') && 
          response['text'].toString().contains('[enrichir]')) {
        return true;
      }
    }
    
    // Sinon, enrichir les réponses plus longues (probablement des explications)
    for (final response in rasaResponses) {
      if (response.containsKey('text') && 
          response['text'].toString().length > 50) {
        return true;
      }
    }
    
    return false;
  }
  
  /// Extraire le texte des réponses Rasa
  String _extractTextFromRasaResponses(List<Map<String, dynamic>> responses) {
    final texts = <String>[];
    
    for (final response in responses) {
      if (response.containsKey('text')) {
        // Supprimer le marqueur [enrichir] s'il existe
        String text = response['text'].toString();
        text = text.replaceAll('[enrichir]', '').trim();
        texts.add(text);
      }
    }
    
    return texts.join('\n\n');
  }
  
  /// Construire un prompt pour Ollama basé sur le message et la réponse Rasa
  String _buildOllamaPrompt(String userMessage, String? rasaResponse) {
    final StringBuilder promptBuilder = StringBuilder();
    
    // Ajouter le contexte optimisé pour Llama3
    promptBuilder.appendLine("<|system|>\nTu es GreenBot, un assistant écologique spécialisé dans le développement durable, les éco-gestes et la réduction de l'empreinte carbone. Tu donnes des réponses amicales, concises et informatives, en te concentrant sur les aspects écologiques et durables. Tu fournis des conseils pratiques et des explications scientifiques simples.\n</|system|>");
    
    // Ajouter l'historique récent des messages (limité aux derniers échanges)
    final recentMessages = _messages.length > 4 
        ? _messages.sublist(_messages.length - 4) 
        : _messages;
    
    for (final msg in recentMessages) {
      if (msg.isUser) {
        promptBuilder.appendLine("<|user|>\n${msg.text}\n</|user|>");
      } else {
        promptBuilder.appendLine("<|assistant|>\n${msg.text}\n</|assistant|>");
      }
    }
    
    // Ajouter le message actuel
    promptBuilder.appendLine("<|user|>\n$userMessage\n</|user|>");
    
    // Si nous avons une réponse Rasa, donner un contexte supplémentaire
    if (rasaResponse != null && rasaResponse.isNotEmpty) {
      promptBuilder.appendLine("\n<|system|>\nInformation contextuelle (à reformuler et enrichir):\n$rasaResponse\nRéponds en réutilisant ces informations de manière naturelle et conversationnelle.\n</|system|>");
    }
    
    promptBuilder.appendLine("<|assistant|>");
    
    return promptBuilder.toString();
  }
  
  /// Générer une réponse en mode hors ligne
  ChatbotMessage _getOfflineResponse(String message) {
    // Liste de réponses prédéfinies sur l'écologie
    final List<String> offlineResponses = [
      "En mode hors ligne, je ne peux pas utiliser toutes mes capacités. Pour une expérience complète, veuillez vérifier la connexion aux services Rasa et Ollama.",
      "Le saviez-vous ? Recycler une tonne de papier permet de sauver environ 17 arbres.",
      "Un conseil écologique : éteignez les appareils électroniques au lieu de les laisser en veille pour économiser de l'énergie.",
      "Pour réduire votre empreinte carbone, privilégiez les transports en commun ou le vélo pour vos déplacements quotidiens.",
      "Le compostage des déchets organiques peut réduire jusqu'à 30% le volume de vos poubelles.",
      "Les ampoules LED consomment jusqu'à 80% d'énergie en moins et durent jusqu'à 25 fois plus longtemps que les ampoules à incandescence.",
      "Réduisez votre consommation d'eau en prenant des douches plus courtes et en fermant le robinet pendant que vous vous brossez les dents.",
      "Acheter local permet de réduire les émissions de CO2 liées au transport des aliments.",
    ];
    
    String responseText;
    List<String> suggestions = [];
    
    // Détecter le contexte du message de l'utilisateur
    message = message.toLowerCase();
    if (message.contains('recycl') || message.contains('déchets') || message.contains('poubelle')) {
      responseText = "Le recyclage est essentiel pour réduire les déchets. Triez vos déchets selon les consignes locales et pensez à composter vos déchets organiques.";
      suggestions = ["Comment composter ?", "Types de recyclage", "Réduire mes déchets"];
    } else if (message.contains('energie') || message.contains('électr') || message.contains('consomm')) {
      responseText = "Pour économiser l'énergie, utilisez des appareils à haute efficacité énergétique, isolez votre maison et éteignez les lumières quand vous quittez une pièce.";
      suggestions = ["Économies d'énergie", "Panneaux solaires", "Isolation écologique"];
    } else if (message.contains('transport') || message.contains('voiture')) {
      responseText = "Les transports représentent une part importante de notre empreinte carbone. Privilégiez la marche, le vélo ou les transports en commun quand c'est possible.";
      suggestions = ["Empreinte des transports", "Mobilité douce", "Covoiturage"];
    } else if (message.contains('aliment') || message.contains('mang') || message.contains('cuisine')) {
      responseText = "Une alimentation durable privilégie les produits locaux, de saison et limite le gaspillage alimentaire. Réduire sa consommation de viande a aussi un impact positif sur l'environnement.";
      suggestions = ["Alimentation durable", "Réduire le gaspillage", "Recettes végétariennes"];
    } else {
      // Réponse par défaut
      responseText = offlineResponses[DateTime.now().microsecond % offlineResponses.length];
      suggestions = ["Conseils écologiques", "Économies d'énergie", "Recyclage"];
    }
    
    return ChatbotMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_offline',
      text: responseText,
      isUser: false,
      timestamp: DateTime.now(),
      suggestedActions: suggestions,
    );
  }
  
  /// Effacer l'historique des messages
  void clearHistory() {
    _messages.clear();
    notifyListeners();
  }
  
  /// Ajouter un message manuellement
  void addMessage(ChatbotMessage message) {
    _messages.add(message);
    notifyListeners();
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