import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Service qui gère l'intégration avec Ollama via l'API Node.js pour le chatbot écologique
class OllamaService {
  static OllamaService? _instance;
  bool _isInitialized = false;
  bool _useApiProxy = true; // Par défaut, utiliser l'API proxy
  
  // Configuration de l'API
  String _apiBaseUrl = 'http://10.0.2.2:3000/api'; // URL de l'API Node.js avec l'adresse pour émulateur Android
  String _modelName = 'llama3:8b'; // Modèle par défaut plus léger
  
  // Liste des modèles disponibles et leurs caractéristiques
  final Map<String, Map<String, dynamic>> _modelConfigs = {
    'llama3:8b': {
      'name': 'Llama 3 (8B)',
      'description': 'Modèle léger et rapide, idéal pour réponses simples',
      'size': 'small',
      'ram_required': 4, // Go de RAM requis
      'temperature': 0.5,
      'top_p': 0.7,
      'num_predict': 300,
    },
    'llama3': {
      'name': 'Llama 3 (Standard)',
      'description': 'Modèle standard avec bon équilibre vitesse/qualité',
      'size': 'medium',
      'ram_required': 8,
      'temperature': 0.7,
      'top_p': 0.9,
      'num_predict': 500,
    },
    'llama3:70b': {
      'name': 'Llama 3 (70B)',
      'description': 'Modèle complet pour réponses détaillées',
      'size': 'large',
      'ram_required': 16,
      'temperature': 0.8,
      'top_p': 0.9,
      'num_predict': 800,
    },
  };
  
  // Adresse hôte à utiliser (10.0.2.2 pour émulateur Android, localhost sinon)
  final String _hostAddress = Platform.isAndroid ? '10.0.2.2' : 'localhost';
  
  // Cache pour l'historique des conversations
  final Map<String, List<Map<String, String>>> _conversationHistory = {};
  final int _maxHistoryLength = 10; // Nombre maximum de messages dans l'historique
  
  /// Constructeur privé
  OllamaService._() {
    // Ajuster les URL en fonction de la plateforme
    _apiBaseUrl = 'http://$_hostAddress:3000/api';
    debugPrint('🔧 Configuration pour ${Platform.isAndroid ? "Android" : "Desktop"}, host: $_hostAddress');
  }
  
  /// Singleton pour le service Ollama
  static OllamaService get instance {
    _instance ??= OllamaService._();
    return _instance!;
  }

  /// Initialiser le service en vérifiant la connexion à l'API
  Future<void> initialize() async {
    if (_isInitialized) return;

    debugPrint('🔄 Tentative d\'initialisation du service OllamaService');
    debugPrint('📡 URL de l\'API: $_apiBaseUrl');

    try {
      // Vérifier que l'API est accessible
      debugPrint('🔍 Vérification de l\'accès à l\'API...');
      final response = await http.get(Uri.parse('$_apiBaseUrl/health'))
        .timeout(const Duration(seconds: 5));
      
      debugPrint('📊 Réponse du health check: ${response.statusCode} - ${response.body}');
      
      if (response.statusCode == 200) {
        // Vérifier maintenant la connexion à Ollama via l'API
        debugPrint('🔍 Vérification de la connexion à Ollama via l\'API...');
        final ollamaStatus = await http.get(Uri.parse('$_apiBaseUrl/llm/status'))
          .timeout(const Duration(seconds: 5));
        
        debugPrint('📊 Réponse du status Ollama: ${ollamaStatus.statusCode} - ${ollamaStatus.body}');
        
        if (ollamaStatus.statusCode == 200) {
          final statusData = jsonDecode(ollamaStatus.body);
          final bool isConnected = statusData['connected'] == true;
          
          debugPrint('🔌 Ollama connecté: $isConnected');
          
          if (isConnected) {
            _isInitialized = true;
            debugPrint('✅ Service API et Ollama initialisés avec succès');
          } else {
            debugPrint('❌ L\'API est accessible mais Ollama n\'est pas connecté');
            throw Exception('L\'API est accessible mais Ollama n\'est pas connecté');
          }
        } else {
          debugPrint('❌ Impossible d\'obtenir le statut d\'Ollama via l\'API');
          throw Exception('Impossible d\'obtenir le statut d\'Ollama via l\'API');
        }
      } else {
        debugPrint('❌ Impossible de se connecter à l\'API (code ${response.statusCode})');
        throw Exception('Impossible de se connecter à l\'API (code ${response.statusCode})');
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'initialisation du service: $e');
      // Tentative de connexion directe à Ollama comme fallback
      _tryDirectOllamaConnection();
    }
  }

