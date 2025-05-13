import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/services/hybrid_chatbot_service.dart';
import 'package:greens_app/services/ollama_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ChatbotSettingsView extends StatefulWidget {
  const ChatbotSettingsView({Key? key}) : super(key: key);

  @override
  State<ChatbotSettingsView> createState() => _ChatbotSettingsViewState();
}

class _ChatbotSettingsViewState extends State<ChatbotSettingsView> {
  final TextEditingController _rasaUrlController = TextEditingController();
  final TextEditingController _ollamaUrlController = TextEditingController();
  String _selectedModel = 'llama3';
  bool _isTestingRasa = false;
  bool _isTestingOllama = false;
  bool _isRasaConnected = false;
  bool _isOllamaConnected = false;
  List<String> _availableModels = ['llama3', 'llama2', 'mistral', 'gemma', 'phi'];
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
    _loadAvailableModels();
  }
  
  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _rasaUrlController.text = prefs.getString('rasa_url') ?? 'http://localhost:5005';
      _ollamaUrlController.text = prefs.getString('ollama_url') ?? 'http://192.168.1.97:11434';
      _selectedModel = prefs.getString('ollama_model') ?? 'llama3';
    });
    
    // Tester les connexions
    _testRasaConnection();
    _testOllamaConnection();
    
    // Charger les modèles disponibles
    _loadAvailableModels();
  }
  
  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    await prefs.setString('rasa_url', _rasaUrlController.text);
    await prefs.setString('ollama_url', _ollamaUrlController.text);
    await prefs.setString('ollama_model', _selectedModel);
    
    // Réinitialiser le service avec les nouvelles configurations
    final chatbotService = HybridChatbotService.instance;
    await chatbotService.initialize(
      rasaUrl: _rasaUrlController.text,
      ollamaUrl: _ollamaUrlController.text,
      ollamaModel: _selectedModel,
    );
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Paramètres enregistrés'),
        backgroundColor: AppColors.successColor,
      ),
    );
  }
  
  Future<void> _testRasaConnection() async {
    setState(() {
      _isTestingRasa = true;
    });
    
    try {
      final url = _rasaUrlController.text;
      final uri = Uri.parse('$url/status');
      
      final response = await http.get(uri).timeout(
        const Duration(seconds: 5),
        onTimeout: () => http.Response('Timeout', 408),
      );
      
      setState(() {
        _isRasaConnected = response.statusCode == 200;
        _isTestingRasa = false;
      });
    } catch (e) {
      setState(() {
        _isRasaConnected = false;
        _isTestingRasa = false;
      });
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur de connexion à Rasa: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
  
  Future<void> _testOllamaConnection() async {
    setState(() {
      _isTestingOllama = true;
    });
    
    try {
      final service = OllamaService();
      await service.initialize(baseUrl: _ollamaUrlController.text);
      
      setState(() {
        _isOllamaConnected = service.isInitialized;
        _isTestingOllama = false;
      });
      
      if (_isOllamaConnected) {
        _loadAvailableModels();
      }
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
  
  Future<void> _loadAvailableModels() async {
    try {
      final ollamaService = OllamaService();
      await ollamaService.initialize(
        baseUrl: _ollamaUrlController.text,
      );
      
      final models = await ollamaService.getAvailableModels();
      if (models.isNotEmpty) {
        setState(() {
          _availableModels = models;
          // S'assurer que le modèle sélectionné est dans la liste
          if (!_availableModels.contains(_selectedModel)) {
            _selectedModel = _availableModels.first;
          }
        });
        
        print('Modèles Ollama disponibles: $_availableModels');
      }
    } catch (e) {
      print('Erreur lors du chargement des modèles Ollama: $e');
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
            // Section Rasa
            _buildSectionTitle('Configuration de Rasa'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _rasaUrlController,
              label: 'URL du serveur Rasa',
              hint: 'http://localhost:5005',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTestingRasa ? null : _testRasaConnection,
                    icon: _isTestingRasa 
                        ? const SizedBox(
                            width: 16, 
                            height: 16, 
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isRasaConnected ? Icons.check_circle : Icons.cloud,
                            color: _isRasaConnected ? Colors.green : Colors.white,
                          ),
                    label: Text(_isRasaConnected 
                        ? 'Connecté' 
                        : 'Tester la connexion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isRasaConnected 
                          ? Colors.green.withOpacity(0.2) 
                          : AppColors.primaryColor,
                      foregroundColor: _isRasaConnected 
                          ? Colors.green
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Section Ollama
            _buildSectionTitle('Configuration d\'Ollama'),
            const SizedBox(height: 8),
            _buildOllamaSettings(),
            const SizedBox(height: 16),
            _buildDropdownField(
              label: 'Modèle',
              value: _selectedModel,
              items: _availableModels,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _selectedModel = value;
                  });
                }
              },
              hint: 'Sélectionnez un modèle',
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _isTestingOllama ? null : _testOllamaConnection,
                    icon: _isTestingOllama 
                        ? const SizedBox(
                            width: 16, 
                            height: 16, 
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(
                            _isOllamaConnected ? Icons.check_circle : Icons.cloud,
                            color: _isOllamaConnected ? Colors.green : Colors.white,
                          ),
                    label: Text(_isOllamaConnected 
                        ? 'Connecté' 
                        : 'Tester la connexion'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isOllamaConnected 
                          ? Colors.green.withOpacity(0.2) 
                          : AppColors.primaryColor,
                      foregroundColor: _isOllamaConnected 
                          ? Colors.green
                          : Colors.white,
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (_isOllamaConnected)
              OutlinedButton.icon(
                onPressed: _loadAvailableModels,
                icon: const Icon(Icons.refresh),
                label: const Text('Rafraîchir la liste des modèles'),
              ),
            
            const SizedBox(height: 32),
            
            // Bouton d'enregistrement
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _saveSettings,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: const Text('Enregistrer les paramètres'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 32),
            
            // Informations sur l'installation
            _buildInfoCard(),
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
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
    String? hint,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<String>(
                value: value,
                decoration: InputDecoration(
                  hintText: hint,
                  border: const OutlineInputBorder(),
                ),
                items: items.map((item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  );
                }).toList(),
                onChanged: onChanged,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: const Icon(Icons.refresh),
              tooltip: 'Actualiser la liste des modèles',
              onPressed: () {
                _loadAvailableModels();
              },
            ),
          ],
        ),
      ],
    );
  }
  
  Widget _buildOllamaSettings() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Configuration d\'Ollama (LLM local)', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        
        // Carte d'information sur la configuration d'Ollama
        Card(
          margin: const EdgeInsets.only(bottom: 16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    const Text('Informations importantes', style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Si Ollama est installé sur un autre appareil du réseau, remplacez "localhost" '
                  'par l\'adresse IP de cet appareil, par exemple "http://192.168.1.97:11434".',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 8),
                Text(
                  'Configuration actuelle: Ollama sur 192.168.1.97 (votre adresse IP locale)',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.secondaryColor),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Assurez-vous que le modèle Llama3 est bien installé sur le serveur Ollama avec la commande : "ollama pull llama3"',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ),
        
        TextFormField(
          controller: _ollamaUrlController,
          decoration: const InputDecoration(
            labelText: 'URL d\'Ollama',
            hintText: 'http://localhost:11434',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }
  
  Widget _buildInfoCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Comment installer Rasa et Ollama',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Pour utiliser le chatbot en local, vous devez installer Rasa et Ollama sur votre ordinateur:',
            ),
            const SizedBox(height: 16),
            _buildInstallStep(
              title: 'Installer Rasa',
              instructions: [
                'pip install rasa',
                'rasa init',
                'rasa run --enable-api'
              ],
              link: 'https://rasa.com/docs/rasa/installation',
            ),
            const SizedBox(height: 16),
            _buildInstallStep(
              title: 'Installer Ollama',
              instructions: [
                'Télécharger depuis ollama.ai',
                'ollama pull llama3'
              ],
              link: 'https://ollama.ai',
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInstallStep({
    required String title,
    required List<String> instructions,
    required String link,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        ...instructions.map((instruction) => 
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('• '),
                Expanded(
                  child: Text(
                    instruction,
                    style: TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 12,
                      backgroundColor: Colors.grey.shade100,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            // Ouvrir le lien
          },
          child: Text('Voir la documentation ($link)'),
        ),
      ],
    );
  }
  
  @override
  void dispose() {
    _rasaUrlController.dispose();
    _ollamaUrlController.dispose();
    super.dispose();
  }
} 