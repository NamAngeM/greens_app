import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/services/chatbot_service.dart';

class ChatbotSettingsView extends StatefulWidget {
  const ChatbotSettingsView({Key? key}) : super(key: key);

  @override
  State<ChatbotSettingsView> createState() => _ChatbotSettingsViewState();
}

class _ChatbotSettingsViewState extends State<ChatbotSettingsView> {
  bool _isTesting = false;
  bool _isInitialized = false;
  
  @override
  void initState() {
    super.initState();
    _testChatbot();
  }
  
  Future<void> _testChatbot() async {
    setState(() {
      _isTesting = true;
    });
    
    try {
      final service = ChatbotService();
      await service.initialize();
      
      setState(() {
        _isInitialized = service.isInitialized;
        _isTesting = false;
      });
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _isTesting = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'initialisation du chatbot: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres du Chatbot'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusSection(),
            const SizedBox(height: 24),
            _buildHelpSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildStatusSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _isInitialized ? Icons.check_circle : Icons.warning,
                color: _isInitialized ? Colors.green : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isInitialized 
                      ? 'Le chatbot est prêt à être utilisé'
                      : 'Le chatbot n\'est pas initialisé',
                  style: TextStyle(
                    color: _isInitialized ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isTesting ? null : _testChatbot,
            icon: _isTesting 
                ? const SizedBox(
                    width: 16, 
                    height: 16, 
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(_isTesting ? 'Test en cours...' : 'Tester le chatbot'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHelpSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Comment utiliser le chatbot',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Le chatbot peut vous aider avec des questions sur :\n\n'
            '- La réduction de l\'empreinte carbone\n'
            '- La gestion des déchets plastiques\n'
            '- L\'économie d\'eau\n\n'
            'Pour obtenir les meilleures réponses, essayez de :\n'
            '1. Poser des questions claires et précises\n'
            '2. Utiliser des mots-clés pertinents\n'
            '3. Reformuler votre question si nécessaire',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
} 