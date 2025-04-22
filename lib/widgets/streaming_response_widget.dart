import 'package:flutter/material.dart';
import '../services/ollama_service.dart';

class StreamingResponseWidget extends StatefulWidget {
  final String prompt;
  final String conversationId;
  final Function(String) onResponseComplete;
  final Function()? onCancel;

  const StreamingResponseWidget({
    Key? key,
    required this.prompt,
    required this.conversationId,
    required this.onResponseComplete,
    this.onCancel,
  }) : super(key: key);

  @override
  State<StreamingResponseWidget> createState() => _StreamingResponseWidgetState();
}

class _StreamingResponseWidgetState extends State<StreamingResponseWidget> {
  final _ollamaService = OllamaService.instance;
  String _currentResponse = '';
  bool _isGenerating = true;
  bool _hasError = false;
  String _errorMessage = '';
  
  @override
  void initState() {
    super.initState();
    _generateResponse();
  }
  
  Future<void> _generateResponse() async {
    try {
      // Mettre à jour l'interface en temps réel à chaque morceau de texte reçu
      final modelConfig = _ollamaService.getModelParams(_ollamaService.currentModel);
      
      final response = await _ollamaService.generateResponse(
        widget.prompt,
        _ollamaService.currentModel,
        conversationId: widget.conversationId,
        temperature: modelConfig['temperature'],
        topP: modelConfig['top_p'],
        numPredict: modelConfig['num_predict'],
        onResponseChunk: (chunk) {
          setState(() {
            _currentResponse += chunk;
          });
        },
      );
      
      if (response['success'] == true) {
        widget.onResponseComplete(response['message']);
      } else {
        setState(() {
          _hasError = true;
          _errorMessage = response['message'] ?? 'Une erreur est survenue lors de la génération.';
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isGenerating = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          margin: const EdgeInsets.only(bottom: 8),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête du message
              Row(
                children: [
                  const Icon(
                    Icons.eco,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'GreenBot',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                  ),
                  const Spacer(),
                  if (_isGenerating)
                    Row(
                      children: [
                        const SizedBox(
                          width: 12,
                          height: 12,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Génération...',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.stop_circle_outlined, size: 16),
                          color: Colors.red.shade400,
                          tooltip: 'Arrêter la génération',
                          onPressed: widget.onCancel,
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              // Contenu du message
              if (_hasError)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.error_outline, color: Colors.red.shade700),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage,
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Text(
                  _currentResponse.isEmpty ? 'Préparation de la réponse...' : _currentResponse,
                  style: const TextStyle(fontSize: 14),
                ),
            ],
          ),
        ),
      ],
    );
  }
} 