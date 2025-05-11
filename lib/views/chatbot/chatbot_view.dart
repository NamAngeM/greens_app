import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/services/chatbot_service.dart';
import 'package:greens_app/views/chatbot/llm_settings_view.dart';
import 'package:greens_app/widgets/menu.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: Color(0xFF1F3140),
        ),
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
              "GreenBot",
              style: TextStyle(
                color: Color(0xFF1F3140),
                fontSize: 18,
                fontWeight: FontWeight.w600,
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
            color: _isN8nAvailable ? AppColors.successColor : AppColors.errorColor,
          ),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Color(0xFF1F3140),
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
          // Titre "Eco Chatbot" - similaire au titre "Our latest products"
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 16),
            child: const Text(
              "Hello I'm GreenBot, your eco assistant",
              style: TextStyle(
                color: Color(0xFF1F3140),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Contenu principal
          Expanded(
            child: Column(
              children: [
                // Indicateur de statut du service
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          _isN8nAvailable ? "Service connecté" : "Service hors ligne",
                          style: TextStyle(
                            color: _isN8nAvailable ? AppColors.successColor : AppColors.errorColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Liste des messages
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
                // Indicateur de chargement
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
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                          ),
                        ),
                        SizedBox(width: 8),
                        Text(
                          "GreenBot est en train d'écrire...",
                          style: TextStyle(
                            color: Color(0xFF1F3140),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                // Zone de saisie
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 4,
                        offset: Offset(0, -2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: 'Posez votre question écologique...',
                            hintStyle: TextStyle(color: Color(0xFF1F3140).withOpacity(0.6)),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: const TextStyle(color: Color(0xFF1F3140)),
                          onSubmitted: (_) => _handleSubmit(),
                        ),
                      ),
                      const SizedBox(width: 8),
                      FloatingActionButton(
                        onPressed: _handleSubmit,
                        backgroundColor: const Color(0xFF4CAF50),
                        elevation: 0,
                        mini: true,
                        child: const Icon(Icons.send),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      // Ajouter le menu de navigation en bas de la page
      bottomNavigationBar: const CustomMenu(currentIndex: 4),
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
                color: Color(0xFF4CAF50),
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
                    ? const Color(0xFF4CAF50)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Color(0xFF1F3140),
                  fontSize: 16,
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
          if (message.isUser)
            const CircleAvatar(
              radius: 18,
              backgroundColor: Color(0xFF1F3140),
              child: Icon(
                Icons.person,
                color: Colors.white,
                size: 20,
              ),
            ),
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