  /// Tentative de connexion directe à Ollama si l'API ne répond pas
  Future<void> _tryDirectOllamaConnection() async {
    debugPrint('🔄 Tentative de connexion directe à Ollama...');
    final ollamaDirectUrl = 'http://$_hostAddress:11434';
    debugPrint('🔍 Utilisation de l\'URL: $ollamaDirectUrl');
    
    try {
      // Vérifier l'accès à Ollama en testant l'API de liste des modèles
      // au lieu de /api/health qui peut ne pas exister dans certaines versions
      final response = await http.get(Uri.parse('$ollamaDirectUrl/api/tags'))
        .timeout(const Duration(seconds: 5));
      
      if (response.statusCode == 200) {
        debugPrint('✅ Connexion directe à Ollama réussie! Utilisation du mode direct.');
        // Vérifier si le modèle llama3 est disponible
        final jsonResponse = jsonDecode(response.body);
        final models = jsonResponse['models'] as List;
        final hasLlama3 = models.any((model) => model['name'] == _modelName);
        
        if (hasLlama3) {
          debugPrint('✅ Modèle $_modelName trouvé!');
        } else {
          debugPrint('⚠️ Modèle $_modelName non trouvé. Veuillez l\'installer avec "ollama pull llama3"');
        }
        
        // Changer l'URL pour pointer directement vers Ollama
        _apiBaseUrl = '$ollamaDirectUrl/api';
        _useApiProxy = false; // Désactiver le proxy API puisqu'on accède directement à Ollama
        debugPrint('🔄 Mode direct activé: _useApiProxy = $_useApiProxy');
        _isInitialized = true;
      } else {
        debugPrint('❌ Échec de la connexion directe à Ollama (code ${response.statusCode})');
        _isInitialized = false;
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la connexion directe à Ollama: $e');
      
      // Tentative alternative avec juste un accès au serveur de base
      try {
        final baseResponse = await http.get(Uri.parse(ollamaDirectUrl))
          .timeout(const Duration(seconds: 5));
        
        if (baseResponse.statusCode == 200 || baseResponse.statusCode == 404) {
          // Même un 404 sur l'URL de base signifie que le serveur est en cours d'exécution
          debugPrint('✅ Serveur Ollama détecté! Utilisation du mode direct.');
          _apiBaseUrl = '$ollamaDirectUrl/api';
          _useApiProxy = false; // Désactiver le proxy API
          debugPrint('🔄 Mode direct activé: _useApiProxy = $_useApiProxy');
          _isInitialized = true;
        } else {
          _isInitialized = false;
        }
      } catch (e2) {
        debugPrint('❌ Échec de la connexion au serveur Ollama de base: $e2');
        _isInitialized = false;
        
        // Afficher un message spécifique pour Android
        if (Platform.isAndroid) {
          debugPrint('💡 Sur Android, assurez-vous que votre serveur Ollama accepte les connexions externes');
          debugPrint('💡 Conseil: Vérifiez votre configuration réseau et les pare-feu');
        }
      }
    }
  }

  /// Envoyer une requête à l'API et obtenir une réponse du modèle Llama3
  Future<String> getResponse(String text) async {
    debugPrint('📝 Demande de réponse pour: "$text"');
    
    if (!_isInitialized) {
      debugPrint('🔄 Service non initialisé, tentative d\'initialisation...');
      await initialize();
      if (!_isInitialized) {
        debugPrint('❌ Échec de l\'initialisation, utilisation du mode hors ligne');
        if (Platform.isAndroid) {
          return "Désolé, je ne peux pas vous répondre pour le moment. Sur un émulateur Android, vérifiez que:\n" +
                 "1. Votre serveur API est en cours d'exécution sur votre machine hôte\n" +
                 "2. Le serveur écoute sur TOUTES les adresses (0.0.0.0), pas seulement localhost\n" +
                 "3. Aucun pare-feu ne bloque la connexion";
        } else {
          return "Désolé, je ne peux pas vous répondre pour le moment. Veuillez vérifier que l'API et le serveur Ollama sont bien démarrés.";
        }
      }
    }

    try {
      // Utiliser la nouvelle méthode generateResponse avec gestion de timeout
      final response = await generateResponse(text, _modelName);
      
      if (response['success'] == true) {
        // Vérifier s'il y a eu un timeout
        if (response['timeout'] == true) {
          debugPrint('⚠️ Timeout détecté lors de la génération de la réponse');
          return response['message'];
        }
        return response['message'];
      } else {
        debugPrint('❌ Erreur: ${response['message']}');
        return "Désolé, une erreur s'est produite: ${response['message']}";
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'appel à l\'API: $e');
      return "Une erreur de communication s'est produite avec l'API. Veuillez vérifier que l'API et Ollama fonctionnent correctement.";
    }
  }
  
  /// Obtenir une réponse directement d'Ollama (mode fallback)
  Future<String> _getDirectOllamaResponse(String text) async {
    try {
      debugPrint('📤 Envoi direct à Ollama pour: "$text"');
      final ollamaUrl = 'http://$_hostAddress:11434/api/chat';
      
      // Prompt système pour l'écologie
      final systemPrompt = '''
Tu es GreenBot, un assistant spécialisé en écologie, développement durable et protection de l'environnement. Tu as été conçu pour fournir des informations précises, scientifiquement fondées et actuelles sur tous les sujets liés à l'écologie.

EXPERTISE:
- Changement climatique et ses impacts
- Biodiversité et conservation des écosystèmes
- Énergies renouvelables et transition énergétique
- Gestion des déchets et économie circulaire
- Agriculture durable et systèmes alimentaires
- Mobilité verte et transport durable
- Consommation responsable et empreinte carbone
- Solutions fondées sur la nature

COMPORTEMENT:
- Réponds toujours avec des informations basées sur des faits scientifiques validés
- Propose des conseils pratiques et réalisables adaptés à différents contextes
- Présente les différents aspects des problématiques écologiques, y compris les débats existants
- Utilise un ton positif et encourageant, mais reste réaliste sur les défis
- Reconnais les limites de tes connaissances quand c'est le cas
- Évite le jargon technique et explique les concepts complexes de manière accessible
''';

      // Préparer la requête directe à Ollama
      final payload = jsonEncode({
        'model': _modelName,
        'messages': [
          {'role': 'system', 'content': systemPrompt},
          {'role': 'user', 'content': text}
        ],
        'stream': false,
        'temperature': 0.5,
        'top_p': 0.8
      });
      
      // Envoyer la requête directement à Ollama
      final response = await http.post(
        Uri.parse(ollamaUrl),
        headers: {'Content-Type': 'application/json'},
        body: payload
      ).timeout(const Duration(seconds: 60));
      
      debugPrint('📊 Réponse d\'Ollama: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final content = jsonResponse['message']?['content'] ?? '';
        debugPrint('✅ Réponse directe d\'Ollama reçue (${content.length} caractères)');
        return content.toString();
      } else {
        debugPrint('❌ Erreur d\'Ollama: ${response.statusCode} - ${response.body}');
        return "Désolé, une erreur s'est produite avec le serveur Ollama (${response.statusCode}).";
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de l\'appel direct à Ollama: $e');
      return "Une erreur de communication s'est produite avec le serveur Ollama.";
    }
  }
  
  /// Obtenir la liste des modèles disponibles
  Future<List<String>> getAvailableModels() async {
    debugPrint('🔍 Récupération des modèles disponibles...');
    
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        debugPrint('❌ Service non initialisé, impossible de récupérer les modèles');
        return [];
      }
    }
    
