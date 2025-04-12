import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

/// Service qui gère l'intégration avec Dialogflow pour le chatbot écologique
class EcoDialogflowService {
  static EcoDialogflowService? _instance;
  bool _isInitialized = false;
  
  // Constantes pour l'API Dialogflow
  final String _credentialsPath = 'assets/ecobot-febg-36d4c0342872.json';
  String? _projectId;
  String? _sessionId;
  String? _accessToken;
  
  // URL de base pour l'API Dialogflow
  final String _baseUrl = 'https://dialogflow.googleapis.com/v2';
  
  /// Créer un singleton pour le service Dialogflow
  static EcoDialogflowService get instance {
    if (_instance == null) {
      throw Exception("EcoDialogflowService non initialisé. Appelez EcoDialogflowService.initialize() d'abord.");
    }
    return _instance!;
  }

  /// Initialiser le service Dialogflow
  static Future<void> initialize() async {
    if (_instance == null) {
      final service = EcoDialogflowService._internal();
      await service._init();
      _instance = service;
    }
  }

  /// Constructeur privé
  EcoDialogflowService._internal();
  
  /// État du service
  bool get isInitialized => _isInitialized;
  
  /// Initialiser le service en chargeant les credentials
  Future<void> _init() async {
    try {
      print('Initialisation du service Dialogflow...');
      
      // Générer un ID de session unique pour l'utilisateur
      _sessionId = 'green-minds-${DateTime.now().millisecondsSinceEpoch}';
      
      // Charger et parser le fichier de credentials
      final String credentialsFile = await rootBundle.loadString(_credentialsPath);
      final Map<String, dynamic> credentials = jsonDecode(credentialsFile);
      
      // Extraire les informations nécessaires
      _projectId = credentials['project_id'];
      
      // Pour les tests locaux sur appareil, nous utiliserons l'API REST de Dialogflow
      // qui nécessite un jeton d'accès Google Cloud
      if (_projectId == null) {
        throw Exception('Le fichier de credentials ne contient pas de project_id');
      }
      
      print('Service Dialogflow initialisé avec succès. Project ID: $_projectId');
      _isInitialized = true;
    } catch (e) {
      print('Erreur lors de l\'initialisation du service Dialogflow: $e');
      _isInitialized = false;
      _loadFallbackResponses();
    }
  }
  
  /// Réponses de secours en cas de problème avec Dialogflow
  final List<String> _fallbackResponses = [
    "Pour réduire votre empreinte écologique, essayez de limiter votre consommation de produits à usage unique.",
    "Le recyclage est un excellent moyen de contribuer à la protection de l'environnement.",
    "Économiser l'eau est crucial pour la préservation des ressources naturelles.",
    "Les transports en commun et le covoiturage sont des alternatives écologiques à la voiture individuelle.",
    "Privilégiez les produits locaux et de saison pour réduire l'impact environnemental de votre alimentation.",
    "L'énergie solaire et éolienne sont des sources d'énergie renouvelables qui contribuent à la réduction des émissions de CO2.",
    "Réduire sa consommation de viande a un impact positif significatif sur l'environnement.",
    "Les déchets plastiques sont particulièrement nocifs pour les écosystèmes marins."
  ];
  
  /// Charger des réponses de secours en cas d'échec de Dialogflow
  void _loadFallbackResponses() {
    print('Mode de secours activé avec ${_fallbackResponses.length} réponses prédéfinies');
  }
  
  /// Détection offline par mots-clés (mode de secours)
  String _getFallbackResponse(String question) {
    final q = question.toLowerCase();
    
    // Recherche simple par mots-clés
    if (q.contains('plastique') || q.contains('déchet')) {
      return "Pour réduire vos déchets plastiques, pensez à utiliser des alternatives réutilisables comme les sacs en tissu, les gourdes et les pailles en métal ou bambou.";
    } else if (q.contains('eau')) {
      return "Pour économiser l'eau au quotidien, prenez des douches courtes, installez des économiseurs d'eau sur vos robinets, et récupérez l'eau de pluie pour vos plantes.";
    } else if (q.contains('énergie') || q.contains('électricité')) {
      return "Pour réduire votre consommation d'énergie, éteignez les appareils en veille, utilisez des ampoules LED, et privilégiez les appareils électroménagers économes (classe A+++).";
    } else if (q.contains('transport') || q.contains('voiture')) {
      return "Pour des déplacements plus écologiques, privilégiez la marche ou le vélo pour les courts trajets, les transports en commun ou le covoiturage pour les plus longs.";
    } else if (q.contains('aliment') || q.contains('manger') || q.contains('nourriture')) {
      return "Pour une alimentation plus durable, privilégiez les produits locaux et de saison, réduisez votre consommation de viande, et limitez le gaspillage alimentaire.";
    } else {
      // Réponse générique aléatoire
      return _fallbackResponses[DateTime.now().millisecondsSinceEpoch % _fallbackResponses.length];
    }
  }
  
  /// Envoyer une requête à Dialogflow pour obtenir une réponse
  Future<String> _detectIntent(String text) async {
    try {
      // Créer un fichier temporaire pour stocker les credentials
      final tempDir = await getTemporaryDirectory();
      final credentialsFile = File('${tempDir.path}/dialogflow_credentials.json');
      await credentialsFile.writeAsString(await rootBundle.loadString(_credentialsPath));
      
      // Définir la variable d'environnement pour les credentials
      final env = Platform.environment.map((key, value) => MapEntry(key, value));
      env['GOOGLE_APPLICATION_CREDENTIALS'] = credentialsFile.path;
      
      // Créer l'URL pour la requête Dialogflow
      final url = '$_baseUrl/projects/$_projectId/agent/sessions/$_sessionId:detectIntent';
      
      // Préparer le corps de la requête
      final body = jsonEncode({
        'queryInput': {
          'text': {
            'text': text,
            'languageCode': 'fr-FR',
          },
        },
      });
      
      // Appeler l'API Dialogflow
      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_accessToken',
        },
        body: body,
      );
      
      // Supprimer le fichier temporaire
      await credentialsFile.delete();
      
      // Vérifier le code de statut
      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);
        final fulfillmentText = jsonResponse['queryResult']['fulfillmentText'];
        return fulfillmentText ?? _getFallbackResponse(text);
      } else {
        print('Erreur Dialogflow: ${response.statusCode} - ${response.body}');
        return _getFallbackResponse(text);
      }
    } catch (e) {
      print('Erreur lors de l\'appel à Dialogflow: $e');
      return _getFallbackResponse(text);
    }
  }
  
  /// Obtenir une réponse à une question écologique
  Future<String> getEcoResponse(String question) async {
    // Utiliser le mode de secours si Dialogflow n'est pas initialisé
    if (!_isInitialized) {
      return _getFallbackResponse(question);
    }
    
    try {
      // Essayer d'obtenir une réponse de Dialogflow
      final response = await _detectIntent(question);
      return response;
    } catch (e) {
      print('Erreur lors de la communication avec Dialogflow: $e');
      return _getFallbackResponse(question);
    }
  }
} 