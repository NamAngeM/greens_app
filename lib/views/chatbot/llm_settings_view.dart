import 'package:flutter/material.dart';
import 'package:greens_app/services/chatbot_service.dart';
import 'package:greens_app/utils/app_colors.dart';

class LLMSettingsView extends StatefulWidget {
  const LLMSettingsView({Key? key}) : super(key: key);

  @override
  State<LLMSettingsView> createState() => _LLMSettingsViewState();
}

class _LLMSettingsViewState extends State<LLMSettingsView> {
  final TextEditingController _apiUrlController = TextEditingController();
  late N8nChatbotService _n8nService;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _n8nService = N8nChatbotService.instance;
    _loadCurrentSettings();
  }

  Future<void> _loadCurrentSettings() async {
    // Charger l'URL actuelle
    _apiUrlController.text = 'https://angenam.app.n8n.cloud/webhook-test/chatbot-eco';
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isSaving = true;
    });

    try {
      final url = _apiUrlController.text.trim();
      if (url.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('L\'URL ne peut pas être vide')),
        );
        return;
      }

      // Réinitialiser le service avec la nouvelle URL
      await _n8nService.initialize(webhookUrl: url);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Paramètres enregistrés avec succès')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de l\'enregistrement des paramètres: $e')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres IA'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration du service n8n',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Ces paramètres sont utilisés pour configurer la connexion au service n8n.',
              style: TextStyle(
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _apiUrlController,
              decoration: const InputDecoration(
                labelText: 'URL du webhook n8n',
                hintText: 'https://votre-serveur-n8n.com/webhook/chatbot',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isSaving ? null : _saveSettings,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: _isSaving
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _apiUrlController.dispose();
    super.dispose();
  }
}