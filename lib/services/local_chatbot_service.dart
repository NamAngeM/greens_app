// lib/services/local_chatbot_service.dart
import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:greens_app/models/chatbot_message.dart';
import 'package:greens_app/services/chatbot_database.dart';
import 'package:uuid/uuid.dart';
import '../models/qa_model.dart';
import 'database_service.dart';
import 'semantic_analyzer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:greens_app/utils/app_colors.dart';

class LocalChatbotService extends ChangeNotifier {
  static final LocalChatbotService instance = LocalChatbotService._internal();
  final ChatbotDatabase _database = ChatbotDatabase.instance;
  final List<ChatbotMessage> _messages = [];
  bool _isInitialized = false;
  String? _lastCategory;
  final _uuid = Uuid();
  final DatabaseService _databaseService = DatabaseService();
  final Random _random = Random();
  final List<String> _recentKeywords = [];
  static const int _maxContextSize = 5;
  
  // Phrases de transition pour rendre les réponses plus naturelles
  final List<String> _transitions = [
    "Je peux vous dire que",
    "D'après mes connaissances,",
    "Pour répondre à votre question,",
    "Voici ce que je sais :",
    "Je vous informe que",
    "Pour être précis,",
    "En effet,",
    "Sachez que",
  ];

  // Phrases pour les cas où on ne trouve pas de réponse exacte
  final List<String> _fallbackResponses = [
    "Je ne suis pas sûr de bien comprendre votre question. Pourriez-vous la reformuler ?",
    "Je n'ai pas d'information précise sur ce sujet. Avez-vous une autre question ?",
    "Je ne peux pas répondre à cette question pour le moment. Souhaitez-vous en poser une autre ?",
    "Je n'ai pas encore appris à répondre à ce type de question. Pourriez-vous essayer autrement ?",
  ];

  // Dictionnaire de synonymes pour améliorer la recherche
  final Map<String, List<String>> _synonyms = {
    'écologie': ['écologique', 'environnement', 'nature', 'écosystème', 'planète', 'terre', 'durable'],
    'déchets': ['ordures', 'poubelle', 'recyclage', 'tri', 'plastique', 'compost'],
    'eau': ['hydrique', 'océan', 'mer', 'rivière', 'potable', 'consommation d\'eau'],
    'énergie': ['électricité', 'renouvelable', 'solaire', 'éolienne', 'consommation énergétique'],
    'transport': ['voiture', 'vélo', 'mobilité', 'déplacement', 'carburant', 'essence'],
    'alimentation': ['nourriture', 'manger', 'repas', 'bio', 'végétarien', 'local'],
    'consommation': ['acheter', 'achat', 'produit', 'magasin', 'responsable', 'éthique'],
    'mode': ['vêtement', 'textile', 'habit', 'seconde main', 'fast fashion']
  };

  LocalChatbotService._internal();

  List<ChatbotMessage> get messages => _messages;
  bool get isInitialized => _isInitialized;

  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialiser la base de données
      await _database.loadInitialData();
      
      _isInitialized = true;
      
