import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import '../models/chatbot_model.dart';
import '../../articles/services/article_recommendation_service.dart';
import '../../user_profile/models/environmental_profile.dart';
import '../../product_scanner/models/product.dart';
import '../../../services/ollama_service.dart';

class ChatbotService {
  // Singleton instance
  static final ChatbotService _instance = ChatbotService._internal();
  factory ChatbotService() => _instance;
  ChatbotService._internal();

  // État et données
  final List<EcobotSession> _sessions = [];
  EcobotSession? _activeSession;
  final StreamController<EcobotSession> _sessionStreamController = StreamController<EcobotSession>.broadcast();
  
  // Intégration avec d'autres services
  final OllamaService _ollamaService = OllamaService();
  final ArticleRecommendationService _articleService = ArticleRecommendationService();

  // Getters
  Stream<EcobotSession> get sessionStream => _sessionStreamController.stream;
  List<EcobotSession> get sessions => List.unmodifiable(_sessions);
  EcobotSession? get activeSession => _activeSession;

  // Initialisation du service
  Future<void> initialize() async {
    // Créer une session par défaut si aucune n'existe
    if (_sessions.isEmpty) {
      final defaultSession = EcobotSession.newSession();
      _sessions.add(defaultSession);
      _activeSession = defaultSession;
      _sessionStreamController.add(defaultSession);
    }
    
    // Initialiser le service Ollama
    await _ollamaService.initialize();
  }

  // Créer une nouvelle session
  EcobotSession createNewSession() {
    final newSession = EcobotSession.newSession();
    _sessions.add(newSession);
    _activeSession = newSession;
    _sessionStreamController.add(newSession);
    return newSession;
  }

  // Définir la session active
  void setActiveSession(String sessionId) {
    final session = _sessions.firstWhere(
      (s) => s.id == sessionId,
      orElse: () => createNewSession(),
    );
    _activeSession = session;
    _sessionStreamController.add(session);
  }

  // Envoyer un message utilisateur et obtenir une réponse
  Future<EcobotSession> sendMessage(String message) async {
    if (_activeSession == null) {
      setActiveSession(createNewSession().id);
    }
    
    // Créer et ajouter le message utilisateur
    final userMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message,
      sender: MessageSender.user,
    );
    
    _activeSession = _activeSession!.addMessage(userMessage);
    _sessionStreamController.add(_activeSession!);
    
    // Mettre à jour le topic de la session basé sur les messages
    if (_activeSession!.messages.length <= 2) {
      final newTopic = _activeSession!.determineTopic();
      _activeSession = _activeSession!.copyWith(topic: newTopic);
    }
    
    // Générer et ajouter la réponse du bot
    try {
      // Préparer le contexte pour la réponse
      final botResponse = await _generateBotResponse(message);
      
      // Créer le message de réponse
      final botMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: botResponse.text,
        sender: MessageSender.bot,
        actionSuggestions: botResponse.suggestions,
        additionalData: botResponse.additionalData,
      );
      
      // Mettre à jour la session
      _activeSession = _activeSession!.addMessage(botMessage);
      _sessionStreamController.add(_activeSession!);
      
      // Mettre à jour la liste des sessions
      final sessionIndex = _sessions.indexWhere((s) => s.id == _activeSession!.id);
      if (sessionIndex != -1) {
        _sessions[sessionIndex] = _activeSession!;
      }
      
