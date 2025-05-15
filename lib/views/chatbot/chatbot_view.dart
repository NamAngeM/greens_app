import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/services/gemini_chatbot_service.dart';
import 'package:greens_app/views/chatbot/chatbot_settings_view.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:greens_app/models/chatbot_message.dart';
import 'package:provider/provider.dart';

class ChatbotView extends StatefulWidget {
  const ChatbotView({Key? key}) : super(key: key);

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late GeminiChatbotService _chatbotService;
  int _currentIndex = 4; // Index pour le menu (4 = Chatbot)
  
  @override
  void initState() {
    super.initState();
    _initChatbotService();
  }
  
  Future<void> _initChatbotService() async {
    try {
      _chatbotService = GeminiChatbotService.instance;
      
      // Initialiser le service avec la clé API Gemini
      await _chatbotService.initialize(
        apiKey: 'AIzaSyBaxf3w-7kaMJo5UF_feoSb7_xJ6fQOjok',
      );
      
      if (!_chatbotService.messages.any((msg) => !msg.isUser)) {
        // Ajouter un message de bienvenue si aucun message du bot n'existe encore
        final welcomeMessage = ChatbotMessage(
          id: 'welcome',
          text: "Bonjour ! Je suis GreenBot, votre assistant écologique propulsé par Gemini. Comment puis-je vous aider aujourd'hui ?",
          isUser: false,
          timestamp: DateTime.now(),
        );
        _chatbotService.clearHistory();
        await _chatbotService.sendMessage("", initialMessage: welcomeMessage);
        if (mounted) setState(() {});
      }
      
      // Vérifier si nous sommes en mode hors ligne et afficher une notification
      if (!_chatbotService.isInitialized) {
        // Ajouter un message informant l'utilisateur du mode hors ligne
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Chatbot en mode hors ligne : fonctionnalités limitées. Appuyez sur ? pour l\'aide.',
                style: TextStyle(fontSize: 13),
              ),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 8),
              action: SnackBarAction(
                label: 'AIDE',
                textColor: Colors.white,
                onPressed: () => _showHelpDialog(context),
              ),
            ),
          );
        });
      }
    } catch (e) {
      print('Erreur lors de l\'initialisation du service de chatbot: $e');
      
      // Ajouter un message d'erreur pour l'utilisateur
      if (mounted) {
        // Informer l'utilisateur de l'erreur et comment la résoudre
        final errorMessage = ChatbotMessage(
          id: 'error',
          text: "Je rencontre des problèmes de connexion avec l'API Gemini.\n\n"
               "Pour utiliser le chatbot :\n\n"
               "1. Assurez-vous que votre appareil est connecté à Internet\n"
               "2. Vérifiez que la clé API Gemini est valide\n\n"
               "Si le problème persiste, contactez le support technique.",
          isUser: false,
          timestamp: DateTime.now(),
        );
        
        _chatbotService.addMessage(errorMessage);
        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
  
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    }
  }

  void _sendMessage() async {
    final message = _messageController.text.trim();
    if (message.isEmpty) return;
    
    _messageController.clear();
    
    await _chatbotService.sendMessage(message);
    _scrollToBottom();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(
              Icons.chat_bubble_outline,
              color: AppColors.primaryColor,
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              "Assistant Écologique",
              style: TextStyle(
                color: Color(0xFF1F3140),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          // Bouton d'aide
          IconButton(
            icon: const Icon(Icons.help_outline, color: Color(0xFF1F3140)),
            onPressed: () {
              _showHelpDialog(context);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Titre "Discutez avec notre IA"
          Container(
            width: double.infinity,
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16, top: 8, bottom: 16),
            child: const Text(
              "Discutez avec notre IA",
              style: TextStyle(
                color: Color(0xFF1F3140),
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // Zone d'informations sur le statut du chatbot
          _buildStatusBar(),
          
          // Zone de messages
          Expanded(
            child: AnimatedBuilder(
              animation: _chatbotService,
              builder: (context, child) {
                return _buildMessageList();
              },
            ),
          ),
          
          // Zone de saisie
          _buildInputArea(),
        ],
      ),
      bottomNavigationBar: CustomMenu(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            setState(() {
              _currentIndex = index;
            });
            
            // Navigation vers la page correspondante
            switch (index) {
              case 0:
                Navigator.pushReplacementNamed(context, AppRoutes.home);
                break;
              case 1:
                Navigator.pushReplacementNamed(context, AppRoutes.products);
                break;
              case 2:
                Navigator.pushReplacementNamed(context, AppRoutes.carbonCalculator);
                break;
              case 3:
                Navigator.pushReplacementNamed(context, AppRoutes.community);
                break;
              case 4:
                // Déjà sur la page chatbot
                break;
            }
          }
        },
      ),
    );
  }
  
  Widget _buildStatusBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: _chatbotService.isInitialized 
          ? Colors.green.withOpacity(0.1)
          : Colors.orange.withOpacity(0.1),
      child: Row(
        children: [
          Icon(
            _chatbotService.isInitialized ? Icons.check_circle : Icons.warning,
            size: 16,
            color: _chatbotService.isInitialized ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _chatbotService.isInitialized
                  ? "Connecté à l'API Gemini"
                  : "Mode hors ligne - Fonctionnalités limitées",
              style: TextStyle(
                fontSize: 12,
                color: _chatbotService.isInitialized ? Colors.green : Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    final messages = _chatbotService.messages;
    
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          "Posez une question à notre assistant écologique",
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }
    
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        return _buildMessageBubble(message);
      },
    );
  }
  
  Widget _buildMessageBubble(ChatbotMessage message) {
    final isUser = message.isUser;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: AppColors.primaryColor.withOpacity(0.1),
              radius: 16,
              child: Icon(
                Icons.eco,
                color: AppColors.primaryColor,
                size: 16,
              ),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isUser 
                    ? AppColors.primaryColor 
                    : Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: isUser ? Colors.white : Colors.black87,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: AppColors.primaryColor,
              radius: 16,
              child: const Icon(
                Icons.person,
                color: Colors.white,
                size: 16,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Posez votre question...",
                hintStyle: TextStyle(color: Colors.grey[400]),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: _chatbotService.isProcessing
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.send, color: Colors.white),
              onPressed: _chatbotService.isProcessing ? null : _sendMessage,
            ),
          ),
        ],
      ),
    );
  }
  
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              Icons.help_outline,
              color: AppColors.primaryColor,
            ),
            const SizedBox(width: 8),
            const Text("Aide du Chatbot"),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Exemples de questions:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            _buildHelpItem(
              "Comment réduire mon empreinte carbone ?",
            ),
            _buildHelpItem(
              "Quels sont les produits écologiques recommandés ?",
            ),
            _buildHelpItem(
              "Comment économiser l'eau au quotidien ?",
            ),
            _buildHelpItem(
              "Qu'est-ce que l'empreinte numérique ?",
            ),
            const SizedBox(height: 16),
            const Text(
              "À propos du chatbot:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              "Ce chatbot utilise l'API Gemini de Google pour vous fournir des informations précises sur l'écologie et le développement durable.",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Fermer"),
          ),
        ],
      ),
    );
  }
  
  Widget _buildHelpItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
