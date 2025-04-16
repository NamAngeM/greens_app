import 'package:flutter/material.dart';
import '../utils/llm_config.dart';
import '../services/llm_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _urlController = TextEditingController();
  bool _isConnectionTested = false;
  bool _isConnected = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSavedUrl();
  }

  Future<void> _loadSavedUrl() async {
    final url = await LlmConfig.getApiUrl();
    setState(() {
      _urlController.text = url;
    });
  }

  Future<void> _testConnection() async {
    setState(() {
      _isLoading = true;
      _isConnectionTested = false;
    });

    final llmService = LlmService();
    final isConnected = await llmService.testConnection();

    setState(() {
      _isLoading = false;
      _isConnectionTested = true;
      _isConnected = isConnected;
    });
  }

  Future<void> _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      await LlmConfig.saveApiUrl(_urlController.text);
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('URL de l\'API sauvegardée')),
      );
      
      await _testConnection();
    }
  }

  Future<void> _resetToDefault() async {
    await LlmConfig.resetApiUrl();
    final defaultUrl = await LlmConfig.getApiUrl();
    
    setState(() {
      _urlController.text = defaultUrl;
      _isConnectionTested = false;
    });
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('URL de l\'API réinitialisée')),
    );
  }

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Configuration de l\'API Ollama',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _urlController,
                decoration: const InputDecoration(
                  labelText: 'URL de l\'API',
                  hintText: 'http://localhost:11434',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une URL';
                  }
                  if (!LlmConfig.isValidApiUrl(value)) {
                    return 'URL invalide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Sauvegarder'),
              ),
              const SizedBox(height: 8),
              OutlinedButton(
                onPressed: _resetToDefault,
                child: const Text('Réinitialiser'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isLoading ? null : _testConnection,
                child: _isLoading
                    ? const CircularProgressIndicator()
                    : const Text('Tester la connexion'),
              ),
              if (_isConnectionTested)
                Container(
                  margin: const EdgeInsets.only(top: 16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _isConnected ? Colors.green[100] : Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    _isConnected
                        ? 'Connecté à Ollama avec succès !'
                        : 'Impossible de se connecter à Ollama. Vérifiez l\'URL et assurez-vous que le serveur est en cours d\'exécution.',
                    style: TextStyle(
                      color: _isConnected ? Colors.green[900] : Colors.red[900],
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