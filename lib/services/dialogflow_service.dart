import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:googleapis/dialogflow/v2.dart' as df;
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'package:greens_app/services/webhook_functions.dart';

/// Service qui gère l'intégration avec Dialogflow pour le chatbot écologique
class DialogflowService {
  static DialogflowService? _instance;
  bool _isInitialized = false;
  late String _sessionId;
  late String _projectId;
  late String _sessionPath;
  df.DialogflowApi? _dialogflowApi;
  
  /// Constructeur privé
  DialogflowService._();
  
  /// Singleton pour le service Dialogflow
  static DialogflowService get instance {
    _instance ??= DialogflowService._();
    return _instance!;
  }

  /// Initialiser le service Dialogflow
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // Générer un ID de session unique pour l'utilisateur
      _sessionId = const Uuid().v4();
      
      // Charger les credentials
      final String credentialsJson = await rootBundle.loadString('assets/dialogflow_credentials.json');
      final Map<String, dynamic> credentialsMap = json.decode(credentialsJson);
      
      // Récupérer le project ID
      _projectId = credentialsMap['project_id'];

      // Créer les identifiants de service
      final credentials = ServiceAccountCredentials.fromJson(credentialsMap);
      
      // Créer un client HTTP authentifié
      final client = await clientViaServiceAccount(
        credentials, 
        [df.DialogflowApi.cloudPlatformScope]
      );
      
      // Initialiser l'API Dialogflow
      _dialogflowApi = df.DialogflowApi(client);
      
      // Chemin de la session
      _sessionPath = 'projects/$_projectId/agent/sessions/$_sessionId';
      
      _isInitialized = true;
      debugPrint('Service Dialogflow initialisé avec succès (Project ID: $_projectId)');
    } catch (e) {
      debugPrint('Erreur lors de l\'initialisation de Dialogflow: $e');
      _isInitialized = false;
    }
  }

  /// Envoyer une requête à Dialogflow et obtenir une réponse
  Future<String> detectIntent(String text) async {
    if (!_isInitialized) {
      await initialize();
      if (!_isInitialized) {
        return "Désolé, je ne peux pas vous répondre pour le moment. Le service n'est pas disponible.";
      }
    }

    try {
      // Créer la requête
      final request = df.GoogleCloudDialogflowV2DetectIntentRequest(
        queryInput: df.GoogleCloudDialogflowV2QueryInput(
          text: df.GoogleCloudDialogflowV2TextInput(
            text: text,
            languageCode: 'fr-FR',
          ),
        ),
      );
      
      // Envoyer la requête
      final response = await _dialogflowApi!.projects.agent.sessions.detectIntent(
        request,
        _sessionPath,
      );
      
      // Extraire la réponse
      final fulfillmentText = response.queryResult?.fulfillmentText ?? '';
      
      if (fulfillmentText.isNotEmpty) {
        return fulfillmentText;
      } else {
        return "Désolé, je n'ai pas compris votre demande. Pourriez-vous reformuler ?";
      }
    } catch (e) {
      debugPrint('Erreur lors de l\'appel à Dialogflow: $e');
      return "Une erreur s'est produite lors du traitement de votre demande.";
    }
  }
  
  /// Vérifier si le service est initialisé
  bool get isInitialized => _isInitialized;
  
  /// Obtenir l'ID de session courant
  String get sessionId => _sessionId;
} 