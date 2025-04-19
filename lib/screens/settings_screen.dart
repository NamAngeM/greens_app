import 'package:flutter/material.dart';
import '../utils/llm_config.dart';
import '../services/llm_service.dart';
import '../services/ollama_service.dart';

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
  bool _useApiProxy = true;
  final _ollamaService = OllamaService.instance;

  @override
  void initState() {
    super.initState();
    _loadSavedSettings();
  }

  Future<void> _loadSavedSettings() async {
    final url = await LlmConfig.getApiUrl();
    setState(() {
      _urlController.text = url;
      _useApiProxy = _ollamaService.useApiProxy;
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
      _ollamaService.useApiProxy = _useApiProxy;
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paramètres sauvegardés')),
      );
      
      await _testConnection();
    }
  }

  Future<void> _resetToDefault() async {
    await LlmConfig.resetApiUrl();
    final defaultUrl = await LlmConfig.getApiUrl();
    
    setState(() {
      _urlController.text = defaultUrl;
      _useApiProxy = true;
      _isConnectionTested = false;
    });
    
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Paramètres réinitialisés')),
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
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: _isLoading ? null : () {
                  OllamaService.showDiagnosticDialog(context);
                },
                icon: const Icon(Icons.bug_report),
                label: const Text('Diagnostic approfondi'),
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
              
              const SizedBox(height: 24),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        '🕒 À propos des timeouts',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Si vous rencontrez des problèmes de timeout lors de la génération de réponses, vous pouvez essayer de:\n'
                        '• Basculer en mode de connexion directe\n'
                        '• Poser des questions plus courtes\n'
                        '• Utiliser un modèle plus petit\n'
                        '• Vérifier les ressources de votre machine',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
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