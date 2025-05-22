// lib/services/chatbot_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:greens_app/models/chatbot_message.dart';
import 'package:uuid/uuid.dart';
import 'package:greens_app/services/carbon_footprint_service.dart';
import 'package:greens_app/services/environmental_impact_service.dart';
import 'package:greens_app/services/eco_challenge_service.dart';
import 'package:greens_app/services/product_recommendation_service.dart';
import 'package:greens_app/services/eco_digital_twin_service.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:flutter/services.dart';

/// Modèle pour représenter le contexte d'une conversation
class ChatContext {
  final String message;
  final String sessionId;
  final List<Map<String, dynamic>> previousMessages;
  final DateTime timestamp;
  final String type;
  final Map<String, dynamic>? userData;

  ChatContext({
    required this.message,
    required this.sessionId,
    required this.previousMessages,
    required this.timestamp,
    this.type = 'eco_chatbot',
    this.userData,
  });

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'sessionId': sessionId,
      'context': previousMessages,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'userData': userData,
    };
  }
}

/// Définition des types d'action possibles pour le chatbot
enum ChatbotActionType {
  navigate,             // Navigation vers une autre page
  calculateFootprint,   // Calculer l'empreinte carbone
  showProducts,         // Afficher des produits recommandés
  joinChallenge,        // Rejoindre un défi écologique
  scanProduct,          // Scanner un produit
  showTips,             // Afficher des conseils personnalisés
  showDigitalTwin,      // Afficher le jumeau numérique
  shareImpact,          // Partager son impact environnemental
  trackHabit,           // Suivre une habitude écologique
  none                  // Aucune action
}

/// Modèle pour représenter une action du chatbot
class ChatbotAction {
  final ChatbotActionType type;
  final String title;
  final Map<String, dynamic> data;
  
