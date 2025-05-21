import 'dart:convert';
import 'package:http/http.dart' as http;

/// Service pour interagir avec Ollama en local
class OllamaService {
  static final OllamaService _instance = OllamaService._internal();
  factory OllamaService() => _instance;
  static OllamaService get instance => _instance;

  bool _isInitialized = false;
  String _model = 'llama3';
  final String _baseUrl = 'http://localhost:11434';

  OllamaService._internal();

  /// Initialise le service Ollama
  Future<bool> initialize({String model = 'llama3'}) async {
    try {
      _model = model;
      // Test de connexion à Ollama
      final response = await http.get(Uri.parse('$_baseUrl/api/tags'));
      _isInitialized = response.statusCode == 200;
      
      if (_isInitialized) {
        print('OllamaService initialisé avec succès');
        print('  - Modèle: $_model');
      } else {
        print('OllamaService: échec de la connexion à Ollama');
      }
      
      return _isInitialized;
    } catch (e) {
      print('Exception lors de l\'initialisation de OllamaService: $e');
      _isInitialized = false;
      return false;
    }
  }

  /// Teste la connexion à Ollama
  Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl/api/tags'));
      return response.statusCode == 200;
    } catch (e) {
      print('Erreur lors du test de connexion à Ollama: $e');
      return false;
    }
  }

  /// Génère une réponse à partir d'un message
  Future<String> generateResponse(String message) async {
    if (!_isInitialized) {
      return "Le service Ollama n'est pas initialisé. Veuillez vérifier que Ollama est en cours d'exécution.";
    }

    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _model,
          'prompt': message,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? "Désolé, je n'ai pas pu générer une réponse.";
      } else {
        print('Erreur API Ollama: ${response.statusCode} - ${response.body}');
        return "Une erreur s'est produite lors de la communication avec Ollama (${response.statusCode}).";
      }
    } catch (e) {
      print('Exception lors de la génération de réponse Ollama: $e');
      return "Une erreur s'est produite lors de la communication avec Ollama.";
    }
  }

  /// Génère une réponse avec un contexte de conversation
  Future<String> generateResponseWithContext(String message, List<Map<String, String>> context) async {
    if (!_isInitialized) {
      return "Le service Ollama n'est pas initialisé. Veuillez vérifier que Ollama est en cours d'exécution.";
    }

    try {
      // Construire le prompt avec le contexte
      final String contextPrompt = context.map((msg) {
        final role = msg['role'] == 'user' ? 'Human' : 'Assistant';
        return '$role: ${msg['content']}';
      }).join('\n');

      final String fullPrompt = '''
$contextPrompt
Human: $message
Assistant:''';

      final response = await http.post(
        Uri.parse('$_baseUrl/api/generate'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': _model,
          'prompt': fullPrompt,
          'stream': false,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? "Désolé, je n'ai pas pu générer une réponse.";
      } else {
        print('Erreur API Ollama: ${response.statusCode} - ${response.body}');
        return "Une erreur s'est produite lors de la communication avec Ollama (${response.statusCode}).";
      }
    } catch (e) {
      print('Exception lors de la génération de réponse Ollama: $e');
      return "Une erreur s'est produite lors de la communication avec Ollama.";
    }
  }

  bool get isInitialized => _isInitialized;
  String get model => _model;
} 