    try {
      // Mode direct à Ollama
      if (_apiBaseUrl.contains('11434')) {
        final ollamaTagsUrl = 'http://$_hostAddress:11434/api/tags';
        final response = await http.get(Uri.parse(ollamaTagsUrl));
        
        if (response.statusCode == 200) {
          final jsonResponse = jsonDecode(response.body);
          final models = (jsonResponse['models'] as List?)?.map((m) => m['name'].toString()).toList() ?? [];
          debugPrint('✅ Modèles récupérés directement d\'Ollama: $models');
          return models;
        } else {
          debugPrint('❌ Erreur lors de la récupération des modèles: ${response.statusCode}');
          return [];
        }
      }
      
      // Via l'API
      final response = await http.get(Uri.parse('$_apiBaseUrl/llm/models'));
      
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final List<dynamic> modelsList = jsonResponse['models'] ?? [];
        debugPrint('✅ Modèles récupérés via l\'API: $modelsList');
        return modelsList.map((model) => model.toString()).toList();
      } else {
        debugPrint('❌ Erreur lors de la récupération des modèles: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la récupération des modèles: $e');
      return [];
    }
  }
  
  /// Tester des paramètres spécifiques pour le modèle
  Future<Map<String, dynamic>> testParameters({
    required String text,
    String? model,
    double? temperature,
    double? topP
  }) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return {'error': 'Service non initialisé'};
      }
    }
    
    try {
      final Map<String, dynamic> params = {'text': text};
      
      if (model != null) params['model'] = model;
      if (temperature != null) params['temperature'] = temperature;
      if (topP != null) params['topP'] = topP;
      
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/llm/test-parameters'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(params)
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return {'error': 'Erreur ${response.statusCode}'};
      }
    } catch (e) {
      return {'error': e.toString()};
    }
  }
  
  /// Vérifier si le service est initialisé
  bool get isInitialized => _isInitialized;
  
  /// Vérifier si nous utilisons l'API proxy
  bool get useApiProxy => _useApiProxy;
  
  /// Définir l'utilisation de l'API proxy
  set useApiProxy(bool value) {
    debugPrint('🔄 Configuration du mode API proxy: $value');
    _useApiProxy = value;
    // Si on désactive le proxy mais qu'on n'est pas en mode direct,
    // on s'assure que l'URL pointe vers Ollama direct
    if (!value && !_apiBaseUrl.contains('11434')) {
      _apiBaseUrl = 'http://$_hostAddress:11434/api';
      debugPrint('🔄 URL API mise à jour pour le mode direct: $_apiBaseUrl');
    }
  }
  
  /// Mettre à jour l'URL de l'API
  void updateApiUrl(String url) {
    debugPrint('🔄 Mise à jour de l\'URL de l\'API: $url');
    _apiBaseUrl = url;
    _isInitialized = false; // Forcer la réinitialisation avec la nouvelle URL
  }

  Future<Map<String, dynamic>> generateResponse(
    String prompt, 
    String modelName, 
    {
      double? temperature,
      double? topP,
      int? numPredict,
      Function(String chunk)? onResponseChunk,
      String? conversationId
    }
  ) async {
    try {
      // Déterminer les paramètres optimaux pour le modèle
      final modelConfig = getModelParams(modelName);
      final double finalTemp = temperature ?? modelConfig['temperature'] ?? 0.7;
      final double finalTopP = topP ?? modelConfig['top_p'] ?? 0.9;
      final int finalNumPredict = numPredict ?? modelConfig['num_predict'] ?? 300;
      
      // Identifiant de conversation unique si non fourni
      final String finalConvId = conversationId ?? 'default';
      
      // Obtenir l'historique de la conversation
      final history = getConversationHistory(finalConvId);
      
      // Préparer les messages avec l'historique
      final List<Map<String, String>> messages = [];
      
      // Ajouter le prompt système s'il n'existe pas dans l'historique
      if (history.isEmpty || history.first['role'] != 'system') {
        final systemPrompt = 'Tu es GreenBot, un assistant écologique. Réponds de façon concise en te basant sur des faits scientifiques.';
        messages.add({'role': 'system', 'content': systemPrompt});
        
        // Ajouter au début de l'historique
        if (history.isEmpty) {
          addToHistory(finalConvId, 'system', systemPrompt);
        }
      } else {
        // Utiliser le prompt système existant
        messages.add(history.first);
      }
      
      // Ajouter l'historique récent (sans le prompt système)
      if (history.length > 1) {
        messages.addAll(history.sublist(1));
      }
      
      // Ajouter le prompt actuel s'il n'est pas déjà dans l'historique
      if (history.isEmpty || history.last['content'] != prompt) {
        messages.add({'role': 'user', 'content': prompt});
        
        // Mémoriser la question
        addToHistory(finalConvId, 'user', prompt);
      }
      
      debugPrint('📤 Génération avec ${messages.length} messages dans l\'historique');
      
      if (_useApiProxy) {
        debugPrint('📤 Génération via API proxy: $prompt');
        // Utiliser l'API proxy
        // Note: Le streaming via l'API Node.js nécessite des modifications côté serveur
        // Nous allons donc conserver le comportement actuel pour ce mode
        
        // Construction du payload avec historique (format simplifié)
        final Map<String, dynamic> payload = {
          'text': prompt,
          'model': modelName,
          'temperature': finalTemp,
          'topP': finalTopP,
          'num_predict': finalNumPredict
        };
        
        // Ajouter l'historique si disponible
        if (messages.length > 1) {
          payload['history'] = messages;
        }
        
        final response = await http.post(
          Uri.parse('$_apiBaseUrl/llm/generate'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(payload),
        ).timeout(const Duration(seconds: 120));

        // Vérifier si la réponse contient du HTML au lieu du JSON
        if (response.body.trim().toLowerCase().startsWith('<!doctype html') || 
            response.body.trim().toLowerCase().startsWith('<html')) {
          debugPrint('❌ Erreur: La réponse est du HTML au lieu du JSON');
          return {
            'success': false,
            'message': 'Erreur de communication: Le serveur a renvoyé une page HTML au lieu du JSON. Vérifiez la configuration du serveur.'
          };
        }

        try {
          final data = jsonDecode(response.body);
          
          // Vérifier si c'est un timeout de l'API
          if (data['status'] == 'TIMEOUT') {
            debugPrint('⚠️ Timeout détecté dans la réponse de l\'API');
            return {
              'success': true,
              'timeout': true,
              'message': data['response'] ?? 'La génération de réponse a pris trop de temps.',
            };
          }
          
          if (response.statusCode == 200 && data['status'] == 'OK') {
            debugPrint('✅ Réponse API reçue avec succès');
            
            // Mémoriser la réponse dans l'historique
            addToHistory(finalConvId, 'assistant', data['response']);
            
            return {
              'success': true,
              'message': data['response'],
            };
          } else {
            debugPrint('❌ Erreur API: ${data['message']}');
            return {
              'success': false,
              'message': 'Erreur: ${data['message'] ?? "Une erreur est survenue"}',
            };
          }
        } catch (jsonError) {
          debugPrint('❌ Erreur lors du décodage JSON: $jsonError');
          debugPrint('❌ Contenu reçu: ${response.body.substring(0, min(100, response.body.length))}...');
          
          return {
            'success': false,
            'message': 'Erreur lors du décodage de la réponse. Format de réponse invalide.',
          };
        }
      } else {
        debugPrint('📤 Génération directe via Ollama: $prompt');
       
        // Si un callback de streaming est fourni, utiliser le mode stream
        if (onResponseChunk != null) {
          debugPrint('🔄 Utilisation du mode streaming');
          
          final request = http.Request(
            'POST', 
            Uri.parse('http://$_hostAddress:11434/api/chat')
          );
          
          request.headers['Content-Type'] = 'application/json';
          request.body = jsonEncode({
            'model': modelName,
            'messages': messages,
            'stream': true,
            'temperature': finalTemp,
            'top_p': finalTopP,
            'num_predict': finalNumPredict
          });
          
          final streamedResponse = await http.Client().send(request)
              .timeout(const Duration(seconds: 90));
              
          if (streamedResponse.statusCode == 200) {
            String fullResponse = '';
            
            // Traiter le flux de données
            await for (var chunk in streamedResponse.stream.transform(utf8.decoder)) {
              // Chaque chunk peut contenir plusieurs lignes JSON
              final lines = chunk.split('\n').where((line) => line.isNotEmpty);
              
              for (final line in lines) {
                try {
                  final data = jsonDecode(line);
                  if (data.containsKey('message') && 
                      data['message'].containsKey('content') &&
                      data['message']['content'] != null &&
                      data['message']['content'].isNotEmpty) {
                    
                    final content = data['message']['content'];
                    onResponseChunk(content);
                    fullResponse += content;
                  }
                } catch (e) {
                  debugPrint('⚠️ Erreur parsing chunk JSON: $e');
                }
              }
            }
            
            debugPrint('✅ Streaming terminé, réponse complète générée');
            
            // Mémoriser la réponse complète dans l'historique
            addToHistory(finalConvId, 'assistant', fullResponse);
            
            return {
              'success': true,
              'message': fullResponse,
            };
          } else {
            debugPrint('❌ Erreur streaming: ${streamedResponse.statusCode}');
            return {
              'success': false,
              'message': 'Erreur lors du streaming: ${streamedResponse.statusCode}',
            };
          }
        } else {
          // Mode non-streaming (code existant)
          final response = await http.post(
            Uri.parse('http://$_hostAddress:11434/api/chat'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'model': modelName,
              'messages': messages,
              'stream': false,
              'temperature': finalTemp,
              'top_p': finalTopP,
              'num_predict': finalNumPredict
            }),
          ).timeout(const Duration(seconds: 90));

          // Vérifier si la réponse contient du HTML au lieu du JSON
          if (response.body.trim().toLowerCase().startsWith('<!doctype html') || 
              response.body.trim().toLowerCase().startsWith('<html')) {
            debugPrint('❌ Erreur: La réponse est du HTML au lieu du JSON');
            return {
              'success': false,
              'message': 'Erreur de communication: Le serveur a renvoyé une page HTML au lieu du JSON. Vérifiez que Ollama est en cours d\'exécution.'
            };
          }

          try {
            final data = jsonDecode(response.body);
            if (response.statusCode == 200) {
              debugPrint('✅ Réponse directe d\'Ollama reçue avec succès');
              
              // Mémoriser la réponse dans l'historique
              final content = data['message']['content'] ?? 'Pas de réponse';
              addToHistory(finalConvId, 'assistant', content);
              
              return {
                'success': true,
                'message': content,
              };
            } else {
              debugPrint('❌ Erreur Ollama: ${data['error'] ?? 'Erreur inconnue'}');
              return {
                'success': false,
                'message': 'Erreur: ${data['error'] ?? "Une erreur est survenue"}',
              };
            }
          } catch (jsonError) {
            debugPrint('❌ Erreur lors du décodage JSON: $jsonError');
            debugPrint('❌ Contenu reçu: ${response.body.substring(0, min(100, response.body.length))}...');
            
            return {
              'success': false,
              'message': 'Erreur lors du décodage de la réponse. Format de réponse invalide.',
            };
          }
        }
      }
    } on TimeoutException {
      debugPrint('⚠️ Timeout lors de la génération de la réponse');
      
      // Si on est en mode API proxy, essayer de passer en mode direct
      if (_useApiProxy) {
        debugPrint('🔄 Tentative de basculement vers le mode direct après timeout');
        _useApiProxy = false;
        
        try {
          // Tentative de connexion directe à Ollama comme fallback
          await _tryDirectOllamaConnection();
          if (_isInitialized) {
            debugPrint('✅ Basculement réussi, nouvelle tentative en mode direct');
            // Réessayer avec la connexion directe
            return await generateResponse(prompt, modelName, temperature: temperature, topP: topP);
          }
        } catch (e) {
          debugPrint('❌ Échec du basculement vers le mode direct: $e');
        }
      }
      
      return {
        'success': true, // On considère que c'est un succès pour ne pas afficher une erreur
        'timeout': true,
        'message': 'La génération de réponse a pris trop de temps. Veuillez essayer une question plus courte ou plus simple.',
      };
    } catch (e) {
      debugPrint('❌ Erreur lors de la génération de la réponse: $e');
      return {
        'success': false,
        'message': 'Erreur: $e',
      };
    }
  }

  /// Test approfondi de diagnostic qui vérifie toutes les connexions possibles
  Future<Map<String, dynamic>> runDiagnostic() async {
    debugPrint('🔍 Démarrage du diagnostic approfondi');
    final results = <String, dynamic>{
      'node_api': {
        'success': false,
        'message': 'Non testé',
        'details': {}
      },
      'direct_ollama': {
        'success': false,
        'message': 'Non testé',
        'details': {}
      },
      'recommendations': []
    };
    
    // Tester l'API Node.js
    try {
      debugPrint('🔍 Test de l\'API Node.js sur $_apiBaseUrl/health');
      final apiUrl = _apiBaseUrl.contains('3000') ? _apiBaseUrl : 'http://$_hostAddress:3000/api';
      
      // Tester la connexion brute d'abord (ping)
      try {
        final pingResponse = await http.get(
          Uri.parse('$apiUrl/health'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        
        results['node_api']['details']['ping'] = {
          'success': pingResponse.statusCode == 200,
          'status_code': pingResponse.statusCode,
          'content_type': pingResponse.headers['content-type'] ?? 'unknown',
          'body_preview': pingResponse.body.length > 100 
              ? '${pingResponse.body.substring(0, 100)}...' 
              : pingResponse.body
        };
        
        if (pingResponse.statusCode == 200) {
          try {
            final pingData = jsonDecode(pingResponse.body);
            results['node_api']['details']['ping']['json_valid'] = true;
            results['node_api']['details']['ping']['data'] = pingData;
          } catch (e) {
            results['node_api']['details']['ping']['json_valid'] = false;
            results['node_api']['details']['ping']['error'] = e.toString();
          }
        }
      } catch (e) {
        results['node_api']['details']['ping'] = {
          'success': false,
          'error': e.toString()
        };
        results['recommendations'].add('Le serveur Node.js ne répond pas. Vérifiez qu\'il est démarré avec `npm start`.');
      }
      
      // Tester le statut Ollama via l'API
      try {
        final ollamaStatusResponse = await http.get(
          Uri.parse('$apiUrl/llm/status'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        
        results['node_api']['details']['ollama_status'] = {
          'success': ollamaStatusResponse.statusCode == 200,
          'status_code': ollamaStatusResponse.statusCode,
          'content_type': ollamaStatusResponse.headers['content-type'] ?? 'unknown',
          'body_preview': ollamaStatusResponse.body.length > 100 
              ? '${ollamaStatusResponse.body.substring(0, 100)}...' 
              : ollamaStatusResponse.body
        };
        
        if (ollamaStatusResponse.statusCode == 200) {
          try {
            final statusData = jsonDecode(ollamaStatusResponse.body);
            results['node_api']['details']['ollama_status']['json_valid'] = true;
            results['node_api']['details']['ollama_status']['data'] = statusData;
            results['node_api']['details']['ollama_status']['ollama_connected'] = statusData['connected'] == true;
            
            if (statusData['connected'] != true) {
              results['recommendations'].add('Le serveur Node.js fonctionne mais ne parvient pas à se connecter à Ollama.');
            }
          } catch (e) {
            results['node_api']['details']['ollama_status']['json_valid'] = false;
            results['node_api']['details']['ollama_status']['error'] = e.toString();
          }
        }
      } catch (e) {
        results['node_api']['details']['ollama_status'] = {
          'success': false,
          'error': e.toString()
        };
      }
      
      // Résumé global de l'API Node
      final bool pingSuccess = results['node_api']['details']['ping'] != null && 
                               results['node_api']['details']['ping']['success'] == true;
      final bool statusSuccess = results['node_api']['details']['ollama_status'] != null && 
                                 results['node_api']['details']['ollama_status']['success'] == true;
      final bool ollamaConnected = results['node_api']['details']['ollama_status'] != null && 
                                  results['node_api']['details']['ollama_status']['ollama_connected'] == true;
                                  
      results['node_api']['success'] = pingSuccess && statusSuccess && ollamaConnected;
      if (pingSuccess && statusSuccess && ollamaConnected) {
        results['node_api']['message'] = 'L\'API Node.js et Ollama fonctionnent correctement.';
      } else if (pingSuccess && statusSuccess) {
        results['node_api']['message'] = 'L\'API Node.js fonctionne mais Ollama n\'est pas connecté.';
      } else if (pingSuccess) {
        results['node_api']['message'] = 'L\'API Node.js répond partiellement.';
      } else {
        results['node_api']['message'] = 'L\'API Node.js ne répond pas.';
      }
    } catch (e) {
      results['node_api']['message'] = 'Erreur lors du test de l\'API Node.js: $e';
      results['recommendations'].add('Vérifiez que le serveur Node.js est démarré et accessible.');
    }
    
    // Tester Ollama directement
    try {
      debugPrint('🔍 Test d\'Ollama direct sur http://$_hostAddress:11434');
      final ollamaDirectUrl = 'http://$_hostAddress:11434';
      
      // Tester la liste des modèles
      try {
        final tagsResponse = await http.get(
          Uri.parse('$ollamaDirectUrl/api/tags'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        
        results['direct_ollama']['details']['tags'] = {
          'success': tagsResponse.statusCode == 200,
          'status_code': tagsResponse.statusCode,
          'content_type': tagsResponse.headers['content-type'] ?? 'unknown',
          'body_preview': tagsResponse.body.length > 100 
              ? '${tagsResponse.body.substring(0, 100)}...' 
              : tagsResponse.body
        };
        
        if (tagsResponse.statusCode == 200) {
          try {
            final tagsData = jsonDecode(tagsResponse.body);
            results['direct_ollama']['details']['tags']['json_valid'] = true;
            results['direct_ollama']['details']['tags']['data'] = tagsData;
            
            // Vérifier si llama3 est présent
            final models = tagsData['models'] as List? ?? [];
            final hasLlama3 = models.any((model) => model['name'] == 'llama3');
            results['direct_ollama']['details']['tags']['has_llama3'] = hasLlama3;
            
            if (!hasLlama3) {
              results['recommendations'].add('Le modèle llama3 n\'est pas installé. Exécutez `ollama pull llama3` pour l\'installer.');
            }
          } catch (e) {
            results['direct_ollama']['details']['tags']['json_valid'] = false;
            results['direct_ollama']['details']['tags']['error'] = e.toString();
          }
        }
      } catch (e) {
        results['direct_ollama']['details']['tags'] = {
          'success': false,
          'error': e.toString()
        };
        
        // Essayer un ping de base sur le serveur
        try {
          final pingResponse = await http.get(
            Uri.parse(ollamaDirectUrl),
          ).timeout(const Duration(seconds: 5));
          
          results['direct_ollama']['details']['ping'] = {
            'success': pingResponse.statusCode == 200 || pingResponse.statusCode == 404,
            'status_code': pingResponse.statusCode,
            'content_type': pingResponse.headers['content-type'] ?? 'unknown'
          };
          
          if (pingResponse.statusCode == 200 || pingResponse.statusCode == 404) {
            results['recommendations'].add('Ollama répond mais l\'API n\'est pas accessible. Vérifiez la version d\'Ollama.');
          }
        } catch (pingError) {
          results['direct_ollama']['details']['ping'] = {
            'success': false,
            'error': pingError.toString()
          };
          results['recommendations'].add('Ollama n\'est pas démarré ou n\'est pas accessible. Exécutez `ollama serve` pour le démarrer.');
        }
      }
      
      // Résumé global d'Ollama direct
      final bool tagsSuccess = results['direct_ollama']['details']['tags'] != null && 
                               results['direct_ollama']['details']['tags']['success'] == true;
      final bool hasLlama3 = results['direct_ollama']['details']['tags'] != null && 
                             results['direct_ollama']['details']['tags']['has_llama3'] == true;
      final bool pingSuccess = results['direct_ollama']['details']['ping'] != null && 
                               results['direct_ollama']['details']['ping']['success'] == true;
                               
      results['direct_ollama']['success'] = tagsSuccess && hasLlama3;
      if (tagsSuccess && hasLlama3) {
        results['direct_ollama']['message'] = 'Ollama fonctionne correctement et llama3 est installé.';
      } else if (tagsSuccess) {
        results['direct_ollama']['message'] = 'Ollama fonctionne, mais llama3 n\'est pas installé.';
      } else if (pingSuccess) {
        results['direct_ollama']['message'] = 'Ollama répond mais l\'API n\'est pas accessible.';
      } else {
        results['direct_ollama']['message'] = 'Ollama ne répond pas.';
      }
    } catch (e) {
      results['direct_ollama']['message'] = 'Erreur lors du test d\'Ollama: $e';
      results['recommendations'].add('Vérifiez qu\'Ollama est installé et démarré avec `ollama serve`.');
    }
    
    // Ajouter des recommandations globales
    if (!results['node_api']['success'] && !results['direct_ollama']['success']) {
      results['recommendations'].add('Aucune des deux méthodes de connexion ne fonctionne. Vérifiez les configurations réseau et pare-feu.');
      
      // Vérifier l'émulateur Android
      if (Platform.isAndroid) {
        results['recommendations'].add('Sur l\'émulateur Android, utilisez 10.0.2.2 au lieu de localhost pour les connexions.');
      }
    } else if (results['direct_ollama']['success'] && !results['node_api']['success']) {
      results['recommendations'].add('Utilisez le mode "Connexion directe à Ollama" dans les paramètres de l\'application.');
    }
    
    return results;
  }

  /// Interface utilisateur pour afficher le rapport de diagnostic
  static Future<void> showDiagnosticDialog(BuildContext context) async {
    final ollamaService = OllamaService.instance;
    bool isLoading = true;
    Map<String, dynamic> diagnosticResults = {};
    
    // Ouvrir le dialogue avant même d'avoir les résultats
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Diagnostic de connexion'),
              content: SizedBox(
                width: double.maxFinite,
                child: isLoading
                    ? const Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 16),
                          Text('Test des connexions en cours...')
                        ],
                      )
                    : SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildDiagnosticSection(
                              'API Node.js',
                              diagnosticResults['node_api']['success'],
                              diagnosticResults['node_api']['message'],
                            ),
                            const Divider(),
                            _buildDiagnosticSection(
                              'Connexion directe à Ollama',
                              diagnosticResults['direct_ollama']['success'],
                              diagnosticResults['direct_ollama']['message'],
                            ),
                            const Divider(),
                            const Text(
                              'Recommandations:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            ...List.generate(
                              (diagnosticResults['recommendations'] as List).length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                                    Expanded(
                                      child: Text(diagnosticResults['recommendations'][index]),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if ((diagnosticResults['recommendations'] as List).isEmpty)
                              const Text('Aucune recommandation nécessaire.')
                          ],
                        ),
                      ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Fermer'),
                ),
                if (!isLoading)
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        isLoading = true;
                      });
                      
                      // Relancer le diagnostic
                      ollamaService.runDiagnostic().then((results) {
                        setState(() {
                          isLoading = false;
                          diagnosticResults = results;
                        });
                      });
                    },
                    child: const Text('Relancer le test'),
                  ),
              ],
            );
          }
        );
      },
    );
    
    // Lancer le diagnostic
    diagnosticResults = await ollamaService.runDiagnostic();
    
    // Mettre à jour l'interface
    if (context.mounted) {
      Navigator.of(context).pop(); // Fermer le précédent dialogue
      
      // Rouvrir avec les résultats
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Diagnostic de connexion'),
            content: SizedBox(
              width: double.maxFinite,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDiagnosticSection(
                      'API Node.js',
                      diagnosticResults['node_api']['success'],
                      diagnosticResults['node_api']['message'],
                    ),
                    const Divider(),
                    _buildDiagnosticSection(
                      'Connexion directe à Ollama',
                      diagnosticResults['direct_ollama']['success'],
                      diagnosticResults['direct_ollama']['message'],
                    ),
                    const Divider(),
                    const Text(
                      'Recommandations:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ...List.generate(
                      (diagnosticResults['recommendations'] as List).length,
                      (index) => Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('• ', style: TextStyle(fontWeight: FontWeight.bold)),
                            Expanded(
                              child: Text(diagnosticResults['recommendations'][index]),
                            ),
                          ],
                        ),
                      ),
                    ),
                    if ((diagnosticResults['recommendations'] as List).isEmpty)
                      const Text('Aucune recommandation nécessaire.')
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Fermer'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  showDiagnosticDialog(context); // Relancer le diagnostic
                },
                child: const Text('Relancer le test'),
              ),
            ],
          );
        },
      );
    }
  }
  
  /// Créer une section pour le rapport de diagnostic
  static Widget _buildDiagnosticSection(String title, bool isSuccess, String message) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: isSuccess ? Colors.green : Colors.red,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(message),
      ],
    );
  }

  /// Obtenir le modèle actuellement utilisé
  String get currentModel => _modelName;
  
  /// Définir le modèle à utiliser
  set currentModel(String modelName) {
    if (_modelConfigs.containsKey(modelName)) {
      _modelName = modelName;
      debugPrint('🔄 Modèle changé pour: $_modelName');
    } else {
      debugPrint('⚠️ Modèle inconnu: $modelName, utilisation du modèle par défaut');
    }
  }
  
  /// Obtenir la liste des configurations de modèles
  Map<String, Map<String, dynamic>> get modelConfigs => _modelConfigs;
  
  /// Obtenir les paramètres recommandés pour un modèle
  Map<String, dynamic> getModelParams(String modelName) {
    final params = _modelConfigs[modelName];
    if (params == null) {
      return _modelConfigs[_modelName] ?? {};
    }
    return params;
  }
  
  /// Sélectionner automatiquement le meilleur modèle en fonction des ressources disponibles
  Future<String> selectBestModel() async {
    // Logique simplifiée - en production, il faudrait détecter la RAM disponible
    if (Platform.isAndroid) {
      // Sur Android, privilégier le modèle léger
      currentModel = 'llama3:8b';
    } else {
      // Sur desktop, on peut tenter le modèle standard
      currentModel = 'llama3';
    }
    
    return _modelName;
  }
  
  /// Ajouter un message à l'historique de conversation
  void addToHistory(String conversationId, String role, String content) {
    if (!_conversationHistory.containsKey(conversationId)) {
      _conversationHistory[conversationId] = [];
    }
    
    _conversationHistory[conversationId]!.add({
      'role': role,
      'content': content
    });
    
    // Limiter la taille de l'historique
    if (_conversationHistory[conversationId]!.length > _maxHistoryLength) {
      // Garder le premier message (système) et les derniers messages
      final systemPrompt = _conversationHistory[conversationId]!.first;
      _conversationHistory[conversationId]!.removeAt(0);
      _conversationHistory[conversationId]!.removeAt(0);
      _conversationHistory[conversationId]!.insert(0, systemPrompt);
    }
  }
  
  /// Obtenir l'historique de conversation
  List<Map<String, String>> getConversationHistory(String conversationId) {
    return _conversationHistory[conversationId] ?? [];
  }
  
  /// Effacer l'historique de conversation
  void clearConversationHistory(String conversationId) {
    _conversationHistory.remove(conversationId);
  }
}

