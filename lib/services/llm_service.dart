import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:greens_app/utils/llm_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service pour interagir avec le modèle de langage Gemma via Ollama
class LlmService {
  static LlmService? _instance;
  String _ollamaApiUrl;
  
  /// Créer un singleton pour le service LLM
  static LlmService get instance {
    if (_instance == null) {
      throw Exception("LlmService non initialisé. Appelez LlmService.initialize() d'abord.");
    }
    return _instance!;
  }

  /// Initialiser le service LLM
  static Future<void> initialize() async {
    if (_instance == null) {
      final apiUrl = await LlmConfig.getApiUrl();
      _instance = LlmService._internal(apiUrl);
    }
  }

  /// Constructeur privé
  LlmService._internal(this._ollamaApiUrl);

  /// Mettre à jour l'URL de l'API
  void updateApiUrl(String url) {
    _ollamaApiUrl = url;
  }

  /// Tester la connexion avec Ollama
  Future<String> testConnection() async {
    try {
      // Commencer par vérifier si l'URL est valide
      if (!_ollamaApiUrl.startsWith('http://') && !_ollamaApiUrl.startsWith('https://')) {
        throw Exception('URL invalide : l\'URL doit commencer par http:// ou https://');
      }
      
      print('Tentative de connexion à Ollama sur : $_ollamaApiUrl');
      
      // Extraire le domaine et le port pour un test de connexion basique
      final uri = Uri.parse(_ollamaApiUrl);
      final host = uri.host;
      final port = uri.port;
      
      // Tester d'abord si le service est joignable
      try {
        final socket = await Socket.connect(host, port, timeout: Duration(seconds: 5));
        socket.destroy();
        print('Connexion socket réussie à $host:$port');
      } catch (e) {
        print('Erreur de connexion socket : $e');
        throw Exception('Impossible de se connecter au serveur Ollama sur $host:$port. Vérifiez qu\'Ollama est bien lancé.');
      }
      
      // Ensuite, faire une requête HTTP simple
      final response = await http.post(
        Uri.parse(_ollamaApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'gemma',
          'prompt': 'Salut',
          'stream': false
        }),
      ).timeout(Duration(seconds: 10));

      if (response.statusCode == 200) {
        print('Réponse reçue avec succès : ${response.body.substring(0, min(50, response.body.length))}...');
        final responseData = jsonDecode(response.body);
        return "Service actif : ${responseData['response'] ?? 'Connexion établie'}";
      } else {
        print('Erreur HTTP : ${response.statusCode}');
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur détaillée de connexion à Ollama: $e');
      throw Exception('Impossible de se connecter à Ollama: $e');
    }
  }

