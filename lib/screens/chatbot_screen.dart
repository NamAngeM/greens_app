import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qa_model.dart';
import '../services/local_chatbot_service.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/app_router.dart';
import '../widgets/menu.dart';

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

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({Key? key}) : super(key: key);

  @override
  _ChatbotScreenState createState() => _ChatbotScreenState();
}

class _ChatbotScreenState extends State<ChatbotScreen> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _addWelcomeMessage();
  }

  void _addWelcomeMessage() {
    setState(() {
      _messages.add(ChatMessage(
        text: "Bonjour ! Je suis votre assistant écologique. Je peux vous aider avec des questions sur :\n"
            "- La réduction de l'empreinte carbone\n"
            "- La gestion des déchets\n"
            "- L'économie d'eau\n"
            "- L'alimentation durable\n"
            "- L'impact du numérique\n"
            "- La consommation d'énergie\n"
            "- La mode éthique\n"
            "- La consommation responsable\n"
            "N'hésitez pas à me poser vos questions !",
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
  }

  void _handleSubmitted(String text) async {
    if (text.isEmpty) return;

    _textController.clear();
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
      _isTyping = true;
    });

    // Simuler un délai de réponse
    await Future.delayed(const Duration(milliseconds: 500));

    final chatbotService = Provider.of<LocalChatbotService>(context, listen: false);
    final response = await chatbotService.getResponse(text);

    setState(() {
      _messages.add(ChatMessage(
        text: response,
        isUser: false,
        timestamp: DateTime.now(),
      ));
      _isTyping = false;
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

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Contenu principal (90% de l'écran)
          Container(
            height: screenHeight * 0.9,
            child: SafeArea(
              child: Column(
                children: [
                  // En-tête avec titre et icône de rafraîchissement
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Spacer(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat,
                              color: AppColors.primaryColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Assistant Écologique',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.settings),
                          onPressed: () {
                            Navigator.pushNamed(context, '/chatbot_settings');
                          },
                        ),
                      ],
                    ),
                  ),

                  // Description du chatbot
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Discutez avec notre assistant',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Posez vos questions sur l\'écologie, le développement durable et les gestes quotidiens pour protéger l\'environnement.',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Liste des messages
                  Expanded(
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(8.0),
                      itemCount: _messages.length + (_isTyping ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _messages.length) {
                          return _buildTypingIndicator();
                        }
                        return _buildMessage(_messages[index]);
                      },
                    ),
                  ),

                  // Barre de saisie
                  _buildInputBar(),
                ],
              ),
            ),
          ),

          // Menu de navigation (10% de l'écran)
          CustomMenu(
            currentIndex: 4, // Index pour le chatbot
            onTap: (index) {
              // Navigation vers les différentes pages
              switch (index) {
                case 0:
                  Navigator.pushReplacementNamed(context, AppRoutes.home);
                  break;
                case 1:
                  Navigator.pushReplacementNamed(context, AppRoutes.articles);
                  break;
                case 2:
                  Navigator.pushReplacementNamed(context, AppRoutes.products);
                  break;
                case 3:
                  Navigator.pushReplacementNamed(context, AppRoutes.profile);
                  break;
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(ChatMessage message) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!message.isUser) _buildAvatar(),
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: AppColors.backgroundColor,
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: Text(
              message.text,
              style: TextStyle(
                color: AppColors.primaryColor,
              ),
            ),
          ),
          if (message.isUser) _buildAvatar(isUser: true),
        ],
      ),
    );
  }

  Widget _buildAvatar({bool isUser = false}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: CircleAvatar(
        backgroundColor: isUser ? AppColors.primaryColor : Colors.green,
        child: Icon(
          isUser ? Icons.person : Icons.eco,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          _buildAvatar(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 10.0),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: const Text('...'),
          ),
        ],
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: const InputDecoration(
                hintText: "Posez votre question sur l'écologie...",
                border: InputBorder.none,
              ),
              onSubmitted: _handleSubmitted,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            color: AppColors.primaryColor,
            onPressed: () => _handleSubmitted(_textController.text),
          ),
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