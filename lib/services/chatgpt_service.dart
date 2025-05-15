import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:greens_app/models/chatbot_message.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:greens_app/models/article_model.dart';

/// Service qui gère la communication avec l'API OpenAI (ChatGPT)
class ChatGPTService with ChangeNotifier {
  static final ChatGPTService _instance = ChatGPTService._privateConstructor();
  
  factory ChatGPTService() {
    return _instance;
  }
  
  ChatGPTService._privateConstructor();
  
  static ChatGPTService get instance => _instance;
  
  final String _openaiUrl = 'https://api.openai.com/v1/chat/completions';
  
  bool _isConfigured = false;
  final List<ChatbotMessage> _messages = [];
  bool _isLoading = false;
  String _openaiApiKey = '';

  // Getters
  bool get isConfigured => _isConfigured;
  List<ChatbotMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  
  /// Initialise le service avec la clé API OpenAI
  Future<void> initialize({required String openaiApiKey}) async {
    try {
      _openaiApiKey = openaiApiKey;
      
      print('Tentative de connexion à OpenAI avec la clé API...');
      
      // Tester l'API OpenAI avec une requête simple
      final response = await http.post(
        Uri.parse(_openaiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openaiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': [
            {
              'role': 'system',
              'content': 'Vous êtes un assistant écologique qui aide les utilisateurs à adopter des pratiques durables.'
            },
            {
              'role': 'user',
              'content': 'Dis bonjour en une phrase'
            }
          ],
          'max_tokens': 50
        }),
      ).timeout(const Duration(seconds: 10));
      
