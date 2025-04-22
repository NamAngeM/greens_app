import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../services/llm_service.dart';
import '../services/ollama_service.dart';
import '../widgets/streaming_response_widget.dart';
import '../widgets/chat_history_widget.dart';
import '../widgets/model_selector_widget.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<Widget> _chatWidgets = [];
  bool _isTyping = false;
  bool _isStreaming = false;
  final LlmService _llmService = LlmService.instance;
  final OllamaService _ollamaService = OllamaService.instance;
  
  // Identifiant unique pour cette conversation
  final String _conversationId = const Uuid().v4();
  
  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  Future<void> _initializeService() async {
    setState(() => _isTyping = true);
    try {
      // Sélectionner automatiquement le meilleur modèle
      await _ollamaService.selectBestModel();
      await _llmService.initialize();
      
      setState(() {
        _chatWidgets.add(
          _buildBotMessage("Bonjour ! Je suis GreenBot, votre assistant écologique. Comment puis-je vous aider aujourd'hui ?")
        );
        _isTyping = false;
      });
      
      // Ajouter le message de bienvenue à l'historique
      _ollamaService.addToHistory(_conversationId, 'assistant', 
        "Bonjour ! Je suis GreenBot, votre assistant écologique. Comment puis-je vous aider aujourd'hui ?");
      
    } catch (e) {
      setState(() {
        _chatWidgets.add(
          _buildErrorMessage("Erreur lors de l'initialisation du service: $e")
        );
        _isTyping = false;
      });
    }
  }
  
  Widget _buildUserMessage(String text) {
    return Container(
      alignment: Alignment.centerRight,
      margin: const EdgeInsets.only(left: 50, right: 8, top: 8, bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.blue.shade100,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(text),
      ),
    );
  }
  
  Widget _buildBotMessage(String text) {
    return Container(
      alignment: Alignment.centerLeft,
      margin: const EdgeInsets.only(right: 50, left: 8, top: 8, bottom: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco, color: Colors.green.shade700, size: 16),
                const SizedBox(width: 4),
                Text(
                  'GreenBot', 
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(text),
          ],
        ),
      ),
    );
  }
  
  Widget _buildErrorMessage(String text) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Row(
          children: [
            Icon(Icons.error_outline, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(color: Colors.red.shade700),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isTyping) return;

    String messageText = _messageController.text;
    _messageController.clear();

    setState(() {
      _chatWidgets.add(_buildUserMessage(messageText));
      _isTyping = true;
      _isStreaming = true;
      
      // Ajouter un widget de streaming qui va s'auto-mettre à jour
      _chatWidgets.add(
        StreamingResponseWidget(
          prompt: messageText,
          conversationId: _conversationId,
          onResponseComplete: (finalResponse) {
            setState(() {
              // Remplacer le widget de streaming par la réponse finale
              _chatWidgets.removeLast();
              _chatWidgets.add(_buildBotMessage(finalResponse));
              _isTyping = false;
              _isStreaming = false;
            });
          },
          onCancel: () {
            setState(() {
              // Annuler la génération et remplacer par un message d'erreur
              _chatWidgets.removeLast();
              _chatWidgets.add(_buildErrorMessage("Génération annulée par l'utilisateur."));
              _isTyping = false;
              _isStreaming = false;
            });
          },
        ),
      );
    });

    _scrollToBottom();
  }
  
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }
  
  void _showHistoryDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          height: MediaQuery.of(context).size.height * 0.7,
          padding: const EdgeInsets.all(16),
          child: ChatHistoryWidget(
            conversationId: _conversationId,
            onHistoryCleared: () {
              setState(() {
                // Réinitialiser le chat lorsque l'historique est effacé
                _chatWidgets.clear();
                _chatWidgets.add(_buildBotMessage("L'historique a été effacé. Comment puis-je vous aider aujourd'hui ?"));
              });
            },
          ),
        ),
      ),
    ).then((selectedPrompt) {
      if (selectedPrompt != null && selectedPrompt is String) {
        // Si l'utilisateur a sélectionné une question précédente, la réutiliser
        _messageController.text = selectedPrompt;
      }
    });
  }
  
  void _showModelSelectorDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        child: Container(
          width: double.maxFinite,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Sélectionner un modèle',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              ModelSelectorWidget(
                initialModel: _ollamaService.currentModel,
                onModelSelected: (modelName) {
                  _ollamaService.currentModel = modelName;
                },
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Fermer'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GreenBot'),
        backgroundColor: Colors.green.shade700,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Historique des conversations',
            onPressed: _showHistoryDialog,
          ),
          IconButton(
            icon: const Icon(Icons.model_training),
            tooltip: 'Changer de modèle',
            onPressed: _showModelSelectorDialog,
          ),
        ],
      ),
      body: Column(
        children: [
          // Bannière du modèle sélectionné
          Container(
            color: Colors.green.shade100,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Icon(Icons.smart_toy, size: 16, color: Colors.green.shade800),
                const SizedBox(width: 8),
                Text(
                  'Modèle: ${_ollamaService.currentModel}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.green.shade800,
                  ),
                ),
                const Spacer(),
                if (_isStreaming)
                  TextButton.icon(
                    icon: Icon(Icons.speed, size: 16, color: Colors.green.shade800),
                    label: Text(
                      'Mode streaming actif',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.green.shade800,
                      ),
                    ),
                    onPressed: null,
                  ),
              ],
            ),
          ),
          
          Expanded(
            child: _chatWidgets.isEmpty
                ? Center(
                    child: Text(
                      _isTyping 
                          ? 'Initialisation...' 
                          : 'Envoyez un message pour commencer la conversation',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _chatWidgets.length,
                    padding: const EdgeInsets.all(8.0),
                    itemBuilder: (context, index) {
                      return _chatWidgets[index];
                    },
                  ),
          ),
          
          if (_isTyping && !_isStreaming)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.green.shade700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Assistant réfléchit...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -1),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Posez une question écologique...',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.all(16),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                    enabled: !_isTyping,
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.send,
                    color: _isTyping 
                      ? Colors.grey.shade400 
                      : Colors.green.shade700,
                  ),
                  onPressed: _isTyping ? null : _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 