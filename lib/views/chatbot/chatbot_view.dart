import 'package:flutter/material.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/services/llm_service.dart';
import 'package:greens_app/utils/llm_config.dart';
import 'package:greens_app/views/chatbot/llm_settings_view.dart';

import '../../utils/app_colors.dart';
import '../../widgets/menu.dart';

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
  late LlmService _llmService;
  bool _isModelAvailable = false;

  @override
  void initState() {
    super.initState();
    _initLlmService();
    
    // Message initial pour expliquer la fonctionnalité
    _addBotMessage("Bonjour ! Je suis GreenBot, votre assistant spécialisé en écologie. Je peux vous aider sur des sujets comme le développement durable, la réduction des déchets, ou la conservation de l'énergie. Que souhaitez-vous savoir aujourd'hui ?");
    
    // Vérifier après un court délai si le modèle est disponible
    Future.delayed(const Duration(seconds: 2), () {
      if (!_isModelAvailable && mounted) {
        _addBotMessage("⚠️ Je remarque que je ne suis pas connecté à mon modèle de langage local (Gemma). Pour profiter de mes capacités complètes, veuillez configurer le modèle local via le bouton Paramètres en haut à droite.");
      }
    });
  }
  
  Future<void> _initLlmService() async {
    try {
      if (!mounted) return;
      
      // Utiliser le singleton du service LLM
      await LlmService.initialize();
      _llmService = LlmService.instance;
      
      // Vérifier si le modèle est disponible
      try {
        final testResponse = await _llmService.testConnection();
        setState(() {
          _isModelAvailable = testResponse.contains("Service actif");
        });
      } catch (e) {
        print('Erreur lors du test de connectivité: $e');
        setState(() {
          _isModelAvailable = false;
        });
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation du service LLM: $e');
      setState(() {
        _isModelAvailable = false;
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
    
    // Indiquer que le bot est en train d'écrire
    setState(() {
      _isTyping = true;
    });
    
    if (!_isModelAvailable) {
      await Future.delayed(const Duration(seconds: 1));
      _addBotMessage("Désolé, je ne peux pas me connecter au modèle Gemma local. Veuillez vérifier les paramètres de connexion ou lancer le serveur Gemma sur votre ordinateur.");
      setState(() {
        _isTyping = false;
      });
      return;
    }
    
    try {
      // Vérifier si la question est liée à l'écologie
      final isEcoRelated = await _llmService.isEcoRelated(text);
      
      if (!isEcoRelated) {
        _addBotMessage("Je suis spécialisé dans les sujets liés à l'écologie et au développement durable. Pourriez-vous me poser une question sur ces thèmes ?");
      } else {
        // Obtenir une réponse du service LLM
        final response = await _llmService.askEcoQuestion(text);
        _addBotMessage(response);
      }
    } catch (e) {
      print('Erreur lors de la communication avec le modèle: $e');
      _addBotMessage("Désolé, une erreur s'est produite lors de la communication avec le modèle. Veuillez réessayer plus tard.");
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
          IconButton(
            icon: Icon(
              Icons.settings,
              color: Colors.white,
              // Indicateur visuel si le modèle n'est pas disponible
              size: _isModelAvailable ? 24 : 28,
            ),
            color: _isModelAvailable ? Colors.white : Colors.red,
            onPressed: () {
              // Naviguer vers les paramètres du LLM
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LlmSettingsView()),
              ).then((_) => _initLlmService());
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(30),
          child: Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16, bottom: 16),
            child: Row(
              children: [
                const Text(
                  "Ask me about ecology!",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'RethinkSans',
                  ),
                ),
                if (!_isModelAvailable) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Text(
                      "Offline",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _buildMessageBubble(message);
              },
            ),
          ),
          
          // Indicateur de frappe
          if (_isTyping)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              alignment: Alignment.centerLeft,
              child: const Text(
                "GreenBot is writing...",
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                  fontFamily: 'RethinkSans',
                ),
              ),
            ),
          
          // Barre de saisie
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3246),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(25),
                    ),
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Send a message...',
                        border: InputBorder.none,
                        hintStyle: TextStyle(
                          fontFamily: 'RethinkSans',
                        ),
                      ),
                      style: const TextStyle(
                        fontFamily: 'RethinkSans',
                      ),
                      onSubmitted: (_) => _handleSubmit(),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Container(
                  width: 50,
                  height: 50,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.send,
                      color: Color(0xFF1E3246),
                    ),
                    onPressed: () => _handleSubmit(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: const CustomMenu(currentIndex: 4),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            Container(
              width: 36,
              height: 36,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Icon(
                  Icons.eco,
                  color: AppColors.secondaryColor,
                  size: 20,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: message.isUser 
                    ? AppColors.secondaryColor 
                    : Colors.white, 
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : const Color(0xFF1E3246),
                  fontSize: 16,
                  fontFamily: 'RethinkSans',
                ),
              ),
            ),
          ),
          if (message.isUser) const SizedBox(width: 8),
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
