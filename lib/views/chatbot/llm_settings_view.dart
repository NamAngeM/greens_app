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
    if (LlmService.instance != null) {
      LlmService.instance.updateApiUrl(url);
    }

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
    
    // S'assurer que l'URL se termine par /api/generate
    if (!correctedUrl.endsWith('/api/generate')) {
      // Supprimer le / final si présent
      if (correctedUrl.endsWith('/')) {
        correctedUrl = correctedUrl.substring(0, correctedUrl.length - 1);
      }
      correctedUrl = '$correctedUrl/api/generate';
      print('URL complétée avec le chemin API: $correctedUrl');
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
      
      // Initialiser ou mettre à jour le service LLM
      if (LlmService.instance == null) {
        print('Initialisation du service LLM');
        await LlmService.initialize();
      } else {
        print('Mise à jour de l\'URL du service LLM');
        LlmService.instance.updateApiUrl(correctedUrl);
      }
      
      print('Appel de la méthode testConnection()');
      // Tester la connexion au modèle
      final response = await LlmService.instance.testConnection();
      print('Réponse reçue du test: $response');
      
      setState(() {
        _isTesting = false;
        _testResult = "Connexion réussie ! Le modèle Gemma est fonctionnel via Ollama.";
        _isTestSuccessful = true;
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
                hintText: 'http://localhost:11434/api/generate',
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

            // Boutons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isTesting ? null : _testConnection,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isTesting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 3,
                            ),
                          )
                        : const Text('Tester la connexion'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Sauvegarder'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Résultat du test
            if (_testResult != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _isTestSuccessful
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
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
                          _isTestSuccessful
                              ? 'Test réussi'
                              : 'Échec du test',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _isTestSuccessful ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(_testResult!),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // Guide d'installation d'Ollama
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Comment installer Gemma sur Ollama',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    '1. Téléchargez et installez Ollama depuis: https://ollama.ai',
                    style: TextStyle(fontSize: 14),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '2. Lancez Ollama et exécutez dans votre terminal ou invite de commande:',
                    style: TextStyle(fontSize: 14),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ollama pull gemma',
                            style: TextStyle(
                              fontFamily: 'monospace',
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Text(
                    '3. Attendez que le téléchargement soit terminé, puis connectez l\'application à l\'URL par défaut.',
                    style: TextStyle(fontSize: 14),
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