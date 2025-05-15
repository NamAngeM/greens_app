import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:greens_app/models/chatbot_message.dart';
import 'package:uuid/uuid.dart';

/// Service qui gère la communication avec l'API Mistral pour le chatbot écologique
class ChatbotAIService with ChangeNotifier {
  static final ChatbotAIService _instance = ChatbotAIService._privateConstructor();
  
  factory ChatbotAIService() {
    return _instance;
  }
  
  // Constructeur privé
  ChatbotAIService._privateConstructor();
  
  static ChatbotAIService get instance => _instance;
  
  // Méthode pour créer une instance avec une initialisation asynchrone
  static Future<ChatbotAIService> createInstance() async {
    return _instance;
  }
  
  final String _huggingfaceUrl = 'https://api-inference.huggingface.co/models/mistralai/Mistral-7B-Instruct-v0.1';
  
  bool _isConfigured = false;
  final List<ChatbotMessage> _messages = [];
  bool _isLoading = false;
  String _hfApiKey = '';
  
  // Getters
  bool get isConfigured => _isConfigured;
  List<ChatbotMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  /// Initialise le service avec la clé API Hugging Face
  Future<void> initialize({
    required String huggingfaceApiKey,
  }) async {
    try {
      _hfApiKey = huggingfaceApiKey;
      
      print('Tentative de connexion à Mistral via Hugging Face avec la clé API...');
      
      // Tester l'API Hugging Face avec une requête simple
      final response = await http.post(
        Uri.parse(_huggingfaceUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_hfApiKey',
        },
        body: jsonEncode({
          'inputs': '<s>[INST] Dis bonjour et présente-toi en une phrase [/INST]</s>'
        }),
      ).timeout(const Duration(seconds: 10));
      
      print('Réponse du serveur Hugging Face: ${response.statusCode}');
      print('Contenu de la réponse: ${response.body}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        _isConfigured = true;
        print('Service Mistral initialisé avec succès via Hugging Face');
      } else {
        print('Erreur lors de l\'initialisation de Mistral via Hugging Face: ${response.statusCode} - ${response.body}');
        _isConfigured = false;
      }
    } catch (e) {
      print('Exception lors de l\'initialisation du service: $e');
      _isConfigured = false;
    }
  }
  
  /// Méthode pour envoyer un message et recevoir une réponse
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

      if (!_isConfigured) {
        // En mode hors ligne, utiliser des réponses prédéfinies
        final offlineResponse = _getOfflineResponse(message);
        final botMessage = ChatbotMessage(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          text: offlineResponse['response'] as String,
          isUser: false,
          timestamp: DateTime.now(),
          suggestedActions: offlineResponse['suggestions'] as List<String>? ?? [],
        );
        
        _messages.add(botMessage);
        _isLoading = false;
        notifyListeners();
        return botMessage;
      }
      
      // Récupérer la réponse de Mistral
      final response = await getResponseWithContext(message);
      
