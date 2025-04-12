import 'package:flutter/material.dart';
import '../services/llm_service.dart';
import '../utils/llm_config.dart';

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
      
      // Mettre à jour le service LLM
      LlmService.instance.updateApiUrl(apiUrl);
      
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
      
      // Mettre à jour le contrôleur et le service
      _apiUrlController.text = defaultUrl;
      LlmService.instance.updateApiUrl(defaultUrl);
      
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
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _testResult = '';
      _hasError = false;
    });

    try {
      final apiUrl = _apiUrlController.text.trim();
      
      // Mettre à jour temporairement l'URL pour le test
      LlmService.instance.updateApiUrl(apiUrl);
      
      final result = await LlmService.instance.testConnection();
      
      setState(() {
        _testResult = 'Connexion réussie: $result';
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _testResult = 'Échec de la connexion: $e';
        _hasError = true;
      });
    } finally {
      setState(() {
        _isLoading = false;
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
                    if (_testResult.isNotEmpty)
                      Container(
                        margin: const EdgeInsets.only(top: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _hasError
                              ? Colors.red.shade100
                              : Colors.green.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: _hasError ? Colors.red : Colors.green,
                          ),
                        ),
                        child: Text(
                          _testResult,
                          style: TextStyle(
                            color: _hasError ? Colors.red.shade900 : Colors.green.shade900,
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