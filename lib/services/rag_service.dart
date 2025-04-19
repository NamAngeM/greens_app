import 'package:flutter/material.dart';
import 'package:greens_app/services/eco_knowledge_base.dart';
import 'package:greens_app/services/ollama_service.dart';

/// Service d'augmentation de réponses par récupération (RAG)
class RagService {
  static RagService? _instance;
  final EcoKnowledgeBase _knowledgeBase = EcoKnowledgeBase();
  final OllamaService _ollamaService = OllamaService.instance;
  bool _isInitialized = false;

  /// Constructeur privé
  RagService._();

  /// Singleton pour le service RAG
  static RagService get instance {
    _instance ??= RagService._();
    return _instance!;
  }

  /// Initialiser le service RAG
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Initialiser le service Ollama
      await _ollamaService.initialize();
      
      // Initialiser et charger la base de connaissances
      await _knowledgeBase.loadPredefinedDocuments();
      
      _isInitialized = true;
      debugPrint('Service RAG initialisé avec succès');
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation du service RAG: $e');
      _isInitialized = false;
    }
  }

  /// Obtenir une réponse augmentée à une question
  Future<String> getResponse(String query) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return "Désolé, je ne peux pas vous répondre pour le moment. Le service n'est pas initialisé correctement.\n\nAssurez-vous que le serveur Ollama est bien démarré et que le modèle llama3 est installé.";
      }
    }

    try {
      // 1. Rechercher des documents pertinents
      final relevantDocuments = await _knowledgeBase.search(query);
      
      // 2. Extraire le contenu des documents pour enrichir le contexte
      final contexts = relevantDocuments.map((doc) => 
        '${doc.title}:\n${doc.content}'
      ).toList();
      
      // Si aucun document n'est trouvé, utiliser directement le modèle Ollama
      if (contexts.isEmpty) {
        // Utiliser la nouvelle méthode generateResponse
        final response = await _ollamaService.generateResponse(query, 'llama3');
        
        // Vérifier s'il y a eu un timeout
        if (response['timeout'] == true) {
          debugPrint('⚠️ Timeout détecté dans RAG sans contexte');
          return "⚠️ ${response['message']}";
        }
        
        if (response['success'] == true) {
          return response['message'];
        } else {
          debugPrint('❌ Erreur dans RAG sans contexte: ${response['message']}');
          return "Désolé, une erreur s'est produite: ${response['message']}\n\nVeuillez vérifier que le serveur Ollama est en cours d'exécution et correctement configuré.";
        }
      }
      
      // 3. Construire un prompt enrichi avec le contexte
      final enhancedPrompt = '''
${query}

Contexte factuel pour t'aider à répondre:
----
${contexts.join('\n\n----\n\n')}
----

Utilise le contexte ci-dessus pour enrichir ta réponse, mais ne te limite pas à ces informations si tu connais d'autres faits pertinents. Ne mentionne pas explicitement le "contexte" dans ta réponse. Réponds directement comme si c'était ta connaissance.
''';
      
      // 4. Envoyer le prompt enrichi au modèle Ollama avec gestion des timeouts
      final response = await _ollamaService.generateResponse(enhancedPrompt, 'llama3');
      
      // Vérifier s'il y a eu un timeout
      if (response['timeout'] == true) {
        debugPrint('⚠️ Timeout détecté dans RAG avec contexte');
        
        // Tenter une approche simplifiée sans contexte en cas de timeout
        final fallbackResponse = await _ollamaService.generateResponse(
          query, 
          'llama3',
          temperature: 0.5
        );
        
        if (fallbackResponse['success'] == true) {
          return "⚠️ J'ai dû simplifier ma réponse en raison d'un délai d'attente:\n\n${fallbackResponse['message']}";
        } else {
          debugPrint('❌ Échec aussi avec l\'approche simplifiée: ${fallbackResponse['message']}');
          return response['message']; // Retourner le message de timeout original
        }
      }
      
      if (response['success'] == true) {
        return response['message'];
      } else {
        debugPrint('❌ Erreur dans RAG avec contexte: ${response['message']}');
        return "Désolé, une erreur s'est produite: ${response['message']}\n\nVeuillez vérifier que le serveur Ollama est en cours d'exécution et correctement configuré.";
      }
    } catch (e) {
      debugPrint('❌ Erreur lors de la génération de la réponse RAG: $e');
      // En cas d'erreur, essayer une approche de secours
      try {
        final response = await _ollamaService.generateResponse(query, 'llama3');
        if (response['success'] == true) {
          return response['message'];
        } else {
          debugPrint('❌ Erreur de secours dans RAG: ${response['message']}');
          return "Désolé, une erreur s'est produite: ${response['message']}\n\nVeuillez vérifier que le serveur Ollama est en cours d'exécution.";
        }
      } catch (e2) {
        debugPrint('❌ Erreur critique dans RAG: $e2');
        return "Désolé, une erreur s'est produite lors du traitement de votre demande. Veuillez vérifier que:\n\n1. Le serveur Ollama est bien démarré\n2. Le modèle llama3 est installé avec 'ollama pull llama3'\n3. Les paramètres de connexion sont corrects";
      }
    }
  }

  /// Obtenir des suggestions de questions en fonction de la catégorie
  Future<List<String>> getSuggestedQuestions(String category) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) return [];
    }

    // Obtenir des documents de la catégorie demandée
    final documents = await _knowledgeBase.getDocumentsByCategory(category);
    if (documents.isEmpty) return [];

    // Extraire des questions des métadonnées des documents
    final suggestions = <String>[];
    for (var doc in documents) {
      if (doc.metadata != null && doc.metadata!.containsKey('questions')) {
        final List<dynamic> questions = doc.metadata!['questions'];
        suggestions.addAll(questions.map((q) => q.toString()));
      }
    }

    // Limiter à 5 suggestions maximum
    if (suggestions.length > 5) {
      suggestions.shuffle();
      return suggestions.take(5).toList();
    }
    
    return suggestions;
  }
  
  /// Vérifier si le service est initialisé
  bool get isInitialized => _isInitialized;
} 