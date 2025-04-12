import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:flutter/foundation.dart';

/// Service qui gère le modèle TensorFlow Lite pour le chatbot écologique
class EcoTFLiteService {
  static EcoTFLiteService? _instance;
  late Interpreter _interpreter;
  late List<String> _vocabulary;
  late List<String> _responses;
  bool _isModelLoaded = false;
  
  // Constantes du modèle
  static const int _maxSequenceLength = 20; // Longueur maximale de la séquence d'entrée
  static const int _vocabSize = 5000;        // Taille du vocabulaire
  static const String _modelPath = 'assets/models/eco_chatbot_model.tflite';
  static const String _vocabPath = 'assets/models/eco_vocabulary.txt';
  static const String _responsesPath = 'assets/models/eco_responses.txt';
  
  /// Créer un singleton pour le service TFLite
  static EcoTFLiteService get instance {
    if (_instance == null) {
      throw Exception("EcoTFLiteService non initialisé. Appelez EcoTFLiteService.initialize() d'abord.");
    }
    return _instance!;
  }

  /// Initialiser le service TFLite
  static Future<void> initialize() async {
    if (_instance == null) {
      final service = EcoTFLiteService._internal();
      await service._loadModel();
      _instance = service;
    }
  }

  /// Constructeur privé
  EcoTFLiteService._internal();
  
  /// État du modèle
  bool get isModelLoaded => _isModelLoaded;
  
  /// Charger le modèle TFLite, le vocabulaire et les réponses
  Future<void> _loadModel() async {
    try {
      // Charger le modèle
      _interpreter = await Interpreter.fromAsset(_modelPath);
      print('Modèle TFLite chargé avec succès');
      
      // Charger le vocabulaire
      final vocabData = await rootBundle.loadString(_vocabPath);
      _vocabulary = vocabData.split('\n');
      print('Vocabulaire chargé avec ${_vocabulary.length} mots');
      
      // Charger les réponses prédéfinies
      final responsesData = await rootBundle.loadString(_responsesPath);
      _responses = responsesData.split('\n---\n');  // Séparateur entre les réponses
      print('Réponses chargées avec ${_responses.length} réponses possibles');
      
      _isModelLoaded = true;
    } catch (e) {
      print('Erreur lors du chargement du modèle TFLite: $e');
      // Charger un petit ensemble de réponses de secours
      _loadFallbackResponses();
    }
  }
  
  /// Charger des réponses de secours en cas d'échec du modèle
  void _loadFallbackResponses() {
    _isModelLoaded = false;
    _responses = [
      "Pour réduire votre empreinte écologique, essayez de limiter votre consommation de produits à usage unique.",
      "Le recyclage est un excellent moyen de contribuer à la protection de l'environnement.",
      "Économiser l'eau est crucial pour la préservation des ressources naturelles.",
      "Les transports en commun et le covoiturage sont des alternatives écologiques à la voiture individuelle.",
      "Privilégiez les produits locaux et de saison pour réduire l'impact environnemental de votre alimentation.",
      "L'énergie solaire et éolienne sont des sources d'énergie renouvelables qui contribuent à la réduction des émissions de CO2.",
      "Réduire sa consommation de viande a un impact positif significatif sur l'environnement.",
      "Les déchets plastiques sont particulièrement nocifs pour les écosystèmes marins."
    ];
    print('Réponses de secours chargées avec ${_responses.length} réponses');
  }
  
  /// Tokenizer une question utilisateur
  List<int> _tokenize(String text) {
    // Version simplifiée du tokenizer
    text = text.toLowerCase();
    final words = text.split(' ');
    
    // Convertir les mots en indices de vocabulaire
    final List<int> tokens = [];
    for (final word in words) {
      final index = _vocabulary.indexOf(word);
      if (index != -1) {
        tokens.add(index);
      } else {
        // OOV (Out of Vocabulary)
        tokens.add(0); // Index 0 réservé pour les mots inconnus
      }
    }
    
    // Padding/Truncation pour atteindre _maxSequenceLength
    if (tokens.length > _maxSequenceLength) {
      return tokens.sublist(0, _maxSequenceLength);
    } else {
      while (tokens.length < _maxSequenceLength) {
        tokens.add(0); // Padding
      }
      return tokens;
    }
  }
  
  /// Obtenir une réponse à une question écologique
  Future<String> getEcoResponse(String question) async {
    if (!_isModelLoaded) {
      // Mode de secours - sélection aléatoire d'une réponse prédéfinie
      return _getFallbackResponse(question);
    }
    
    try {
      // Tokenize la question
      final input = _tokenize(question);
      
      // Préparer le tenseur d'entrée (1 exemple, séquence de longueur _maxSequenceLength)
      final inputShape = [1, _maxSequenceLength];
      final outputShape = [1, _responses.length];  // Output pour chaque réponse possible
      
      // Allouer des tenseurs
      final inputTensor = List.filled(inputShape[0] * inputShape[1], 0)
          .reshape(inputShape);
      final outputTensor = List.filled(outputShape[0] * outputShape[1], 0.0)
          .reshape(outputShape);
      
      // Remplir le tenseur d'entrée
      for (var i = 0; i < input.length; i++) {
        inputTensor[0][i] = input[i];
      }
      
      // Exécuter l'inférence
      _interpreter.run(inputTensor, outputTensor);
      
      // Trouver la réponse avec le score le plus élevé
      final List<double> scores = List.from(outputTensor[0]);
      final maxIndex = scores.indexOf(scores.reduce(max));
      
      return _responses[maxIndex];
    } catch (e) {
      print('Erreur lors de l\'inférence TFLite: $e');
      return _getFallbackResponse(question);
    }
  }
  
  /// Obtenir une réponse de secours basée sur des mots-clés
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
      // Réponse générique
      return _responses[Random().nextInt(_responses.length)];
    }
  }
  
  /// Libérer les ressources
  void dispose() {
    if (_isModelLoaded) {
      _interpreter.close();
    }
  }
} 