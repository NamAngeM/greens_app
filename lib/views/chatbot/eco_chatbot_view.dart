import 'package:flutter/material.dart';
import 'package:greens_app/services/chatbot_service.dart';

/// Modèle pour représenter un message dans le chatbot
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

/// Vue du chatbot écologique qui utilise n8n
class EcoChatbotView extends StatefulWidget {
  const EcoChatbotView({Key? key}) : super(key: key);

  @override
  State<EcoChatbotView> createState() => _EcoChatbotViewState();
}

class _EcoChatbotViewState extends State<EcoChatbotView> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isInitialized = false;
  bool _isLoading = false;
  String _connectionStatus = "Non initialisé";
  late ChatbotService _chatbotService;

  @override
  void initState() {
    super.initState();
    _initializeService();
    // Ajouter un message de bienvenue
    _addBotMessage("Bonjour ! Je suis votre assistant écologique. Comment puis-je vous aider aujourd'hui ?");
  }

  /// Initialiser le service n8n
  Future<void> _initializeService() async {
    setState(() {
      _isLoading = true;
      _connectionStatus = "Connexion en cours...";
    });
    
    try {
      _chatbotService = await ChatbotService.createInstance();
      
      // Initialiser le service avec l'URL du webhook
      await _chatbotService.initialize(webhookUrl: 'https://angenam.app.n8n.cloud/webhook-test/chatbot-eco');
      
      setState(() {
        _isInitialized = _chatbotService.isInitialized;
        _connectionStatus = _isInitialized ? "Connecté" : "Non connecté";
      });
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _connectionStatus = "Erreur: $e";
      });
      print("Erreur lors de l'initialisation du service: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// Ajouter un message de l'utilisateur
  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  /// Ajouter un message du bot
  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  /// Faire défiler jusqu'au bas de la conversation
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

  /// Envoyer un message et obtenir une réponse
  Future<void> _handleSubmit() async {
    final question = _textController.text.trim();
    if (question.isEmpty) return;

    _addUserMessage(question);
    _textController.clear();

    setState(() {
      _isLoading = true;
    });

    try {
      if (!_isInitialized) {
        _addBotMessage("Je ne suis pas connecté au service n8n. Veuillez réessayer plus tard.");
        return;
      }

      // Convertir les 5 derniers messages pour le contexte
      final context = _messages
          .where((msg) => _messages.indexOf(msg) >= _messages.length - 5)
          .map((msg) => {
                'text': msg.text,
                'isUser': msg.isUser,
                'timestamp': DateTime.now().toIso8601String(),
              })
          .toList();
      
      final response = await _chatbotService.getResponse(question, context: context);
      _addBotMessage(response);
    } catch (e) {
      _addBotMessage("Désolé, une erreur s'est produite: $e");
      print("Erreur lors de l'envoi du message: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Assistant Écologique"),
        backgroundColor: Colors.green,
        actions: [
          // Indicateur de statut
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  _isInitialized ? Icons.check_circle : Icons.error,
                  color: _isInitialized ? Colors.green : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _connectionStatus,
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Zone de messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(8.0),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Indicateur de chargement
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8.0),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          
          // Zone de saisie
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: "Posez votre question écologique...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                    onSubmitted: (_) => _handleSubmit(),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _handleSubmit,
                  backgroundColor: Colors.green,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Construire une bulle de message
  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              backgroundColor: Colors.green,
              child: const Icon(
                Icons.eco,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8.0),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12.0),
              decoration: BoxDecoration(
                color: message.isUser
                    ? Colors.green
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Colors.black,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8.0),
            const CircleAvatar(
              backgroundColor: Colors.blue,
              child: Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}