class ProductCategoryService {
  static String determineCategory(String barcode) {
    if (barcode.startsWith('978') || barcode.startsWith('979'))
      return "Livres & Médias";
    else if (RegExp(r'^(000|00[1-9]|0[1-9][0-9])').hasMatch(barcode))
      return "Électronique";
    else if (RegExp(r'^(45[0-9])').hasMatch(barcode))
      return "Vêtements & Mode";
    else if (RegExp(r'^(35[0-9])').hasMatch(barcode))
      return "Beauté & Cosmétiques";
    else if (RegExp(r'^(50[0-9])').hasMatch(barcode))
      return "Produits Ménagers";
    // Autres catégories spécifiques
    else
      return "Divers"; // Catégorie par défaut
  }
  
  static IconData getCategoryIcon(String category) {
    switch(category) {
      case "Livres & Médias": return Icons.menu_book;
      case "Électronique": return Icons.devices;
      case "Vêtements & Mode": return Icons.checkroom;
      case "Beauté & Cosmétiques": return Icons.face;
      case "Produits Ménagers": return Icons.cleaning_services;
      case "Alimentation": return Icons.restaurant;
      default: return Icons.category;
    }
  }
  
  static List<String> getCategorySpecificFields(String category) {
    // Retourne les champs spécifiques à afficher selon la catégorie
    switch(category) {
      case "Livres & Médias": 
        return ["Auteur", "Éditeur", "Pages", "ISBN"];
      case "Électronique": 
        return ["Marque", "Modèle", "Spécifications", "Garantie"];
      case "Vêtements & Mode": 
        return ["Marque", "Taille", "Matière", "Entretien"];
      // Autres catégories
      default: 
        return ["Description", "Marque", "Caractéristiques"];
    }
  }
  
  static IconData getFieldIcon(String field) {
    switch(field) {
      case "Auteur": return Icons.person;
      case "Éditeur": return Icons.business;
      case "Pages": return Icons.book;
      case "ISBN": return Icons.numbers;
      case "Marque": return Icons.branding_watermark;
      case "Modèle": return Icons.model_training;
      case "Spécifications": return Icons.settings;
      case "Garantie": return Icons.verified;
      case "Taille": return Icons.format_size;
      case "Matière": return Icons.texture;
      case "Entretien": return Icons.wash;
      default: return Icons.info;
    }
  }
}

// Le fichier se termine ici 