  /// Vérifier si une question est liée à l'écologie
  Future<bool> isEcoRelated(String question) async {
    try {
      final response = await http.post(
        Uri.parse(_ollamaApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'gemma',
          'prompt': '''
          Tu es un assistant en écologie qui doit déterminer si la question suivante est liée à l'écologie, l'environnement, le développement durable, ou des produits écologiques.
          
          Question: "$question"
          
          Réponds uniquement par "OUI" si la question est liée à l'écologie, ou "NON" si elle ne l'est pas.
          ''',
          'stream': false
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final answer = responseData['response']?.toLowerCase() ?? "";
        return answer.contains('oui');
      } else {
        return true; // En cas d'erreur, on accepte la question par défaut
      }
    } catch (e) {
      print('Erreur lors de la vérification du sujet: $e');
      return true; // En cas d'erreur, on accepte la question par défaut
    }
  }

  /// Poser une question sur l'écologie
  Future<String> askEcoQuestion(String question) async {
    try {
      final response = await http.post(
        Uri.parse(_ollamaApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': 'gemma',
          'prompt': '''
          Tu es GreenBot, un assistant spécialisé en écologie et développement durable. Ta mission est d'aider les utilisateurs à adopter un mode de vie plus écologique et à comprendre les enjeux environnementaux.
          
          Voici la question de l'utilisateur: "$question"
          
          Réponds de manière concise, claire et utile. Fournis des informations scientifiquement exactes et des conseils pratiques quand c'est possible.
          ''',
          'stream': false
        }),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        return responseData['response'] ?? "Je n'ai pas pu générer de réponse. Veuillez réessayer.";
      } else {
        throw Exception('Erreur ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('Erreur lors de la génération de réponse: $e');
      return "Désolé, une erreur s'est produite lors de la génération de la réponse. Veuillez réessayer plus tard.";
    }
  }

  // Liste de mots-clés liés à l'écologie pour filtrer les questions pertinentes
  final List<String> _ecoKeywords = [
    'écologie', 'environnement', 'biodiversité', 'climat', 'changement climatique', 
    'développement durable', 'énergie', 'renewable', 'vert', 'green', 'pollut',
    'déchet', 'tri', 'recyclage', 'compost', 'zéro déchet', 'carbone', 'empreinte', 
    'conservation', 'éco-responsable', 'écosystème', 'habitat', 'faune', 'flore',
    'extinction', 'protection', 'sustainable', 'organic', 'bio', 'local', 'circuit court',
    'biodiversity', 'emissions', 'greenhouse', 'serre', 'planète', 'terre', 'earth',
    'nature', 'eau', 'water', 'air', 'clean', 'propre', 'forest', 'forêt', 'arbre',
    'tree', 'espèce', 'species', 'renewable', 'renouvelable', 'fossil', 'fossile'
  ];
  
  // Liste de sujets bloqués qui ne seront pas traités
  final List<String> _blockedTopics = [
    'politique', 'religion', 'sexe', 'violence', 'drogue', 'money', 'argent', 'war',
    'guerre', 'weapon', 'arme', 'discrimination', 'haine', 'hate', 'illegal', 'illégal'
  ];
  
  // Génération de texte avec le LLM
  Future<String> generateText(String prompt, {int maxTokens = 100}) async {
    try {
      if (!LlmConfig.isValidApiUrl(_ollamaApiUrl)) {
        throw Exception('URL API invalide: $_ollamaApiUrl');
      }
      
      final response = await http.post(
        Uri.parse(_ollamaApiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'prompt': prompt,
          'max_tokens': maxTokens,
        }),
      ).timeout(const Duration(seconds: 30));
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['generated_text'] ?? 'Aucun texte généré';
      } else {
        final errorMessage = response.statusCode == 429 
          ? 'Limite de requêtes atteinte. Veuillez réessayer plus tard.'
          : 'Erreur HTTP: ${response.statusCode}';
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is http.ClientException) {
        throw Exception('Impossible de se connecter au serveur LLM.');
      }
      rethrow;
    }
  }
  