      print('Réponse du serveur OpenAI: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _isConfigured = true;
        print('Service ChatGPT initialisé avec succès');
      } else {
        print('Erreur lors de l\'initialisation de ChatGPT: ${response.statusCode} - ${response.body}');
        _isConfigured = false;
      }
    } catch (e) {
      print('Exception lors de l\'initialisation du service ChatGPT: $e');
      _isConfigured = false;
    }
  }

  /// Envoie un message à ChatGPT et reçoit une réponse
  Future<ChatbotMessage> sendMessage(String message) async {
    if (!_isConfigured) {
      final offlineResponse = ChatbotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: "Le service ChatGPT n'est pas configuré. Veuillez vérifier votre clé API.",
        isUser: false,
        timestamp: DateTime.now(),
      );
      _messages.add(offlineResponse);
      notifyListeners();
      return offlineResponse;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      // Ajouter le message de l'utilisateur
      final userMessage = ChatbotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      );
      _messages.add(userMessage);
      notifyListeners();
      
      // Préparer les messages pour la conversation
      final List<Map<String, String>> apiMessages = [
        {
          'role': 'system',
          'content': 'Vous êtes un assistant écologique spécialisé dans le développement durable. '
              'Fournissez des conseils pratiques et scientifiquement exacts sur l\'écologie, '
              'la réduction de l\'empreinte carbone, et les habitudes durables. Soyez concis, précis et motivant.'
        }
      ];
      
      // Ajouter les 5 derniers messages de la conversation pour le contexte
      final historyMessages = _messages.length > 10 
          ? _messages.sublist(_messages.length - 10) 
          : _messages;
      
      for (final msg in historyMessages) {
        apiMessages.add({
          'role': msg.isUser ? 'user' : 'assistant',
          'content': msg.text
        });
      }
      
      // Envoyer la requête à l'API OpenAI
      final response = await http.post(
        Uri.parse(_openaiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_openaiApiKey',
        },
        body: jsonEncode({
          'model': 'gpt-3.5-turbo',
          'messages': apiMessages,
          'max_tokens': 500,
          'temperature': 0.7,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        final content = responseData['choices'][0]['message']['content'];
        
        // Créer des suggestions basées sur le contenu
        List<String> suggestions = _generateSuggestions(message, content);
        
        // Créer la réponse
        final botMessage = ChatbotMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: content,
          isUser: false,
          timestamp: DateTime.now(),
          suggestedActions: suggestions,
        );
        
        _messages.add(botMessage);
        _isLoading = false;
        notifyListeners();
        return botMessage;
      } else {
        throw Exception('Erreur OpenAI: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de l\'envoi du message à ChatGPT: $e');
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
  
  /// Ajoute un message de bienvenue
  void addWelcomeMessage() {
    _messages.add(ChatbotMessage(
      id: 'welcome_chatgpt',
      text: 'Bonjour ! Je suis votre assistant écologique propulsé par ChatGPT. Je peux vous aider sur des questions concernant l\'écologie et le développement durable. N\'hésitez pas à me demander des conseils !',
      isUser: false,
      timestamp: DateTime.now(),
      suggestedActions: [
        'Comment réduire mon empreinte carbone ?',
        'Quels sont les principes de l\'économie circulaire ?',
        'Comment recycler correctement ?',
      ],
    ));
    notifyListeners();
  }
  
  /// Génère des suggestions basées sur la question et la réponse
  List<String> _generateSuggestions(String question, String answer) {
    List<String> suggestions = [];
    
    if (question.toLowerCase().contains('empreinte') || question.toLowerCase().contains('carbone')) {
      suggestions.add('Comment mesurer mon empreinte carbone ?');
      suggestions.add('Quels transports privilégier ?');
    }
    
    if (question.toLowerCase().contains('recycl') || question.toLowerCase().contains('déchet')) {
      suggestions.add('Comment faire du compost ?');
      suggestions.add('Réduire ses déchets plastiques ?');
    }
    
    if (question.toLowerCase().contains('énergie') || question.toLowerCase().contains('électricité')) {
      suggestions.add('Quelle isolation pour ma maison ?');
      suggestions.add('Comment économiser l\'eau ?');
    }
    
    // Si aucune suggestion spécifique, donner des suggestions par défaut
    if (suggestions.isEmpty) {
      suggestions = [
        'Comment limiter mon impact environnemental ?',
        'Conseils pour une alimentation durable',
        'Comprendre les labels écologiques',
      ];
    }
    
    // Limiter à max 3 suggestions
    return suggestions.take(3).toList();
  }

  /// Obtenir une réponse de ChatGPT avec le contexte de la conversation
  Future<Map<String, dynamic>> getResponseWithContext(
    String message, {
    List<Map<String, dynamic>>? context,
    Map<String, dynamic>? userData,
  }) async {
    if (!_isConfigured) {
      return {
        'response': "Le service n'est pas initialisé. Veuillez vérifier votre configuration.",
        'actions': [],
        'suggestions': [],
        'productRecommendations': <ProductModel>[],
        'articleRecommendations': <ArticleModel>[],
      };
    }
    
    try {
      final response = await _getChatGPTResponse(message, context: context);
      
      // Générer des recommandations basées sur la conversation
      final productRecommendations = await generateProductRecommendations(messageContext: message);
      final articleRecommendations = await generateArticleRecommendations(messageContext: message);
      
      return {
        'response': response['response'],
        'actions': response['actions'] ?? [],
        'suggestions': response['suggestions'] ?? [],
        'productRecommendations': productRecommendations,
        'articleRecommendations': articleRecommendations,
      };
    } catch (e) {
      print('Exception lors de la communication avec le service IA: $e');
      return {
        'response': "Désolé, une erreur s'est produite lors de la communication: $e",
        'actions': [],
        'suggestions': [],
        'productRecommendations': <ProductModel>[],
        'articleRecommendations': <ArticleModel>[],
      };
    }
  }

  /// Méthode interne pour communiquer avec l'API ChatGPT
  Future<Map<String, dynamic>> _getChatGPTResponse(String message, {List<Map<String, dynamic>>? context}) async {
    // Simulation de réponse pour le développement
    await Future.delayed(const Duration(seconds: 1));
    return {
      'response': "Voici une réponse simulée à votre message: $message",
      'actions': ['action1', 'action2'],
      'suggestions': ['suggestion1', 'suggestion2'],
    };
  }

  /// Générer des recommandations de produits basées sur le contexte de la conversation
  Future<List<ProductModel>> generateProductRecommendations({String? messageContext}) async {
    try {
      // Dans une implémentation réelle, vous utiliseriez le contexte de la conversation
      // pour obtenir des recommandations pertinentes depuis une API ou une base de données
      
      // Pour l'instant, nous retournons des exemples de produits écologiques
      return [
        ProductModel(
          id: 'prod-eco-1',
          name: 'Bouteille réutilisable en acier inoxydable',
          brand: 'EcoLife',
          description: 'Bouteille isotherme qui garde vos boissons chaudes pendant 12h et froides pendant 24h. Fabriquée à partir de matériaux recyclés.',
          price: 24.99,
          imageUrl: 'assets/images/products/bottle.png',
          categories: ['Maison', 'Zéro déchet'],
          isEcoFriendly: true,
          merchantUrl: 'https://example.com/eco-bottle',
        ),
        ProductModel(
          id: 'prod-eco-2',
          name: 'Sac à provisions en coton bio',
          brand: 'GreenBag',
          description: 'Sac réutilisable en coton biologique, durable et lavable. Remplacez vos sacs plastiques par cette alternative écologique.',
          price: 12.50,
          imageUrl: 'assets/images/products/bag.png',
          categories: ['Accessoires', 'Zéro déchet'],
          isEcoFriendly: true,
          merchantUrl: 'https://example.com/green-bag',
        ),
        ProductModel(
          id: 'prod-eco-3',
          name: 'Brosse à dents en bambou',
          brand: 'EcoDent',
          description: 'Brosse à dents avec manche en bambou biodégradable et poils en nylon recyclable. Emballage minimal et compostable.',
          price: 4.99,
          imageUrl: 'assets/images/products/toothbrush.png',
          categories: ['Hygiène', 'Salle de bain'],
          isEcoFriendly: true,
          merchantUrl: 'https://example.com/bamboo-brush',
        ),
      ];
    } catch (e) {
      print('Erreur lors de la génération des recommandations de produits: $e');
      return [];
    }
  }

  /// Générer des recommandations d'articles basées sur le contexte de la conversation
  Future<List<ArticleModel>> generateArticleRecommendations({String? messageContext}) async {
    try {
      // Dans une implémentation réelle, vous utiliseriez le contexte de la conversation
      // pour obtenir des recommandations pertinentes depuis une API ou une base de données
      
      // Pour l'instant, nous retournons des exemples d'articles sur l'écologie
      return [
        ArticleModel(
          id: 'art-eco-1',
          title: 'Comment réduire votre empreinte carbone au quotidien',
          content: "Cet article présente 10 façons simples de réduire votre empreinte carbone dans votre vie quotidienne, de l'alimentation aux transports en passant par la consommation d'énergie à la maison.",
          summary: 'Découvrez des gestes simples pour réduire votre impact environnemental au quotidien.',
          imageUrl: 'assets/images/articles/carbon_footprint.jpg',
          categories: ['Conseils pratiques', 'Empreinte carbone'],
          readTimeMinutes: 5,
          publishDate: DateTime.now().subtract(const Duration(days: 3)),
          authorName: 'Marie Dubois',
        ),
        ArticleModel(
          id: 'art-eco-2',
          title: 'Le guide du compostage pour débutants',
          content: 'Tout ce que vous devez savoir pour commencer à composter chez vous, même si vous vivez en appartement. Découvrez les différentes méthodes, ce que vous pouvez composter et les erreurs à éviter.',
          summary: 'Apprenez à composter facilement, même en espace réduit.',
          imageUrl: 'assets/images/articles/composting.jpg',
          categories: ['Jardinage', 'Zéro déchet'],
          readTimeMinutes: 8,
          publishDate: DateTime.now().subtract(const Duration(days: 7)),
          authorName: 'Thomas Martin',
        ),
        ArticleModel(
          id: 'art-eco-3',
          title: 'Les labels écologiques : comment s\'y retrouver ?',
          content: 'Face à la multiplication des labels environnementaux, il peut être difficile de s\'y retrouver. Cet article décrypte les principaux labels écologiques et vous aide à faire des choix éclairés.',
          summary: 'Un guide pour comprendre et reconnaître les labels écologiques fiables.',
          imageUrl: 'assets/images/articles/eco_labels.jpg',
          categories: ['Consommation responsable', 'Guides'],
          readTimeMinutes: 6,
          publishDate: DateTime.now().subtract(const Duration(days: 14)),
          authorName: 'Sophie Legrand',
        ),
      ];
    } catch (e) {
      print('Erreur lors de la génération des recommandations d\'articles: $e');
      return [];
    }
  }
}