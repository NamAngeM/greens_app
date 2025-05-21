import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/services/ollama_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ChatbotSettingsView extends StatefulWidget {
  const ChatbotSettingsView({Key? key}) : super(key: key);

  @override
  State<ChatbotSettingsView> createState() => _ChatbotSettingsViewState();
}

class _ChatbotSettingsViewState extends State<ChatbotSettingsView> {
  bool _isTestingOllama = false;
  bool _isOllamaConnected = false;
  
  @override
  void initState() {
    super.initState();
    _testOllamaConnection();
  }
  
  Future<void> _testOllamaConnection() async {
    setState(() {
      _isTestingOllama = true;
    });
    
    try {
      final service = OllamaService();
      await service.initialize(model: 'llama3');
      
      setState(() {
        _isOllamaConnected = service.isInitialized;
        _isTestingOllama = false;
      });
    } catch (e) {
      setState(() {
        _isOllamaConnected = false;
        _isTestingOllama = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion à Ollama: $e'),
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
        title: const Text('Paramètres du chatbot'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Ollama
            _buildSectionTitle('Configuration d\'Ollama'),
            const SizedBox(height: 16),
            _buildOllamaStatus(),
            const SizedBox(height: 24),
            _buildHelpSection(),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }
  
  Widget _buildOllamaStatus() {
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
                _isOllamaConnected ? Icons.check_circle : Icons.warning,
                color: _isOllamaConnected ? Colors.green : Colors.orange,
                size: 24,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _isOllamaConnected 
                      ? 'Ollama est connecté et prêt à être utilisé'
                      : 'Ollama n\'est pas disponible',
                  style: TextStyle(
                    color: _isOllamaConnected ? Colors.green : Colors.orange,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: _isTestingOllama ? null : _testOllamaConnection,
            icon: _isTestingOllama 
                ? const SizedBox(
                    width: 16, 
                    height: 16, 
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh),
            label: Text(_isTestingOllama ? 'Test en cours...' : 'Tester la connexion'),
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
            'Comment utiliser Ollama',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '1. Assurez-vous qu\'Ollama est installé sur votre machine\n'
            '2. Vérifiez qu\'Ollama est en cours d\'exécution\n'
            '3. Vérifiez que le modèle llama3 est disponible\n\n'
            'Pour installer Ollama et le modèle llama3 :\n'
            '1. Téléchargez Ollama depuis https://ollama.ai\n'
            '2. Installez Ollama sur votre machine\n'
            '3. Exécutez la commande : ollama pull llama3',
            style: TextStyle(fontSize: 14),
          ),
        ],
      ),
    );
  }
} 