  // Méthode pour obtenir une réponse du modèle LLM local
  Future<String> getResponse(String message) async {
    // Simuler un délai de réponse
    await Future.delayed(const Duration(seconds: 1));
    
    message = message.toLowerCase();
    
    if (message.contains('plastique') || message.contains('déchets plastiques')) {
      return "Pour réduire votre consommation de plastique, vous pouvez :\n"
          "- Utiliser des sacs réutilisables\n"
          "- Opter pour des bouteilles et contenants en verre\n"
          "- Acheter en vrac pour éviter les emballages\n"
          "- Utiliser des pailles réutilisables en métal ou bambou\n"
          "- Éviter les produits à usage unique";
    } 
    else if (message.contains('eau') || message.contains('économiser l\'eau')) {
      return "Pour économiser l'eau au quotidien :\n"
          "- Prenez des douches courtes plutôt que des bains\n"
          "- Installez des économiseurs d'eau sur vos robinets\n"
          "- Récupérez l'eau de pluie pour arroser vos plantes\n"
          "- Réparez rapidement les fuites\n"
          "- Utilisez le lave-vaisselle et le lave-linge à pleine charge";
    }
    else if (message.contains('énergie') || message.contains('électricité')) {
      return "Pour réduire votre consommation d'énergie :\n"
          "- Éteignez les appareils en veille\n"
          "- Utilisez des ampoules LED\n"
          "- Isolez correctement votre habitation\n"
          "- Privilégiez les appareils économes en énergie (classe A+++)\n"
          "- Baissez légèrement le chauffage et portez un pull en hiver";
    }
    else if (message.contains('alimentation') || message.contains('manger') || message.contains('nourriture')) {
      return "Pour une alimentation plus écologique :\n"
          "- Privilégiez les produits locaux et de saison\n"
          "- Réduisez votre consommation de viande\n"
          "- Évitez le gaspillage alimentaire\n"
          "- Achetez en vrac et bio quand c'est possible\n"
          "- Compostez vos déchets organiques";
    }
    else if (message.contains('transport') || message.contains('voiture') || message.contains('déplacements')) {
      return "Pour des transports plus écologiques :\n"
          "- Privilégiez la marche ou le vélo pour les courts trajets\n"
          "- Utilisez les transports en commun\n"
          "- Pratiquez le covoiturage\n"
          "- Si possible, optez pour une voiture électrique ou hybride\n"
          "- Limitez vos voyages en avion";
    }
    else if (message.contains('jardinage') || message.contains('jardin') || message.contains('plantes')) {
      return "Pour un jardinage écologique :\n"
          "- N'utilisez pas de pesticides chimiques\n"
          "- Faites votre propre compost\n"
          "- Plantez des espèces locales adaptées au climat\n"
          "- Économisez l'eau en paillant vos plantations\n"
          "- Créez un potager pour produire vos légumes";
    }
    else {
      return "Je suis votre assistant écologique GreenMinds. Je peux vous aider sur des sujets comme la réduction des déchets plastiques, les économies d'eau et d'énergie, l'alimentation durable, les transports écologiques et le jardinage naturel. Comment puis-je vous aider aujourd'hui?";
    }
  }
  
  // Instructions pour configurer et lancer le modèle Gemma LLaMA localement
  static String getSetupInstructions() {
    return '''
Prérequis:
- Python 3.10+
- Git
- CMake
- Compilateur C++ (gcc/clang)
- GPU compatible CUDA (recommandé)
- 8+ Go de RAM
- 5+ Go d'espace disque

Installation:
1. Cloner llama.cpp:
   git clone https://github.com/ggerganov/llama.cpp
   cd llama.cpp

2. Compiler le projet:
   cmake -B build
   cmake --build build --config Release

3. Télécharger le modèle Gemma:
   a. Créer un compte sur Hugging Face
   b. Accepter les conditions d'utilisation du modèle Gemma
   c. Télécharger 'gemma-2b-it-q4_0.gguf' depuis https://huggingface.co/google/gemma-2b-it

4. Lancer le serveur:
   ./build/bin/server -m [chemin/vers/gemma-2b-it-q4_0.gguf] --host 127.0.0.1 --port 8000 -c 2048

5. Le serveur doit être accessible à l'adresse: http://localhost:8000/api/generate

Notes:
- Utilisez la version quantifiée 'q4_0.gguf' pour des performances optimales sur un matériel limité
- Ajustez '-c 2048' pour changer la taille du contexte si nécessaire
- Vérifiez que le port 8000 est disponible ou modifiez-le selon vos besoins
''';
  }

  // Vérifier si une question est liée à l'écologie
  Future<bool> isEcologyRelated(String question) async {
    try {
      final prompt = '''
      Détermine si la question suivante est liée à l'écologie, au développement durable, 
      ou aux produits écologiques. Réponds uniquement par "oui" ou "non".
      
      Question: $question
      ''';

      final response = await generateText(prompt, maxTokens: 10);
      return response.toLowerCase().contains('oui');
    } catch (e) {
      // En cas d'erreur, on suppose que la question est liée à l'écologie
      return true;
    }
  }
} 