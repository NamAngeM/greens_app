import 'package:flutter/material.dart';
import 'package:greens_app/services/llm_service.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/llm_config.dart';
import 'package:url_launcher/url_launcher.dart';

class LlmSettingsView extends StatefulWidget {
  const LlmSettingsView({Key? key}) : super(key: key);

  @override
  State<LlmSettingsView> createState() => _LlmSettingsViewState();
}

class _LlmSettingsViewState extends State<LlmSettingsView> {
  final TextEditingController _apiUrlController = TextEditingController();
  bool _isTesting = false;
  String? _testResult;
  bool _isTestSuccessful = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }

  Future<void> _loadSettings() async {
    final apiUrl = await LlmConfig.getApiUrl();
    setState(() {
      _apiUrlController.text = apiUrl;
    });
  }

  Future<void> _saveSettings() async {
    final url = _apiUrlController.text.trim();
    if (url.isEmpty || !LlmConfig.isValidApiUrl(url)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('URL invalide. Veuillez entrer une URL valide.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Sauvegarder l'URL
    await LlmConfig.saveApiUrl(url);
    
    // Mettre à jour le service LLM
    LlmService.instance.updateApiUrl(url);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres sauvegardés avec succès'),
        backgroundColor: Colors.green,
      ),
    );
  }

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
      
      // Sauvegarder temporairement l'URL pour le test
      await LlmConfig.saveApiUrl(correctedUrl);
      
      // Test de connexion
      await LlmService.initialize();
      
      print('Appel de la méthode testConnection()');
      // Tester la connexion au modèle
      final response = await LlmService.testConnectionWithUrl(correctedUrl);
      print('Réponse reçue du test: $response');
      
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres du modèle Gemma'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône et description
            Center(
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.auto_awesome,
                      size: 40,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Configuration de Gemma via Ollama',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Informations sur Ollama
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'À propos d\'Ollama',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ollama est un outil qui permet d\'exécuter des modèles de langage localement sur votre machine. Gemma de Google doit être installé sur Ollama pour fonctionner avec ce chatbot.',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Par défaut, Ollama écoute sur: http://localhost:11434',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () async {
                      final url = Uri.parse('https://ollama.ai/');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(url);
                      }
                    },
                    icon: const Icon(Icons.open_in_new),
                    label: const Text('Visiter le site d\'Ollama'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Configuration URL
            const Text(
              'URL de l\'API Ollama',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _apiUrlController,
              decoration: InputDecoration(
                hintText: 'http://localhost:11434',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Assurez-vous qu\'Ollama est en cours d\'exécution et que le modèle "gemma" est installé.',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            
            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveSettings,
                    icon: const Icon(Icons.save),
                    label: const Text('Sauvegarder'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTesting ? null : _testConnection,
                    icon: _isTesting 
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.network_check),
                    label: Text(_isTesting ? 'Test en cours...' : 'Tester la connexion'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            // Résultat du test
            if (_testResult != null) ...[
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isTestSuccessful ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _isTestSuccessful ? Colors.green : Colors.red,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _isTestSuccessful ? Icons.check_circle : Icons.error,
                          color: _isTestSuccessful ? Colors.green : Colors.red,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isTestSuccessful ? 'Succès' : 'Échec',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isTestSuccessful ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_testResult!),
                    if (!_isTestSuccessful) ...[
                      const SizedBox(height: 16),
                      const Text(
                        'Conseils de dépannage:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      const Text('• Vérifiez qu\'Ollama est bien installé et démarré'),
                      const Text('• Vérifiez que l\'URL est correcte (généralement http://localhost:11434)'),
                      const Text('• Assurez-vous que le modèle "gemma" est installé avec la commande: ollama pull gemma'),
                    ],
                  ],
                ),
              ),
            ],
            
            const SizedBox(height: 32),
            
            // Guide d'installation de Gemma
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.help_outline, color: Colors.amber),
                      SizedBox(width: 8),
                      Text(
                        'Comment installer Gemma',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.amber,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '1. Installez Ollama depuis ollama.ai',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '2. Ouvrez un terminal et exécutez:',
                    style: TextStyle(fontSize: 14),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ollama pull gemma',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(Icons.content_copy, size: 16),
                      ],
                    ),
                  ),
                  const Text(
                    '3. Après l\'installation, démarrez le serveur avec:',
                    style: TextStyle(fontSize: 14),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ollama serve',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Icon(Icons.content_copy, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
} 