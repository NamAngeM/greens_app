import 'package:flutter/material.dart';
import 'package:greens_app/services/llm_service.dart';
import 'package:greens_app/services/ollama_service.dart';
import 'package:greens_app/utils/llm_config.dart';

class LlmSettingsView extends StatefulWidget {
  const LlmSettingsView({Key? key}) : super(key: key);

  @override
  State<LlmSettingsView> createState() => _LlmSettingsViewState();
}

class _LlmSettingsViewState extends State<LlmSettingsView> {
  final _formKey = GlobalKey<FormState>();
  final _apiUrlController = TextEditingController();
  bool _isLoading = false;
  String _testResult = '';
  bool _hasError = false;
  bool _isTesting = false;
  bool _isTestSuccessful = false;
  bool _useApiProxy = true;
  final _ollamaService = OllamaService.instance;

  @override
  void initState() {
    super.initState();
    _loadApiUrl();
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  // Charger l'URL de l'API existante
  Future<void> _loadApiUrl() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final apiUrl = await LlmConfig.getApiUrl();
      _apiUrlController.text = apiUrl;
      _useApiProxy = _ollamaService.useApiProxy;
    } catch (e) {
      _showSnackBar('Erreur lors du chargement de l\'URL: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Sauvegarder l'URL de l'API
  Future<void> _saveApiUrl() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      final apiUrl = _apiUrlController.text.trim();
      await LlmConfig.saveApiUrl(apiUrl);
      
      // Mettre à jour les services
      _ollamaService.updateApiUrl(apiUrl);
      _ollamaService.useApiProxy = _useApiProxy;
      
      _showSnackBar('URL API sauvegardée avec succès');
    } catch (e) {
      _showSnackBar('Erreur lors de la sauvegarde: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Réinitialiser l'URL de l'API
  Future<void> _resetApiUrl() async {
    setState(() {
      _isLoading = true;
      _testResult = '';
    });

    try {
      await LlmConfig.resetApiUrl();
      final defaultUrl = await LlmConfig.getApiUrl();
      
      // Mettre à jour le contrôleur et les services
      _apiUrlController.text = defaultUrl;
      _ollamaService.updateApiUrl(defaultUrl);
      _useApiProxy = true;
      _ollamaService.useApiProxy = true;
      
      _showSnackBar('URL API réinitialisée avec succès');
    } catch (e) {
      _showSnackBar('Erreur lors de la réinitialisation: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Tester la connexion
  Future<void> _testConnection() async {
    setState(() {
      _isTesting = true;
      _testResult = null;
    });

    final url = _apiUrlController.text.trim();
    print('URL saisie pour le test: "$url"');
    
    if (url.isEmpty) {
      setState(() {
        _isTesting = false;
        _testResult = "URL vide. Veuillez entrer une URL valide.";
        _isTestSuccessful = false;
      });
      return;
    }
    
    // Correction simple pour les erreurs courantes dans l'URL
    String correctedUrl = url;
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      correctedUrl = 'http://$url';
      print('URL corrigée automatiquement: $correctedUrl');
    }
    
    // S'assurer que l'URL n'a pas de chemin spécifique pour le test de connexion
    if (correctedUrl.contains('/api/')) {
      correctedUrl = correctedUrl.substring(0, correctedUrl.indexOf('/api/'));
      print('URL simplifiée pour le test: $correctedUrl');
    }
    
    if (correctedUrl != url) {
      // Mettre à jour le champ de texte avec l'URL corrigée
      _apiUrlController.text = correctedUrl;
      print('Champ de texte mis à jour avec l\'URL corrigée');
    }

    try {
      print('Début du test de connexion avec: $correctedUrl');
      
      // Utiliser la méthode de test
      _ollamaService.updateApiUrl(correctedUrl);
      final llmService = LlmService();
      final response = await llmService.testConnection();
      print('Réponse reçue du test: $response');
      
      if (response) {
        // Si la connexion est réussie, sauvegarder l'URL
        await LlmConfig.saveApiUrl(correctedUrl);
      }
      
      setState(() {
        _isTesting = false;
        _testResult = response 
            ? "Connexion réussie ! Le serveur Ollama est accessible."
            : "Impossible de se connecter à Ollama. Vérifiez que le serveur est en cours d'exécution.";
        _isTestSuccessful = response;
      });
    } catch (e) {
      print('Erreur lors du test de connexion: $e');
      setState(() {
        _isTesting = false;
        _testResult = "Erreur de connexion : $e";
        _isTestSuccessful = false;
      });
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres LLM'),
      ),
      body: _isLoading && _apiUrlController.text.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Configuration du service LLM',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Spécifiez l\'URL de l\'API du service LLM. Assurez-vous que le service est accessible et correctement configuré.',
                    ),
                    const SizedBox(height: 16),
                    
                    // Mode de connexion
                    Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Mode de connexion',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'En cas de problèmes de timeout, vous pouvez essayer de basculer en mode direct.',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                            const SizedBox(height: 12),
                            RadioListTile<bool>(
                              title: const Text('Via API Node.js (recommandé)'),
                              subtitle: const Text('Plus stable mais peut causer des timeouts sur les grands modèles'),
                              value: true,
                              groupValue: _useApiProxy,
                              onChanged: (value) {
                                setState(() {
                                  _useApiProxy = value!;
                                });
                              },
                            ),
                            RadioListTile<bool>(
                              title: const Text('Connexion directe à Ollama'),
                              subtitle: const Text('Plus rapide mais moins de fonctionnalités'),
                              value: false,
                              groupValue: _useApiProxy,
                              onChanged: (value) {
                                setState(() {
                                  _useApiProxy = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                    
                    TextFormField(
                      controller: _apiUrlController,
                      decoration: const InputDecoration(
                        labelText: 'URL API',
                        hintText: 'http://exemple.com/api/v1/generate',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'L\'URL de l\'API est requise';
                        }
                        if (!LlmConfig.isValidApiUrl(value)) {
                          return 'Format d\'URL invalide';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _saveApiUrl,
                            child: const Text('Sauvegarder'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : _resetApiUrl,
                            child: const Text('Réinitialiser'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _isLoading ? null : _testConnection,
                      icon: const Icon(Icons.network_check),
                      label: const Text('Tester la connexion'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).primaryColor,
                        foregroundColor: Colors.white,
                      ),
                    ),
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    if (_testResult != null)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _isTestSuccessful
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _isTestSuccessful ? Colors.green : Colors.red,
                          ),
                        ),
                        child: Text(
                          _testResult,
                          style: TextStyle(
                            color: _isTestSuccessful ? Colors.green.shade900 : Colors.red.shade900,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
    );
  }
} 