      // Ajouter un message de bienvenue
      final welcomeMessage = ChatbotMessage(
        id: _uuid.v4(),
        text: "Bonjour ! Je suis votre assistant écologique. Je peux vous aider avec des questions sur :\n"
            "- La réduction de l'empreinte carbone (transport)\n"
            "- La gestion des déchets plastiques (dechets)\n"
            "- L'économie d'eau (eau)\n"
            "- L'alimentation durable (alimentation)\n"
            "- L'impact du numérique (numerique)\n"
            "- La consommation d'énergie (energie)\n"
            "- La mode éthique (mode)\n"
            "- La consommation responsable (consommation)\n"
            "N'hésitez pas à me poser vos questions !",
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      _messages.add(welcomeMessage);
      await _database.saveConversationMessage(welcomeMessage.text, false);
      
      notifyListeners();
      
      print('Service de chatbot local initialisé avec succès');
    } catch (e) {
      print('Erreur lors de l\'initialisation du service de chatbot local: $e');
      _isInitialized = false;
      throw Exception('Impossible d\'initialiser le service de chatbot local: $e');
    }
  }

  Future<String> sendMessage(String message) async {
    if (!_isInitialized) {
      await initialize();
    }

    // Enregistrer le message de l'utilisateur
    final userMessage = ChatbotMessage(
      id: _uuid.v4(),
      text: message,
      isUser: true,
      timestamp: DateTime.now(),
    );
    
    _messages.add(userMessage);
    await _database.saveConversationMessage(message, true);
    
    // Générer une réponse
    final response = await getResponse(message);
    
    // Enregistrer la réponse du chatbot
    final botMessage = ChatbotMessage(
      id: _uuid.v4(),
      text: response,
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    _messages.add(botMessage);
    await _database.saveConversationMessage(response, false);
    
    notifyListeners();
    
    return response;
  }

  Future<String> getResponse(String userMessage) async {
    final settings = await getSettings();
    final normalizedMessage = _normalizeMessage(userMessage);
    final keywords = _extractKeywords(normalizedMessage);
    
    if (settings['useSynonyms']) {
      keywords.addAll(_expandKeywordsWithSynonyms(keywords));
    }

    if (settings['useContext']) {
      _updateContext(keywords);
    }

    final results = await _databaseService.searchQA(normalizedMessage);
    String response;

    if (results.isNotEmpty) {
      final bestMatch = _selectBestMatch(results, keywords, settings['useContext']);
      response = bestMatch.answer;
    } else {
      response = await _getFallbackResponse(settings['showSuggestions']);
    }

    if (settings['useNaturalLanguage']) {
      response = _formatResponse(response);
    }

    return response;
  }

  String _normalizeMessage(String message) {
    return message.toLowerCase().trim();
  }

  List<String> _extractKeywords(String text) {
    final stopWords = {
      'le', 'la', 'les', 'un', 'une', 'des', 'et', 'ou', 'mais', 'donc', 'car',
      'ni', 'que', 'qui', 'quoi', 'dont', 'où', 'comment', 'pourquoi', 'quand',
      'est', 'sont', 'être', 'avoir', 'faire', 'dire', 'voir', 'aller', 'venir',
      'pouvoir', 'vouloir', 'devoir', 'falloir', 'savoir', 'croire', 'penser',
      'trouver', 'donner', 'prendre', 'mettre', 'passer', 'rester', 'partir',
      'arriver', 'monter', 'descendre', 'entrer', 'sortir', 'revenir', 'rentrer',
      'repartir', 'repasser', 'remettre', 'redonner', 'reprendre', 'retrouver',
      'repenser', 'recroire', 'resavoir', 'refalloir', 'redevoir', 'revouloir',
      'repouvoir', 'revenir', 'repartir', 'repasser', 'remettre', 'redonner',
      'reprendre', 'retrouver', 'repenser', 'recroire', 'resavoir', 'refalloir',
      'redevoir', 'revouloir', 'repouvoir'
    };

    return text
        .split(RegExp(r'[,\s]+'))
        .where((word) => word.length > 2 && !stopWords.contains(word))
        .toList();
  }

  List<String> _expandKeywordsWithSynonyms(List<String> keywords) {
    final synonyms = {
      'climat': ['météo', 'température', 'réchauffement', 'gaz', 'effet', 'serre'],
      'énergie': ['électricité', 'puissance', 'force', 'courant', 'alimentation'],
      'déchet': ['ordures', 'détritus', 'rebut', 'résidu', 'reste'],
      'eau': ['liquide', 'pluie', 'rivière', 'fleuve', 'mer', 'océan'],
      'biodiversité': ['nature', 'faune', 'flore', 'espèce', 'animal', 'végétal'],
      'transport': ['déplacement', 'voyage', 'mobilité', 'circulation'],
      'alimentation': ['nourriture', 'aliment', 'repas', 'manger', 'boire'],
      'consommation': ['utilisation', 'usage', 'dépense', 'achat'],
    };

    final expandedKeywords = <String>[];
    for (final keyword in keywords) {
      expandedKeywords.add(keyword);
      for (final entry in synonyms.entries) {
        if (entry.value.contains(keyword)) {
          expandedKeywords.add(entry.key);
        }
      }
    }
    return expandedKeywords;
  }

  void _updateContext(List<String> keywords) {
    _recentKeywords.addAll(keywords);
    if (_recentKeywords.length > _maxContextSize) {
      _recentKeywords.removeRange(0, _recentKeywords.length - _maxContextSize);
    }
  }

  QAModel _selectBestMatch(List<QAModel> results, List<String> keywords, bool useContext) {
    QAModel bestMatch = results.first;
    double bestScore = 0;

    for (final result in results) {
      double score = 0;
      final resultKeywords = _extractKeywords(result.question);

      // Score pour les mots-clés exacts
      for (final keyword in keywords) {
        if (resultKeywords.contains(keyword)) {
          score += 2;
        }
      }

      // Score pour les mots-clés similaires
      for (final keyword in keywords) {
        for (final resultKeyword in resultKeywords) {
          if (_levenshteinDistance(keyword, resultKeyword) <= 2) {
            score += 1;
          }
        }
      }

      // Bonus pour les questions commençant par les mêmes mots
      if (result.question.toLowerCase().startsWith(keywords.first.toLowerCase())) {
        score += 1;
      }

      // Bonus pour le contexte
      if (useContext) {
        for (final contextKeyword in _recentKeywords) {
          if (resultKeywords.contains(contextKeyword)) {
            score += 0.5;
          }
        }
      }

      if (score > bestScore) {
        bestScore = score;
        bestMatch = result;
      }
    }

    return bestMatch;
  }

  int _levenshteinDistance(String s, String t) {
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    final matrix = List.generate(
      s.length + 1,
      (i) => List.generate(t.length + 1, (j) => 0),
    );

    for (var i = 0; i <= s.length; i++) matrix[i][0] = i;
    for (var j = 0; j <= t.length; j++) matrix[0][j] = j;

    for (var i = 1; i <= s.length; i++) {
      for (var j = 1; j <= t.length; j++) {
        final cost = s[i - 1] == t[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1, // deletion
          matrix[i][j - 1] + 1, // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce(min);
      }
    }

    return matrix[s.length][t.length];
  }

  Future<String> _getFallbackResponse(bool showSuggestions) async {
    final fallbackResponses = [
      "Je ne suis pas sûr de comprendre votre question. Pourriez-vous la reformuler ?",
      "Désolé, je n'ai pas d'information précise sur ce sujet. Avez-vous une autre question ?",
      "Je ne peux pas répondre à cette question pour le moment. Essayez de la poser différemment.",
    ];

    String response = fallbackResponses[Random().nextInt(fallbackResponses.length)];

    if (showSuggestions) {
      final suggestions = await _getSuggestions();
      if (suggestions.isNotEmpty) {
        response += "\n\nVoici quelques questions similaires que je peux traiter :\n";
        for (final suggestion in suggestions.take(3)) {
          response += "- $suggestion\n";
        }
      }
    }

    return response;
  }

  Future<List<String>> _getSuggestions() async {
    final popularQuestions = await _databaseService.getPopularQuestions(limit: 5);
    return popularQuestions.map((qa) => qa.question).toList();
  }

  String _formatResponse(String response) {
    final transitionPhrases = [
      "D'après mes connaissances, ",
      "Je peux vous dire que ",
      "Pour répondre à votre question, ",
      "En ce qui concerne votre question, ",
      "Voici ce que je sais : ",
    ];

    if (!response.startsWith(RegExp(r'[A-Z]'))) {
      response = transitionPhrases[Random().nextInt(transitionPhrases.length)] + response;
    }

    return response;
  }

  Future<Map<String, dynamic>> getSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'showTypingIndicator': prefs.getBool('showTypingIndicator') ?? true,
      'useNaturalLanguage': prefs.getBool('useNaturalLanguage') ?? true,
      'showSuggestions': prefs.getBool('showSuggestions') ?? true,
      'useContext': prefs.getBool('useContext') ?? true,
      'useSynonyms': prefs.getBool('useSynonyms') ?? true,
    };
  }

  Future<void> updateSettings(Map<String, dynamic> settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showTypingIndicator', settings['showTypingIndicator']);
    await prefs.setBool('useNaturalLanguage', settings['useNaturalLanguage']);
    await prefs.setBool('showSuggestions', settings['showSuggestions']);
    await prefs.setBool('useContext', settings['useContext']);
    await prefs.setBool('useSynonyms', settings['useSynonyms']);
  }

  Future<List<QAModel>> getSuggestions(String category) async {
    if (category.isEmpty) {
      return await _databaseService.getPopularQA(limit: 5);
    }
    return await _databaseService.getQAByCategory(category);
  }

  Future<List<String>> getCategories() async {
    final allQA = await _databaseService.getAllQA();
    final categories = allQA
        .map((qa) => qa.category)
        .where((category) => category != null)
        .map((category) => category!)
        .toSet()
        .toList();
    categories.sort();
    return categories;
  }

  List<String> getSuggestedQuestions(String? lastCategory) {
    List<String> suggestions = [];
    
    // Si aucune catégorie n'est spécifiée, utiliser la dernière catégorie discutée
    final category = lastCategory ?? _lastCategory;
    
    // Questions générales si aucune catégorie n'est disponible
    if (category == null) {
      return [
        "Qu'est-ce que l'écologie ?",
        "Comment réduire mon empreinte carbone ?",
        "Quels sont les gestes écologiques au quotidien ?",
      ];
    }
    
    // Questions spécifiques par catégorie
    switch (category) {
      case 'transport':
        suggestions = [
          "Comment réduire l'impact de mes déplacements ?",
          "Quels sont les avantages du vélo en ville ?",
          "Qu'est-ce que la mobilité douce ?",
        ];
        break;
      case 'dechets':
        suggestions = [
          "Comment bien trier ses déchets ?",
          "Comment réduire ses déchets plastiques ?",
          "Qu'est-ce que le compostage ?",
        ];
        break;
      case 'eau':
        suggestions = [
          "Comment économiser l'eau au quotidien ?",
          "Pourquoi l'eau est-elle une ressource précieuse ?",
          "Comment réduire la pollution de l'eau ?",
        ];
        break;
      case 'alimentation':
        suggestions = [
          "Quels sont les avantages des produits locaux ?",
          "Comment réduire le gaspillage alimentaire ?",
          "Pourquoi manger moins de viande ?",
        ];
        break;
      case 'numerique':
        suggestions = [
          "Qu'est-ce que la pollution numérique ?",
          "Comment réduire l'impact de mes emails ?",
          "Les appareils reconditionnés sont-ils écologiques ?",
        ];
        break;
      case 'energie':
        suggestions = [
          "Comment économiser l'électricité à la maison ?",
          "Quelles sont les énergies renouvelables ?",
          "Qu'est-ce que la sobriété énergétique ?",
        ];
        break;
      case 'mode':
        suggestions = [
          "Qu'est-ce que la mode éthique ?",
          "Comment avoir une garde-robe écologique ?",
          "Pourquoi éviter la fast fashion ?",
        ];
        break;
      case 'consommation':
        suggestions = [
          "Qu'est-ce que la consommation responsable ?",
          "Comment reconnaître un produit écologique ?",
          "Qu'est-ce que l'obsolescence programmée ?",
        ];
        break;
      default:
        suggestions = [
          "Qu'est-ce que l'écologie ?",
          "Comment réduire mon empreinte carbone ?",
          "Quels sont les gestes écologiques au quotidien ?",
        ];
    }
    
    // Mélanger les suggestions et en prendre 3 maximum
    suggestions.shuffle();
    return suggestions.take(3).toList();
  }

  void clearConversation() async {
    _messages.clear();
    
    // Ajouter un nouveau message de bienvenue
    final welcomeMessage = ChatbotMessage(
      id: _uuid.v4(),
      text: "Bonjour ! Je suis votre assistant écologique. Comment puis-je vous aider aujourd'hui ?",
      isUser: false,
      timestamp: DateTime.now(),
    );
    
    _messages.add(welcomeMessage);
    _lastCategory = null;
    
    notifyListeners();
  }
  
  Future<List<ChatbotMessage>> loadConversationHistory() async {
    final history = await _database.getConversationHistory();
    
    _messages.clear();
    
    for (var message in history.reversed) {
      _messages.add(ChatbotMessage(
        id: _uuid.v4(),
        text: message['message'] as String,
        isUser: message['is_user'] == 1,
        timestamp: DateTime.parse(message['timestamp'] as String),
      ));
    }
    
    notifyListeners();
    return _messages;
  }
}
