import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/local_chatbot_service.dart';
import '../utils/app_colors.dart';

class ChatbotSettingsScreen extends StatefulWidget {
  const ChatbotSettingsScreen({Key? key}) : super(key: key);

  @override
  _ChatbotSettingsScreenState createState() => _ChatbotSettingsScreenState();
}

class _ChatbotSettingsScreenState extends State<ChatbotSettingsScreen> {
  bool _showTypingIndicator = true;
  bool _useNaturalLanguage = true;
  bool _showSuggestions = true;
  bool _useContext = true;
  bool _useSynonyms = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final chatbotService = Provider.of<LocalChatbotService>(context, listen: false);
    final settings = await chatbotService.getSettings();
    
    setState(() {
      _showTypingIndicator = settings['showTypingIndicator'] ?? true;
      _useNaturalLanguage = settings['useNaturalLanguage'] ?? true;
      _showSuggestions = settings['showSuggestions'] ?? true;
      _useContext = settings['useContext'] ?? true;
      _useSynonyms = settings['useSynonyms'] ?? true;
    });
  }

  Future<void> _saveSettings() async {
    final chatbotService = Provider.of<LocalChatbotService>(context, listen: false);
    await chatbotService.updateSettings({
      'showTypingIndicator': _showTypingIndicator,
      'useNaturalLanguage': _useNaturalLanguage,
      'showSuggestions': _showSuggestions,
      'useContext': _useContext,
      'useSynonyms': _useSynonyms,
    });
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Paramètres sauvegardés avec succès'),
          backgroundColor: AppColors.successColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres du Chatbot'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildSection(
            title: 'Interface',
            children: [
              SwitchListTile(
                title: const Text('Afficher l\'indicateur de frappe'),
                subtitle: const Text('Montre quand le chatbot est en train de répondre'),
                value: _showTypingIndicator,
                onChanged: (value) {
                  setState(() {
                    _showTypingIndicator = value;
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
              SwitchListTile(
                title: const Text('Afficher les suggestions'),
                subtitle: const Text('Propose des questions similaires quand aucune réponse n\'est trouvée'),
                value: _showSuggestions,
                onChanged: (value) {
                  setState(() {
                    _showSuggestions = value;
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          _buildSection(
            title: 'Intelligence artificielle',
            children: [
              SwitchListTile(
                title: const Text('Langage naturel'),
                subtitle: const Text('Utilise des phrases de transition pour des réponses plus naturelles'),
                value: _useNaturalLanguage,
                onChanged: (value) {
                  setState(() {
                    _useNaturalLanguage = value;
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
              SwitchListTile(
                title: const Text('Gestion du contexte'),
                subtitle: const Text('Prend en compte les questions précédentes pour des réponses plus pertinentes'),
                value: _useContext,
                onChanged: (value) {
                  setState(() {
                    _useContext = value;
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
              SwitchListTile(
                title: const Text('Utiliser les synonymes'),
                subtitle: const Text('Améliore la compréhension des questions en utilisant des mots similaires'),
                value: _useSynonyms,
                onChanged: (value) {
                  setState(() {
                    _useSynonyms = value;
                  });
                },
                activeColor: AppColors.primaryColor,
              ),
            ],
          ),
          const SizedBox(height: 32.0),
          ElevatedButton(
            onPressed: _saveSettings,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16.0),
            ),
            child: const Text(
              'Sauvegarder les paramètres',
              style: TextStyle(fontSize: 16.0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
            ),
          ),
        ),
        Card(
          elevation: 2.0,
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }
} 