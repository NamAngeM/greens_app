import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:greens_app/models/chatbot_message.dart';

/// Service pour interagir avec le backend Rasa
class RasaService {
  // Singleton pattern
  static final RasaService _instance = RasaService._internal();
  factory RasaService() => _instance;
  RasaService._internal();

  // Configuration
  String _baseUrl = 'http://localhost:5005';
  bool _isInitialized = false;
  
  // Getters
  bool get isInitialized => _isInitialized;
  String get baseUrl => _baseUrl;

  /// Initialiser le service avec l'URL du serveur Rasa
  Future<void> initialize({String? baseUrl}) async {
    try {
      if (baseUrl != null) {
        _baseUrl = baseUrl;
      }
      
      // Vérifier la connexion
      final response = await http.get(
        Uri.parse('$_baseUrl/status'),
        headers: {'Content-Type': 'application/json'},
      ).timeout(
        const Duration(seconds: 10), // Augmenter le timeout à 10 secondes
        onTimeout: () {
          print('Délai d\'attente dépassé lors de la connexion à Rasa');
          throw TimeoutException('Délai d\'attente dépassé lors de la connexion à Rasa');
        },
      );
      
      if (response.statusCode == 200) {
        print('RasaService initialisé avec succès: ${response.body}');
        _isInitialized = true;
      } else {
        print('Échec de la connexion à Rasa: ${response.statusCode}');
        _isInitialized = false;
      }
    } catch (e) {
      print('Exception lors de l\'initialisation de RasaService: $e');
      _isInitialized = false;
    }
  }

  /// Envoyer un message à Rasa et obtenir la réponse
  Future<List<Map<String, dynamic>>> sendMessage(
    String message, {
    String? senderId,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      if (!_isInitialized) {
        throw Exception('Le service Rasa n\'est pas initialisé.');
      }

      final uri = Uri.parse('$_baseUrl/webhooks/rest/webhook');
      final Map<String, dynamic> requestBody = {
        'sender': senderId ?? 'user',
        'message': message,
      };

      // Ajouter les métadonnées si elles sont présentes
      if (metadata != null) {
        requestBody['metadata'] = metadata;
      }

      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> responseData = jsonDecode(response.body);
        
        if (responseData.isEmpty) {
          return [{'text': "Je n'ai pas compris. Pouvez-vous reformuler ?"}];
        }
        
        return List<Map<String, dynamic>>.from(responseData);
      } else {
        print('Erreur Rasa: ${response.statusCode} - ${response.body}');
        return [{'text': "Erreur de communication avec le chatbot."}];
      }
    } catch (e) {
      print('Exception lors de l\'envoi du message à Rasa: $e');
      return [{'text': "Erreur de connexion avec le chatbot."}];
    }
  }

  /// Convertir les réponses Rasa en ChatbotMessage
  ChatbotMessage processRasaResponse(List<Map<String, dynamic>> responses, String sessionId) {
    // Traiter et fusionner plusieurs réponses, s'il y en a
    final List<String> textResponses = [];
    final Map<String, dynamic> actions = {};
    final List<String> suggestions = [];
    
    for (var i = 0; i < responses.length; i++) {
      final response = responses[i];
      
      // Traiter le texte
      if (response.containsKey('text')) {
        textResponses.add(response['text']);
      }
      
      // Traiter les boutons éventuels
      if (response.containsKey('buttons') && response['buttons'] is List) {
        final List<dynamic> buttons = response['buttons'];
        for (var j = 0; j < buttons.length; j++) {
          final button = buttons[j];
          if (button is Map<String, dynamic> && 
              button.containsKey('title') && 
              button.containsKey('payload')) {
            suggestions.add(button['title']);
            
            // Ajouter une action si payload est un format spécial
            if (button['payload'].toString().startsWith('/action_')) {
              actions['action_$j'] = {
                'type': 'ChatbotActionType.${_extractActionType(button['payload'])}',
                'title': button['title'],
                'data': button['payload'],
              };
            }
          }
        }
      }
      
      // Traiter les images éventuelles
      if (response.containsKey('image')) {
        actions['image_$i'] = {
          'type': 'ChatbotActionType.showImage',
          'title': 'Voir l\'image',
          'data': {'url': response['image']},
        };
      }
      
      // Traiter les pièces jointes éventuelles
      if (response.containsKey('attachment')) {
        actions['attachment_$i'] = {
          'type': 'ChatbotActionType.openAttachment',
          'title': 'Ouvrir la pièce jointe',
          'data': {'url': response['attachment']},
        };
      }
    }
    
    // Créer le message de réponse
    return ChatbotMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}_$sessionId',
      text: textResponses.join('\n\n'),
      isUser: false,
      timestamp: DateTime.now(),
      suggestedActions: suggestions,
      metadata: actions,
    );
  }
  
  /// Extraire le type d'action à partir du payload Rasa
  String _extractActionType(String payload) {
    if (payload.contains('action_calculate')) return 'calculateFootprint';
    if (payload.contains('action_products')) return 'showProducts';
    if (payload.contains('action_challenge')) return 'joinChallenge';
    if (payload.contains('action_scan')) return 'scanProduct';
    if (payload.contains('action_tips')) return 'showTips';
    if (payload.contains('action_navigate')) return 'navigate';
    return 'none';
  }
} 