      return _activeSession!;
    } catch (e) {
      // En cas d'erreur, envoyer un message d'erreur
      final errorMessage = ChatMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: 'Désolé, je rencontre des difficultés à répondre. Pouvez-vous reformuler votre question ou réessayer plus tard?',
        sender: MessageSender.bot,
      );
      
      _activeSession = _activeSession!.addMessage(errorMessage);
      _sessionStreamController.add(_activeSession!);
      
      return _activeSession!;
    }
  }

  // Structure pour la réponse générée
  class BotResponseData {
    final String text;
    final List<String>? suggestions;
    final Map<String, dynamic>? additionalData;

    BotResponseData({
      required this.text,
      this.suggestions,
      this.additionalData,
    });
  }

  // Générer une réponse intelligente
  Future<BotResponseData> _generateBotResponse(String userMessage) async {
    // Vérifier si Ollama est disponible
    final isOllamaAvailable = await _ollamaService.isOllamaAvailable();
    
    if (isOllamaAvailable) {
      try {
        // Préparer le prompt pour Ollama
        final systemPrompt = _prepareSystemPrompt();
        final userPrompt = userMessage;
        
        // Envoyer la demande à Ollama
        final response = await _ollamaService.sendPrompt(
          systemPrompt: systemPrompt,
          userPrompt: userPrompt,
        );
        
        // Analyser la réponse pour extraire les suggestions
        List<String>? suggestions = _extractSuggestionsFromResponse(response);
        
        // Pour certaines requêtes, ajouter des données supplémentaires
        Map<String, dynamic>? additionalData = await _generateAdditionalData(userMessage);
        
        return BotResponseData(
          text: response,
          suggestions: suggestions,
          additionalData: additionalData,
        );
      } catch (e) {
        // En cas d'erreur avec Ollama, utiliser la réponse de secours
        return _generateFallbackResponse(userMessage);
      }
    } else {
      // Si Ollama n'est pas disponible, utiliser la réponse de secours
      return _generateFallbackResponse(userMessage);
    }
  }

  // Préparer le prompt système pour Ollama
  String _prepareSystemPrompt() {
    return '''
Tu es EcoBot, un assistant virtuel écologique intégré dans une application mobile d'aide à la réduction de l'empreinte environnementale. Ton rôle est de fournir des informations précises et utiles sur les problématiques environnementales.

Règles à suivre:
1. Réponds toujours en français.
2. Sois précis, factuel et informatif.
3. Oriente tes réponses vers des actions concrètes que l'utilisateur peut entreprendre.
4. Privilégie les sources scientifiques et évite les affirmations non vérifiables.
5. Adapte ton niveau de détail selon la complexité de la question.
6. Explique les concepts écologiques de manière accessible sans être condescendant.
7. Si tu ne connais pas la réponse, propose de rediriger l'utilisateur vers des ressources fiables.

L'application dispose des fonctionnalités suivantes que tu peux suggérer:
- Scanner de produits (code-barres) pour connaître leur impact environnemental
- Calculateur d'empreinte carbone personnelle
- Recommandations d'articles sur l'écologie
- Tableau de bord de suivi des actions écologiques
- Défis écologiques communautaires

Réponds dans un format naturel et conversationnel, en évitant les formules trop protocolaires.
''';
  }

  // Extraire des suggestions de suivi de la réponse
  List<String>? _extractSuggestionsFromResponse(String response) {
    // Analyse simple : si la réponse contient des puces ou des numéros, extraire comme suggestions
    final List<String> suggestions = [];
    
    // Rechercher des patterns comme "1.", "•", "-" suivis de texte
    final regexBullets = RegExp(r'(?:\n|^)(?:\d+\.|•|-)\s+([^\n]+)');
    final matches = regexBullets.allMatches(response);
    
    for (var match in matches) {
      if (match.group(1) != null) {
        suggestions.add(match.group(1)!);
      }
    }
    
    // Si on a trouvé des suggestions, les retourner (max 4)
    if (suggestions.isNotEmpty) {
      return suggestions.take(4).toList();
    }
    
    // Sinon, générer des suggestions basées sur le contexte
    return _generateContextualSuggestions(response);
  }

  // Générer des suggestions contextuelles
  List<String>? _generateContextualSuggestions(String response) {
    // Mots-clés à rechercher et suggestions associées
    final Map<String, List<String>> keywordSuggestions = {
      'plastique': [
        'Comment réduire ma consommation de plastique ?',
        'Quels types de plastique sont recyclables ?',
      ],
      'empreinte carbone': [
        'Comment calculer mon empreinte carbone ?',
        'Quelles actions ont le plus d\'impact sur mon empreinte ?',
      ],
      'numérique': [
        'Comment réduire ma pollution numérique ?',
        'Quelle est l\'empreinte environnementale d\'un email ?',
      ],
      'bruit': [
        'Comment le bruit affecte-t-il l\'environnement ?',
        'Quelles sont les sources de pollution sonore ?',
      ],
      'eau': [
        'Comment économiser l\'eau au quotidien ?',
        'Quel est l\'impact environnemental des bouteilles d\'eau ?',
      ],
      'transport': [
        'Quel est le mode de transport le plus écologique ?',
        'Comment réduire l\'impact de mes déplacements ?',
      ],
    };
    
    final List<String> suggestions = [];
    
    // Parcourir les mots-clés et vérifier leur présence dans la réponse
    keywordSuggestions.forEach((keyword, keywordSuggestions) {
      if (response.toLowerCase().contains(keyword.toLowerCase())) {
        suggestions.addAll(keywordSuggestions);
      }
    });
    
    // Ajouter quelques suggestions générales
    final generalSuggestions = [
      'Pouvez-vous me donner plus de détails ?',
      'Comment puis-je appliquer ces conseils au quotidien ?',
      'Quels articles recommandez-vous sur ce sujet ?',
    ];
    
    // Mélanger toutes les suggestions et en prendre 3 ou 4
    final allSuggestions = [...suggestions, ...generalSuggestions];
    allSuggestions.shuffle(Random());
    
    return allSuggestions.take(min(4, allSuggestions.length)).toList();
  }

  // Générer des données supplémentaires pour enrichir la réponse
  Future<Map<String, dynamic>?> _generateAdditionalData(String userMessage) async {
    final Map<String, dynamic> additionalData = {};
    
    // Vérifier si le message est lié à des sujets spécifiques
    final lowerCaseMessage = userMessage.toLowerCase();
    
    // Ajouter des articles recommandés si pertinent
    if (lowerCaseMessage.contains('article') || 
        lowerCaseMessage.contains('lire') ||
        lowerCaseMessage.contains('apprendre') ||
        lowerCaseMessage.contains('information')) {
      
      final recommendedArticles = await _articleService.getArticleRecommendations(3);
      if (recommendedArticles.isNotEmpty) {
        additionalData['recommendedArticles'] = recommendedArticles.map((a) => {
          'id': a.id,
          'title': a.title,
          'summary': a.summary,
          'imageUrl': a.imageUrl,
        }).toList();
      }
    }
    
    // Ajouter des informations sur les produits si pertinent
    if (lowerCaseMessage.contains('produit') || 
        lowerCaseMessage.contains('scanner') ||
        lowerCaseMessage.contains('code-barre')) {
      
      additionalData['productScanTip'] = 'Pour scanner un produit, utilisez la fonction Scanner dans l\'application et visez le code-barre.';
    }
    
    return additionalData.isNotEmpty ? additionalData : null;
  }

  // Générer une réponse de secours si Ollama n'est pas disponible
  BotResponseData _generateFallbackResponse(String userMessage) {
    // Base de réponses prédéfinies
    final Map<String, String> predefinedResponses = {
      'bonjour': 'Bonjour ! Comment puis-je vous aider aujourd\'hui sur les questions environnementales ?',
      'merci': 'Avec plaisir ! N\'hésitez pas si vous avez d\'autres questions sur l\'environnement.',
      'plastique': 'Le plastique est un problème majeur pour l\'environnement. Pour réduire votre impact, privilégiez les alternatives réutilisables et évitez les emballages à usage unique. Le recyclage est important, mais la réduction à la source est encore plus efficace.',
      'empreinte carbone': 'L\'empreinte carbone mesure l\'impact de nos activités sur le climat. Les principaux facteurs sont le transport, l\'alimentation, le logement et la consommation de biens. Pour la réduire, limitez les voyages en avion, mangez plus végétal, isolez votre logement et achetez moins mais mieux.',
      'numérique': 'La pollution numérique représente 4% des émissions mondiales de CO2. Pour la réduire : gardez vos appareils plus longtemps, limitez le streaming vidéo en haute définition, nettoyez régulièrement vos emails et stockages cloud, et éteignez vos appareils quand vous ne les utilisez pas.',
      'bruit': 'La pollution sonore a des impacts sur la santé (stress, troubles du sommeil) et sur l\'environnement (perturbation des écosystèmes). Pour la réduire, utilisez des écouteurs à volume modéré, privilégiez les appareils silencieux, et respectez le calme dans les espaces naturels.',
    };
    
    // Rechercher des mots-clés dans le message
    String response = 'Je suis désolé, je n\'ai pas pu accéder à mes ressources complètes pour vous répondre. Voici ce que je peux vous dire sur ce sujet : ';
    bool foundKeyword = false;
    
    for (var keyword in predefinedResponses.keys) {
      if (userMessage.toLowerCase().contains(keyword)) {
        response += predefinedResponses[keyword]!;
        foundKeyword = true;
        break;
      }
    }
    
    // Réponse par défaut si aucun mot-clé n'est trouvé
    if (!foundKeyword) {
      response = 'Je suis désolé, je rencontre des difficultés techniques pour vous répondre de manière précise. Pourriez-vous reformuler votre question, ou réessayer plus tard quand la connexion sera meilleure ?';
    }
    
    // Suggestions génériques
    final List<String> genericSuggestions = [
      'Comment réduire mon empreinte écologique ?',
      'Quels sont les meilleurs gestes écologiques au quotidien ?',
      'Comment fonctionne le recyclage ?',
      'Qu\'est-ce que l\'éco-anxiété ?',
    ];
    
    return BotResponseData(
      text: response,
      suggestions: genericSuggestions,
    );
  }

  // Supprimer une session
  void deleteSession(String sessionId) {
    final sessionIndex = _sessions.indexWhere((s) => s.id == sessionId);
    if (sessionIndex != -1) {
      _sessions.removeAt(sessionIndex);
      
      // Si la session active a été supprimée, en définir une nouvelle
      if (_activeSession?.id == sessionId) {
        _activeSession = _sessions.isNotEmpty ? _sessions.last : createNewSession();
        _sessionStreamController.add(_activeSession!);
      }
    }
  }

  // Nettoyer les ressources quand le service n'est plus nécessaire
  void dispose() {
    _sessionStreamController.close();
  }
} 