      // Créer le message de réponse
      final botMessage = ChatbotMessage(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        text: response['response'] as String,
        isUser: false,
        timestamp: DateTime.now(),
        suggestedActions: response['suggestions'] as List<String>? ?? [],
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

  /// Envoie un message à Mistral et récupère la réponse
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
      };
    }
    
    try {
      return await _getMistralResponse(message, context: context);
    } catch (e) {
      print('Exception lors de la communication avec le service IA: $e');
      return {
        'response': "Désolé, une erreur s'est produite lors de la communication: $e",
        'actions': [],
        'suggestions': [],
      };
    }
  }
  
  /// Obtenir une réponse du modèle Mistral via Hugging Face
  Future<Map<String, dynamic>> _getMistralResponse(
    String message, {
    List<Map<String, dynamic>>? context,
  }) async {
    try {
      // Préparer le contexte de la conversation pour Mistral
      String fullPrompt = '<s>[INST] ';
      
      // Ajouter le système prompt
      fullPrompt += '''
Tu es un assistant écologique spécialisé dans le développement durable et l'écologie. 
Ta mission est d'aider les utilisateurs à réduire leur empreinte carbone, adopter des habitudes plus durables, 
et comprendre les enjeux environnementaux. Tes réponses doivent être informatives, 
précises et encourageantes. Privilégie les conseils pratiques applicables au quotidien.

Règles à suivre:
1. Reste factuel et scientifique dans tes réponses
2. Propose des solutions concrètes et accessibles
3. Adapte tes conseils au profil de l'utilisateur quand c'est possible
4. Sois concis et direct dans tes réponses
5. Utilise un ton positif et motivant
''';
      
      // Ajouter le contexte des messages précédents
      if (context != null && context.isNotEmpty) {
        for (final msg in context.take(3)) { // Limiter à 3 messages pour éviter les dépassements de token
          if (msg['isUser'] == true) {
            fullPrompt += '\nUtilisateur: ${msg['text']}';
          } else {
            fullPrompt += '\nAssistant: ${msg['text']}';
          }
        }
      }
      
      // Ajouter le message actuel
      fullPrompt += '\n\nUtilisateur: $message\nAssistant: [/INST]</s>';
      
      // Envoyer la requête à Hugging Face
      final response = await http.post(
        Uri.parse(_huggingfaceUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_hfApiKey',
        },
        body: jsonEncode({
          'inputs': fullPrompt,
          'parameters': {
            'max_new_tokens': 512,
            'temperature': 0.7,
            'top_p': 0.95,
            'return_full_text': false
          }
        }),
      ).timeout(const Duration(seconds: 30));
      
      print('Réponse de Mistral via Hugging Face: ${response.statusCode}');
      
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final List responseData = jsonDecode(response.body);
        String content = '';
        
        if (responseData.isNotEmpty && responseData[0] is Map && responseData[0].containsKey('generated_text')) {
          content = responseData[0]['generated_text'];
          // Nettoyer la réponse si nécessaire
          if (content.startsWith('<s>') || content.startsWith('[INST]')) {
            content = content.replaceAll('<s>', '').replaceAll('</s>', '')
                           .replaceAll('[INST]', '').replaceAll('[/INST]', '').trim();
          }
        } else {
          content = "J'ai bien reçu votre message, mais je n'ai pas pu générer une réponse appropriée.";
        }
        
        // Générer des suggestions simples basées sur le message
        final suggestions = _generateSimpleSuggestions(message);
        
        return {
          'response': content,
          'actions': [],
          'suggestions': suggestions,
        };
      } else {
        print('Erreur lors de la communication avec Hugging Face: ${response.statusCode} - ${response.body}');
        return {
          'response': "Désolé, une erreur s'est produite lors de la communication avec le service IA (code ${response.statusCode}).",
          'actions': [],
          'suggestions': [],
        };
      }
    } catch (e) {
      print('Exception lors de la communication avec Hugging Face: $e');
      return {
        'response': "Désolé, une erreur s'est produite lors de la communication: $e",
        'actions': [],
        'suggestions': [],
      };
    }
  }
  
  /// Générer des suggestions simples basées sur le message
  List<String> _generateSimpleSuggestions(String message) {
    final lowerMessage = message.toLowerCase();
    
    if (lowerMessage.contains('empreinte') || lowerMessage.contains('carbone')) {
      return [
        'Comment calculer mon empreinte carbone ?',
        'Quels sont les gestes quotidiens pour la réduire ?',
        'Impact du transport sur l\'empreinte carbone ?'
      ];
    } else if (lowerMessage.contains('énergie') || lowerMessage.contains('électricité')) {
      return [
        'Comment réduire ma consommation d\'énergie ?',
        'Quelles sont les énergies renouvelables ?',
        'Comment isoler mon logement ?'
      ];
    } else if (lowerMessage.contains('déchet') || lowerMessage.contains('recycl')) {
      return [
        'Comment faire du compost ?',
        'Comment réduire mes déchets plastiques ?',
        'Que peut-on recycler ?'
      ];
    } else {
      return [
        'Comment réduire mon empreinte carbone ?',
        'Comment économiser l\'énergie ?',
        'Comment recycler correctement ?'
      ];
    }
  }
  
  /// Obtenir une réponse prédéfinie pour le mode hors ligne
  Map<String, dynamic> _getOfflineResponse(String message) {
    final messageLower = message.toLowerCase();
    
    // Réponses pour les questions sur l'empreinte carbone
    if (messageLower.contains('empreinte carbone') || 
        messageLower.contains('carbon') || 
        messageLower.contains('co2')) {
      return {
        'response': 'Pour réduire votre empreinte carbone, vous pouvez : limiter vos déplacements en voiture, privilégier les transports en commun, manger moins de viande, isoler votre logement, et réduire votre consommation d\'énergie.',
        'suggestions': [
          'Comment calculer mon empreinte carbone ?',
          'Quels aliments ont le plus d\'impact ?',
          'Comment réduire ma consommation d\'énergie ?'
        ]
      };
    }
    
    // Réponses pour les questions sur l'économie d'énergie
    if (messageLower.contains('économiser') || 
        messageLower.contains('énergie') || 
        messageLower.contains('électricité')) {
      return {
        'response': 'Pour économiser l\'énergie, vous pouvez : éteindre les appareils en veille, utiliser des ampoules LED, baisser le chauffage de 1°C (économie de 7%), laver le linge à basse température, et privilégier la lumière naturelle.',
        'suggestions': [
          'Quels appareils consomment le plus ?',
          'Comment isoler mon logement ?',
          'Quelles aides pour la rénovation énergétique ?'
        ]
      };
    }
    
    // Réponses pour les questions sur le recyclage
    if (messageLower.contains('recycl') || 
        messageLower.contains('déchet') || 
        messageLower.contains('poubelle') ||
        messageLower.contains('tri')) {
      return {
        'response': 'Pour bien recycler : triez vos déchets selon les consignes locales, rincez légèrement vos emballages, n\'emboîtez pas les déchets de matières différentes, et apportez les produits dangereux (piles, électronique) dans des points de collecte spécifiques.',
        'suggestions': [
          'Comment recycler les appareils électroniques ?',
          'Où jeter les piles usagées ?',
          'Comment faire du compost ?'
        ]
      };
    }
    
    // Réponses sur les produits écologiques
    if (messageLower.contains('produit') || 
        messageLower.contains('écologique') || 
        messageLower.contains('acheter') ||
        messageLower.contains('achat')) {
      return {
        'response': 'Privilégiez des produits avec des labels environnementaux (Écolabel, AB, FSC...), limitez les emballages, choisissez des produits durables et réparables, et pensez aux articles d\'occasion ou reconditionnés.',
        'suggestions': [
          'Quels sont les meilleurs labels écologiques ?',
          'Comment éviter le greenwashing ?',
          'Qu\'est-ce que l\'économie circulaire ?'
        ]
      };
    }
    
    // Réponse par défaut
    return {
      'response': 'Je suis en mode hors-ligne actuellement. Je peux vous renseigner sur la réduction de l\'empreinte carbone, les économies d\'énergie, le recyclage ou les produits écologiques. Que souhaitez-vous savoir ?',
      'suggestions': [
        'Comment réduire mon empreinte carbone ?',
        'Comment économiser l\'énergie ?',
        'Comment bien recycler ?'
      ]
    };
  }
} 