  ChatbotAction({
    required this.type,
    required this.title,
    this.data = const {},
  });
  
  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'title': title,
      'data': data,
    };
  }
  
  factory ChatbotAction.fromJson(Map<String, dynamic> json) {
    return ChatbotAction(
      type: _parseActionType(json['type']),
      title: json['title'],
      data: json['data'] ?? {},
    );
  }
  
  static ChatbotActionType _parseActionType(String? typeStr) {
    if (typeStr == null) return ChatbotActionType.none;
    
    final actionType = ChatbotActionType.values.firstWhere(
      (e) => e.toString() == typeStr || e.toString() == 'ChatbotActionType.$typeStr',
      orElse: () => ChatbotActionType.none,
    );
    
    return actionType;
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
  
  // Services intégrés pour le hub central
  CarbonFootprintService? _carbonService;
  EnvironmentalImpactService? _impactService;
  EcoChallengeService? _challengeService;
  ProductRecommendationService? _productService;
  EcoDigitalTwinService? _digitalTwinService;

  // Getters
  List<ChatbotMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;

  Map<String, dynamic>? _ecologieData;
  List<Map<String, String>> _conversationHistory = [];
  String? _lastCategory;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Charger le fichier JSON des questions/réponses
      final String jsonString = await rootBundle.loadString('assets/data/ecologie.json');
      _ecologieData = json.decode(jsonString);
      
      print('Fichier ecologie.json chargé avec succès');
      print('Nombre de questions: ${_ecologieData!['questions'].length}');
      print('Catégories disponibles: ${_ecologieData!['metadata']['categories'].join(', ')}');
      
      // Débogage: afficher les questions sur l'écologie
      print('Questions sur l\'écologie:');
      for (var question in _ecologieData!['questions']) {
        if (question['categorie'] == 'consommation') {
          print('- ${question['id']}: ${question['question']}');
        }
      }
      
      _isInitialized = true;
      
      // Ajouter un message de bienvenue à l'historique
      final welcomeMessage = {
        'id': '${DateTime.now().millisecondsSinceEpoch}_assistant',
        'role': 'assistant',
        'content': "Bonjour ! Je suis votre assistant écologique. Je peux vous aider avec des questions sur :\n"
            "- La réduction de l'empreinte carbone (transport)\n"
            "- La gestion des déchets plastiques (dechets)\n"
            "- L'économie d'eau (eau)\n"
            "N'hésitez pas à me poser vos questions !",
      };
      _conversationHistory.add(welcomeMessage);
      
    } catch (e) {
      print('Erreur lors du chargement du fichier ecologie.json: $e');
      _isInitialized = false;
      throw Exception('Impossible de charger les données écologiques: $e');
    }
  }

  Future<Map<String, String>> sendMessage(String message) async {
    if (!_isInitialized || _ecologieData == null) {
      return {
        'id': '${DateTime.now().millisecondsSinceEpoch}_error',
        'role': 'assistant',
        'content': "Je suis désolé, je ne peux pas accéder à mes réponses pour le moment.",
      };
    }

    // Ajouter le message de l'utilisateur à l'historique
    final userMessage = {
      'id': '${DateTime.now().millisecondsSinceEpoch}_user',
      'role': 'user',
      'content': message,
    };
    _conversationHistory.add(userMessage);

    // Générer la réponse
    final response = _generateResponse(message);

    // Ajouter la réponse à l'historique
    final assistantMessage = {
      'id': '${DateTime.now().millisecondsSinceEpoch}_assistant',
      'role': 'assistant',
      'content': response,
    };
    _conversationHistory.add(assistantMessage);

    return assistantMessage;
  }

  String _generateResponse(String userMessage) {
    // Convertir le message en minuscules pour une meilleure correspondance
    final message = userMessage.toLowerCase();

    // Rechercher une correspondance dans les questions
    List<Map<String, dynamic>> matchedQuestions = [];
    
    for (var question in _ecologieData!['questions']) {
      final questionText = question['question'].toString().toLowerCase();
      
      // Vérifier si le message de l'utilisateur contient des mots-clés de la question
      if (_containsKeywords(message, questionText)) {
        matchedQuestions.add(question);
      }
    }
    
    // Si on a trouvé des correspondances
    if (matchedQuestions.isNotEmpty) {
      // Trouver la question la plus pertinente (celle avec le plus de mots-clés en commun)
      var bestQuestion = matchedQuestions[0];
      int bestMatchCount = 0;
      
      for (var question in matchedQuestions) {
        final questionText = question['question'].toString().toLowerCase();
        final keywords = questionText
            .split(' ')
            .where((word) => word.length > 3)
            .map((word) => word.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase())
            .where((word) => word.isNotEmpty)
            .toList();
        
        int matchCount = 0;
        for (var keyword in keywords) {
          if (message.contains(keyword)) {
            matchCount++;
          }
        }
        
        if (matchCount > bestMatchCount) {
          bestMatchCount = matchCount;
          bestQuestion = question;
        }
      }
      
      // Mettre à jour la dernière catégorie discutée
      _lastCategory = bestQuestion['categorie'];
      
      // Trouver la meilleure réponse (celle avec le plus de points)
      var bestResponse = bestQuestion['reponses'][0];
      for (var reponse in bestQuestion['reponses']) {
        if (reponse['points'] > bestResponse['points']) {
          bestResponse = reponse;
        }
      }
      
      // Ajouter une suggestion de question liée si disponible
      String suggestion = "";
      final relatedQuestions = _ecologieData!['questions']
          .where((q) => q['categorie'] == _lastCategory && q['id'] != bestQuestion['id'])
          .toList();
      
      if (relatedQuestions.isNotEmpty) {
        relatedQuestions.shuffle();
        suggestion = "\n\nVous pourriez aussi vous intéresser à : \"${relatedQuestions[0]['question']}\"";
      }
      
      return "Question: ${bestQuestion['question']}\n\n${bestResponse['texte']}\n\n${bestResponse['explication']}$suggestion";
    }

    // Vérifier si le message contient des mots-clés liés aux catégories
    for (var categorie in _ecologieData!['metadata']['categories']) {
      if (message.contains(categorie.toString().toLowerCase())) {
        // Mettre à jour la dernière catégorie discutée
        _lastCategory = categorie.toString();
        
        // Trouver toutes les questions de cette catégorie
        var questionsCategorie = _ecologieData!['questions']
            .where((q) => q['categorie'] == categorie)
            .toList();
        
        if (questionsCategorie.isNotEmpty) {
          questionsCategorie.shuffle();
          var question = questionsCategorie[0];
          return "Voici une question sur ${categorie} :\n\n${question['question']}\n\nVous pouvez me demander plus d'informations à ce sujet.";
        }
      }
    }

    // Si aucune correspondance n'est trouvée, retourner une réponse par défaut
    return "Je suis désolé, je n'ai pas de réponse spécifique à cette question dans ma base de données. "
           "Je peux vous aider avec des questions sur :\n"
           "- La réduction de l'empreinte carbone (transport)\n"
           "- La gestion des déchets plastiques (dechets)\n"
           "- L'économie d'eau (eau)\n"
           "- L'alimentation durable (alimentation)\n"
           "- L'impact du numérique (numerique)\n"
           "- La consommation d'énergie (energie)\n"
           "- La mode éthique (mode)\n"
           "- La consommation responsable (consommation)\n"
           "N'hésitez pas à reformuler votre question.";
  }

  bool _containsKeywords(String message, String question) {
    // Cas spécial pour les questions directes (qu'est-ce que X, comment faire X, etc.)
    final directQuestionPatterns = [
      RegExp(r"qu'est[\s-]*ce[\s-]*que.*"),
      RegExp(r"que[\s-]*signifie.*"),
      RegExp(r"comment[\s-]*faire.*"),
      RegExp(r"comment[\s-]*peut[\s-]*on.*"),
      RegExp(r"pourquoi[\s-]*.*"),
      RegExp(r"définition[\s-]*de.*"),
      RegExp(r"c'est[\s-]*quoi.*"),
      RegExp(r"explique[\s-]*moi.*"),
      RegExp(r"peux[\s-]*tu[\s-]*expliquer.*"),
      RegExp(r"parle[\s-]*moi[\s-]*de.*")
    ];
    
    // Dictionnaire de synonymes pour les termes écologiques
    final synonymes = {
      'écologie': ['écologique', 'environnement', 'nature', 'écosystème', 'planète', 'terre', 'durable'],
      'déchets': ['ordures', 'poubelle', 'recyclage', 'tri', 'plastique', 'compost'],
      'eau': ['hydrique', 'océan', 'mer', 'rivière', 'potable', 'consommation d\'eau'],
      'énergie': ['électricité', 'renouvelable', 'solaire', 'éolienne', 'consommation énergétique'],
      'transport': ['voiture', 'vélo', 'mobilité', 'déplacement', 'carburant', 'essence'],
      'alimentation': ['nourriture', 'manger', 'repas', 'bio', 'végétarien', 'local'],
      'consommation': ['acheter', 'achat', 'produit', 'magasin', 'responsable', 'éthique'],
      'mode': ['vêtement', 'textile', 'habit', 'seconde main', 'fast fashion']
    };
    
    // Vérifier si c'est une question directe
    bool isDirectQuestion = false;
    for (var pattern in directQuestionPatterns) {
      if (pattern.hasMatch(message)) {
        isDirectQuestion = true;
        break;
      }
    }
    
    // Extraire les mots-clés significatifs de la question
    final questionKeywords = question
        .split(' ')
        .where((word) => word.length > 3) // Ignorer les mots courts
        .map((word) => word.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase()) // Supprimer la ponctuation
        .where((word) => word.isNotEmpty) // Ignorer les mots vides après nettoyage
        .toList();
    
    // Extraire les mots-clés du message de l'utilisateur
    final messageKeywords = message
        .split(' ')
        .where((word) => word.length > 3)
        .map((word) => word.replaceAll(RegExp(r'[^\w\s]'), '').toLowerCase())
        .where((word) => word.isNotEmpty)
        .toList();
    
    // Calculer le score de correspondance
    int exactMatchCount = 0;
    int synonymMatchCount = 0;
    int fuzzyMatchCount = 0;
    
    for (var questionKeyword in questionKeywords) {
      // Correspondance exacte
      if (messageKeywords.contains(questionKeyword)) {
        exactMatchCount++;
        continue;
      }
      
      // Correspondance par synonymes
      bool foundSynonym = false;
      synonymes.forEach((key, synonymList) {
        if (questionKeyword == key || synonymList.contains(questionKeyword)) {
          for (var messageKeyword in messageKeywords) {
            if (messageKeyword == key || synonymList.contains(messageKeyword)) {
              synonymMatchCount++;
              foundSynonym = true;
              break;
            }
          }
        }
        if (foundSynonym) return;
      });
      if (foundSynonym) continue;
      
      // Correspondance approximative (distance de Levenshtein)
      for (var messageKeyword in messageKeywords) {
        if (_levenshteinDistance(questionKeyword, messageKeyword) <= 2) { // Tolérance de 2 caractères
          fuzzyMatchCount++;
          break;
        }
      }
    }
    
    // Calculer le score total pondéré
    double score = exactMatchCount * 1.0 + synonymMatchCount * 0.8 + fuzzyMatchCount * 0.6;
    
    // Seuil de correspondance
    double threshold = isDirectQuestion ? 0.8 : 1.5;
    
    // Vérifier également les catégories pour les questions liées
    for (var category in _ecologieData!['metadata']['categories']) {
      String categoryStr = category.toString().toLowerCase();
      if (message.contains(categoryStr)) {
        score += 0.5;
      }
      
      // Vérifier les synonymes de catégories
      if (synonymes.containsKey(categoryStr)) {
        for (var synonym in synonymes[categoryStr]!) {
          if (message.contains(synonym)) {
            score += 0.3;
            break;
          }
        }
      }
    }
    
    return score >= threshold;
  }
  
  // Calcul de la distance de Levenshtein (distance d'édition entre deux chaînes)
  int _levenshteinDistance(String s, String t) {
    if (s == t) return 0;
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;
    
    List<int> v0 = List<int>.filled(t.length + 1, 0);
    List<int> v1 = List<int>.filled(t.length + 1, 0);
    
    for (int i = 0; i < v0.length; i++) {
      v0[i] = i;
    }
    
    for (int i = 0; i < s.length; i++) {
      v1[0] = i + 1;
      
      for (int j = 0; j < t.length; j++) {
        int cost = (s[i] == t[j]) ? 0 : 1;
        v1[j + 1] = min(v1[j] + 1, min(v0[j + 1] + 1, v0[j] + cost));
      }
      
      for (int j = 0; j < v0.length; j++) {
        v0[j] = v1[j];
      }
    }
    
    return v1[t.length];
  }

  void clearConversation() {
    _conversationHistory.clear();
  }

  /// Initialise le service avec l'URL du webhook n8n et les services intégrés
  Future<void> initializeWithWebhook({
    required String webhookUrl,
    CarbonFootprintService? carbonService,
    EnvironmentalImpactService? impactService,
    EcoChallengeService? challengeService,
    ProductRecommendationService? productService,
    EcoDigitalTwinService? digitalTwinService,
  }) async {
    try {
      _webhookUrl = webhookUrl;
      
      // Enregistrer les services intégrés
      _carbonService = carbonService;
      _impactService = impactService;
      _challengeService = challengeService;
      _productService = productService;
      _digitalTwinService = digitalTwinService;
      
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

  /// Envoie un message au chatbot via n8n et récupère la réponse avec le contexte utilisateur
  Future<Map<String, dynamic>> getResponseWithContext(
    String message, {
    List<Map<String, dynamic>>? context,
    Map<String, dynamic>? userData,
  }) async {
    if (!_isInitialized) {
      return {
        'response': "Le service n'est pas initialisé. Veuillez vérifier votre configuration.",
        'actions': [],
        'suggestions': [],
      };
    }
    
    try {
      // Préparer le contexte de la conversation avec les données utilisateur
      final chatContext = ChatContext(
        message: message,
        sessionId: _sessionId,
        previousMessages: context ?? [],
        timestamp: DateTime.now(),
        userData: userData,
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
        final responseData = jsonDecode(response.body);
        
        // Extraire les actions suggérées si présentes
        List<ChatbotAction> actions = [];
        if (responseData['actions'] != null && responseData['actions'] is List) {
          actions = (responseData['actions'] as List)
              .map((action) => ChatbotAction.fromJson(action))
              .toList();
        }
        
        // Extraire les suggestions si présentes
        List<String> suggestions = [];
        if (responseData['suggestions'] != null && responseData['suggestions'] is List) {
          suggestions = List<String>.from(responseData['suggestions']);
        }
        
        return {
          'response': responseData['response'] ?? "J'ai bien reçu votre message, mais je n'ai pas de réponse spécifique.",
          'actions': actions,
          'suggestions': suggestions,
        };
      } else {
        print('Erreur lors de la communication avec n8n: ${response.statusCode}');
        return {
          'response': "Désolé, une erreur s'est produite lors de la communication avec le service (code ${response.statusCode}).",
          'actions': [],
          'suggestions': [],
        };
      }
    } catch (e) {
      print('Exception lors de la communication avec n8n: $e');
      return {
        'response': "Désolé, une erreur s'est produite lors de la communication: $e",
        'actions': [],
        'suggestions': [],
      };
    }
  }
  
  /// Version simplifiée pour la compatibilité avec le code existant
  Future<String> getResponse(String message, {List<Map<String, dynamic>>? context}) async {
    final response = await getResponseWithContext(message, context: context);
    return response['response'] as String;
  }

  /// Envoie un message au chatbot via n8n et récupère la réponse avec actions contextuelles
  Future<ChatbotMessage> sendMessageWithContext(String message, {String userId = ''}) async {
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

      // Récupérer les données utilisateur pour le contexte
      final userData = await _getUserContextData(userId);
      
      // Récupérer la réponse enrichie
      final response = await getResponseWithContext(
        message, 
        context: _messages
          .take(5)
          .map((msg) => {
                'text': msg.text,
                'isUser': msg.isUser,
                'timestamp': msg.timestamp.toIso8601String(),
              })
          .toList(),
        userData: userData,
      );
      
      // Extraire les actions et suggestions
      final List<ChatbotAction> actions = response['actions'] as List<ChatbotAction>? ?? [];
      final List<String> suggestions = response['suggestions'] as List<String>? ?? [];

      // Créer le message de réponse
      final botMessage = ChatbotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response['response'] as String,
        isUser: false,
        timestamp: DateTime.now(),
        suggestedActions: suggestions,
        metadata: _convertActionsToMap(actions),
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
  
  /// Exécute une action du chatbot
  Future<void> executeAction(ChatbotAction action, BuildContext context, String userId) async {
    switch (action.type) {
      case ChatbotActionType.navigate:
        // Navigation vers une autre page
        final route = action.data['route'] as String?;
        if (route != null) {
          Navigator.of(context).pushNamed(route);
        }
        break;
        
      case ChatbotActionType.calculateFootprint:
        // Lancer le calculateur d'empreinte carbone
        Navigator.of(context).pushNamed(AppRoutes.carbonCalculator);
        break;
        
      case ChatbotActionType.showProducts:
        // Afficher les produits recommandés
        final category = action.data['category'] as String?;
        if (category != null) {
          Navigator.of(context).pushNamed(
            AppRoutes.products,
            arguments: {'category': category}
          );
        } else {
          Navigator.of(context).pushNamed(AppRoutes.products);
        }
        break;
        
      case ChatbotActionType.joinChallenge:
        // Rejoindre un défi écologique
        final challengeId = action.data['challengeId'] as String?;
        if (challengeId != null && _challengeService != null) {
          // Logique pour rejoindre un défi spécifique
          await _challengeService!.joinChallenge(userId, challengeId);
          // Informer l'utilisateur
          final successMessage = ChatbotMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Vous avez rejoint le défi avec succès !',
            isUser: false,
            timestamp: DateTime.now(),
          );
          _messages.add(successMessage);
          notifyListeners();
        }
        break;
        
      case ChatbotActionType.scanProduct:
        // Lancer le scanner de produits
        Navigator.of(context).pushNamed(AppRoutes.productScanner);
        break;
        
      case ChatbotActionType.showTips:
        // Afficher des conseils personnalisés
        if (_digitalTwinService != null) {
          final tip = _digitalTwinService!.getPersonalizedTip();
          final tipMessage = ChatbotMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Conseil personnalisé : $tip',
            isUser: false,
            timestamp: DateTime.now(),
          );
          _messages.add(tipMessage);
          notifyListeners();
        }
        break;
        
      case ChatbotActionType.showDigitalTwin:
        // Afficher le jumeau numérique
        // Navigation vers la future page du jumeau numérique
        // Pour l'instant, on affiche un message
        final message = ChatbotMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: 'Fonctionnalité de jumeau numérique en développement. Restez à l\'écoute !',
          isUser: false,
          timestamp: DateTime.now(),
        );
        _messages.add(message);
        notifyListeners();
        break;
        
      case ChatbotActionType.shareImpact:
        // Partager son impact environnemental
        Navigator.of(context).pushNamed(AppRoutes.environmentalImpact);
        break;
        
      case ChatbotActionType.trackHabit:
        // Suivre une habitude écologique
        final habitType = action.data['habitType'] as String?;
        if (habitType != null && _impactService != null) {
          final carbonImpact = _impactService!.calculateImpactForAction(habitType);
          await _impactService!.addEnvironmentalImpact(userId, carbonImpact, habitType);
          
          // Informer l'utilisateur
          final message = ChatbotMessage(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            text: 'Bravo ! Vous avez enregistré une action écologique qui a économisé $carbonImpact kg de CO₂.',
            isUser: false,
            timestamp: DateTime.now(),
          );
          _messages.add(message);
          notifyListeners();
        }
        break;
        
      case ChatbotActionType.none:
      default:
        // Aucune action ou action non reconnue
        print('Action non reconnue ou aucune action : ${action.type}');
        break;
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
    
    // Suggestions par défaut si échec
    return [
      "Comment fonctionne le jumeau numérique écologique ?",
      "Montre-moi mon impact environnemental",
      "Je veux scanner un produit",
      "Recommande-moi des produits écologiques"
    ];
  }
  
  /// Récupère des actions contextuelles recommandées basées sur l'historique des conversations
  Future<List<ChatbotAction>> getContextualActions(String userId) async {
    // Si pas d'historique récent, renvoyer des actions par défaut
    if (_messages.isEmpty) {
      return [
        ChatbotAction(
          type: ChatbotActionType.calculateFootprint,
          title: 'Calculer mon empreinte carbone',
        ),
        ChatbotAction(
          type: ChatbotActionType.scanProduct,
          title: 'Scanner un produit',
        ),
        ChatbotAction(
          type: ChatbotActionType.showDigitalTwin,
          title: 'Voir mon jumeau écologique',
        ),
      ];
    }
    
    // Analyser les derniers messages pour déterminer les actions pertinentes
    final recentMessages = _messages.where((msg) => msg.isUser).take(3).toList();
    final List<ChatbotAction> recommendedActions = [];
    
    // Si l'utilisateur a parlé d'impact ou d'empreinte
    final mentionsImpact = recentMessages.any((msg) => 
      msg.text.toLowerCase().contains('impact') || 
      msg.text.toLowerCase().contains('empreinte'));
    
    if (mentionsImpact) {
      recommendedActions.add(ChatbotAction(
        type: ChatbotActionType.calculateFootprint,
        title: 'Calculer mon empreinte carbone',
      ));
      
      recommendedActions.add(ChatbotAction(
        type: ChatbotActionType.shareImpact,
        title: 'Voir mon impact environnemental',
      ));
    }
    
    // Si l'utilisateur a parlé de produits
    final mentionsProducts = recentMessages.any((msg) => 
      msg.text.toLowerCase().contains('produit') || 
      msg.text.toLowerCase().contains('acheter') ||
      msg.text.toLowerCase().contains('achat'));
    
    if (mentionsProducts) {
      recommendedActions.add(ChatbotAction(
        type: ChatbotActionType.scanProduct,
        title: 'Scanner un produit',
      ));
      
      recommendedActions.add(ChatbotAction(
        type: ChatbotActionType.showProducts,
        title: 'Voir les produits recommandés',
      ));
    }
    
    // Si l'utilisateur a parlé de défis ou d'actions
    final mentionsChallenges = recentMessages.any((msg) => 
      msg.text.toLowerCase().contains('défi') || 
      msg.text.toLowerCase().contains('action') ||
      msg.text.toLowerCase().contains('participer'));
    
    if (mentionsChallenges && _challengeService != null) {
      // Obtenir un défi recommandé
      try {
        final recommendedChallenge = await _challengeService!.getRecommendedChallenge(userId);
        if (recommendedChallenge != null) {
          recommendedActions.add(ChatbotAction(
            type: ChatbotActionType.joinChallenge,
            title: 'Rejoindre le défi : ${recommendedChallenge.title}',
            data: {'challengeId': recommendedChallenge.id},
          ));
        }
      } catch (e) {
        print('Erreur lors de la récupération d\'un défi recommandé: $e');
      }
    }
    
    // Si trop peu d'actions recommandées, ajouter des actions par défaut
    if (recommendedActions.length < 2) {
      recommendedActions.add(ChatbotAction(
        type: ChatbotActionType.showDigitalTwin,
        title: 'Voir mon jumeau écologique',
      ));
      
      recommendedActions.add(ChatbotAction(
        type: ChatbotActionType.showTips,
        title: 'Obtenir des conseils personnalisés',
      ));
    }
    
    return recommendedActions;
  }
  
  /// Récupère les données utilisateur pour enrichir le contexte du chatbot
  Future<Map<String, dynamic>> _getUserContextData(String userId) async {
    if (userId.isEmpty) return {};
    
    final userData = <String, dynamic>{
      'userId': userId,
    };
    
    // Ajouter les données d'impact environnemental si disponibles
    if (_impactService != null) {
      try {
        await _impactService!.getUserImpact(userId);
        final impact = _impactService!.userImpact;
        userData['environmentalImpact'] = {
          'carbonSaved': impact.carbonSaved,
          'treeEquivalent': impact.treeEquivalent,
          'waterSaved': impact.waterSaved,
          'userContributionPercentage': impact.userContributionPercentage,
        };
      } catch (e) {
        print('Erreur lors de la récupération des données d\'impact: $e');
      }
    }
    
    // Ajouter les données du jumeau numérique si disponibles
    if (_digitalTwinService != null) {
      try {
        await _digitalTwinService!.loadOrCreateDigitalTwin(userId);
        final twin = _digitalTwinService!.digitalTwin;
        if (twin != null) {
          userData['ecoLevel'] = twin.ecoLevel;
          userData['levelProgress'] = twin.levelProgress;
          userData['completedChallenges'] = twin.completedChallenges.length;
          userData['currentChallenges'] = twin.currentChallenges.length;
          userData['recentActions'] = twin.ecoActions
            .where((a) => DateTime.now().difference(a.timestamp).inDays < 7)
            .length;
        }
      } catch (e) {
        print('Erreur lors de la récupération des données du jumeau numérique: $e');
      }
    }
    
    return userData;
  }
  
  /// Convertit une liste d'actions en map pour le modèle ChatbotMessage
  Map<String, dynamic> _convertActionsToMap(List<ChatbotAction> actions) {
    final result = <String, dynamic>{};
    for (var i = 0; i < actions.length; i++) {
      result['action_$i'] = {
        'type': actions[i].type.toString(),
        'title': actions[i].title,
        'data': actions[i].data,
      };
    }
    return result;
  }

  /// Récupère des suggestions de questions basées sur la catégorie de la dernière question posée
  List<String> getSuggestedQuestions(String? lastCategory) {
    if (!_isInitialized || _ecologieData == null) {
      return [];
    }
    
    List<String> suggestions = [];
    
    // Si une catégorie a été récemment discutée, suggérer des questions de cette catégorie
    if (lastCategory != null) {
      final questionsInCategory = _ecologieData!['questions']
          .where((q) => q['categorie'] == lastCategory)
          .toList();
      
      if (questionsInCategory.isNotEmpty) {
        // Prendre jusqu'à 2 questions de cette catégorie
        for (var i = 0; i < min(2, questionsInCategory.length); i++) {
          suggestions.add(questionsInCategory[i]['question']);
        }
      }
    }
    
    // Ajouter des questions d'autres catégories pour diversifier
    final categories = _ecologieData!['metadata']['categories'] as List;
    final otherCategories = categories.where((c) => c != lastCategory).toList();
    
    if (otherCategories.isNotEmpty) {
      // Prendre jusqu'à 3 questions d'autres catégories
      final randomCategories = List.from(otherCategories)..shuffle();
      for (var i = 0; i < min(3, randomCategories.length); i++) {
        final category = randomCategories[i];
        final questionsInCategory = _ecologieData!['questions']
            .where((q) => q['categorie'] == category)
            .toList();
        
        if (questionsInCategory.isNotEmpty) {
          questionsInCategory.shuffle();
          suggestions.add(questionsInCategory[0]['question']);
        }
      }
    }
    
    // Si nous n'avons pas assez de suggestions, ajouter des questions aléatoires
    if (suggestions.length < 3) {
      final allQuestions = List.from(_ecologieData!['questions'])..shuffle();
      for (var question in allQuestions) {
        if (!suggestions.contains(question['question'])) {
          suggestions.add(question['question']);
          if (suggestions.length >= 3) break;
        }
      }
    }
    
    return suggestions;
  }
}