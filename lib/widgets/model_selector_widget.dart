import 'package:flutter/material.dart';
import '../services/ollama_service.dart';

class ModelSelectorWidget extends StatefulWidget {
  final String initialModel;
  final Function(String) onModelSelected;
  final bool showRefreshButton;

  const ModelSelectorWidget({
    Key? key,
    required this.initialModel,
    required this.onModelSelected,
    this.showRefreshButton = true,
  }) : super(key: key);

  @override
  State<ModelSelectorWidget> createState() => _ModelSelectorWidgetState();
}

class _ModelSelectorWidgetState extends State<ModelSelectorWidget> {
  final _ollamaService = OllamaService.instance;
  List<String> _availableModels = [];
  String _selectedModel = '';
  bool _isLoadingModels = false;

  @override
  void initState() {
    super.initState();
    _selectedModel = widget.initialModel;
    _loadAvailableModels();
  }

  Future<void> _loadAvailableModels() async {
    setState(() {
      _isLoadingModels = true;
    });
    
    try {
      // Récupérer les modèles configurés dans le service
      final configuredModels = _ollamaService.modelConfigs.keys.toList();
      
      // Tenter de récupérer les modèles réellement disponibles sur le serveur
      if (_ollamaService.isInitialized) {
        final modelsList = await _ollamaService.getAvailableModels();
        
        setState(() {
          // Si des modèles sont installés, filtrer la liste pour n'afficher que ceux disponibles
          if (modelsList.isNotEmpty) {
            _availableModels = configuredModels
                .where((model) => modelsList.contains(model.split(':').first))
                .toList();
            
            // Si aucun modèle filtré n'est disponible, montrer tous les modèles configurés
            if (_availableModels.isEmpty) {
              _availableModels = configuredModels;
            }
          } else {
            // Si aucun modèle n'est retourné, montrer tous les modèles configurés
            _availableModels = configuredModels;
          }
          
          // Si le modèle sélectionné n'est pas disponible, prendre le premier de la liste
          if (!_availableModels.contains(_selectedModel) && _availableModels.isNotEmpty) {
            _selectedModel = _availableModels.first;
            widget.onModelSelected(_selectedModel);
          }
          
          _isLoadingModels = false;
        });
      } else {
        setState(() {
          _availableModels = configuredModels;
          _isLoadingModels = false;
        });
      }
    } catch (e) {
      setState(() {
        // En cas d'erreur, afficher tous les modèles configurés
        _availableModels = _ollamaService.modelConfigs.keys.toList();
        _isLoadingModels = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sélection du modèle',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Choisissez un modèle selon vos besoins. Les modèles plus légers sont plus rapides mais moins précis.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            
            if (_isLoadingModels)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_availableModels.isEmpty)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text('Aucun modèle disponible. Vérifiez votre connexion à Ollama.'),
              )
            else
              Column(
                children: _availableModels.map((modelName) {
                  final modelInfo = _ollamaService.modelConfigs[modelName] ?? {};
                  final name = modelInfo['name'] ?? modelName;
                  final description = modelInfo['description'] ?? 'Modèle Ollama';
                  
                  return RadioListTile<String>(
                    title: Text(name),
                    subtitle: Text(description),
                    value: modelName,
                    groupValue: _selectedModel,
                    onChanged: (value) {
                      setState(() {
                        _selectedModel = value!;
                        widget.onModelSelected(_selectedModel);
                      });
                    },
                  );
                }).toList(),
              ),
              
            if (widget.showRefreshButton)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: OutlinedButton.icon(
                  onPressed: _isLoadingModels ? null : _loadAvailableModels,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Actualiser les modèles'),
                ),
              ),
          ],
        ),
      ),
    );
  }
} 