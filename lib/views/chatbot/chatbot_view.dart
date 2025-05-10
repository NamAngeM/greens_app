import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/services/chatbot_service.dart';
import 'package:greens_app/views/chatbot/llm_settings_view.dart';
import 'package:uuid/uuid.dart';

class ChatbotView extends StatefulWidget {
  const ChatbotView({Key? key}) : super(key: key);

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isTyping = false;
  late ChatbotService _n8nService;
  bool _isN8nAvailable = false;
  final String _sessionId = const Uuid().v4();

  @override
  void initState() {
    super.initState();
    _initAIService();
    
    _addBotMessage("Bonjour ! Je suis GreenBot, votre assistant spécialisé en écologie. Je peux vous aider sur des sujets comme le développement durable, la réduction des déchets, ou la conservation de l'énergie. Que souhaitez-vous savoir aujourd'hui ?");
  }
  
  Future<void> _initAIService() async {
    try {
      if (!mounted) return;
      
      // Initialiser n8n
      _n8nService = ChatbotService.instance;
      await _n8nService.initialize(webhookUrl: 'https://angenam.app.n8n.cloud/webhook-test/chatbot-eco');
      
      setState(() {
        _isN8nAvailable = _n8nService.isInitialized;
      });
    } catch (e) {
      print('Erreur lors de l\'initialisation du service d\'IA: $e');
      setState(() {
        _isN8nAvailable = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: true,
        ),
      );
    });
    
    _scrollToBottom();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(
        ChatMessage(
          text: text,
          isUser: false,
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

  Future<void> _handleSubmit() async {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;
    
    _addUserMessage(text);
    _messageController.clear();
    
    setState(() {
      _isTyping = true;
    });
    
    // Vérifier la disponibilité du service
    if (!_isN8nAvailable) {
      await Future.delayed(const Duration(seconds: 1));
      _addBotMessage("Désolé, je ne peux pas me connecter au service n8n. Veuillez vérifier votre configuration.");
      setState(() {
        _isTyping = false;
      });
      return;
    }
    
    try {
      // Convertir les 5 derniers messages pour le contexte
      final context = _messages
          .where((msg) => _messages.indexOf(msg) >= _messages.length - 5)
          .map((msg) => {
                'text': msg.text,
                'isUser': msg.isUser,
                'timestamp': DateTime.now().toIso8601String(),
              })
          .toList();
      
      String response = await _n8nService.getResponse(text, context: context);
      
      _addBotMessage(response);
    } catch (e) {
      print('Erreur lors de la communication avec le service d\'IA: $e');
      _addBotMessage("Désolé, une erreur s'est produite lors de la communication avec le service d'IA. Veuillez réessayer plus tard.");
    } finally {
      setState(() {
        _isTyping = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3246), 
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3246),
        elevation: 0,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logo/green_minds_logo.png',
              width: 24,
              height: 24,
              color: AppColors.secondaryColor,
            ),
            const SizedBox(width: 8),
            const Text(
              "Hello I'm GreenBot,",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w400,
                fontFamily: 'RethinkSans',
              ),
            ),
          ],
        ),
        actions: [
          // Indicateur d'état
          Icon(
            Icons.circle,
            size: 12,
            color: _isN8nAvailable ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LLMSettingsView(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.api,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      const Text(
                        "n8n (agent IA)",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.circle,
                        size: 8,
                        color: _isN8nAvailable ? Colors.green : Colors.red,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index]);
              },
            ),
          ),
          if (_isTyping)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    "GreenBot est en train d'écrire...",
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            color: const Color(0xFF162736),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Posez votre question écologique...',
                      hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                      filled: true,
                      fillColor: const Color(0xFF1E3246),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    onSubmitted: (_) => _handleSubmit(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton(
                  onPressed: _handleSubmit,
                  backgroundColor: AppColors.secondaryColor,
                  elevation: 0,
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.eco,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              decoration: BoxDecoration(
                color: message.isUser
                    ? AppColors.secondaryColor
                    : const Color(0xFF162736),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;

  ChatMessage({
    required this.text,
    required this.isUser,
  });
}
