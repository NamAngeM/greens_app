import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/services/ollama_chatbot_service.dart';
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
  late OllamaChatbotService _chatbotService;
  int _currentIndex = 4; // Index pour le menu (4 = Chatbot)
  
  @override
  void initState() {
    super.initState();
    _initChatbotService();
  }
  
  Future<void> _initChatbotService() async {
    try {
      _chatbotService = OllamaChatbotService.instance;
      
      // Initialiser le service avec le modèle Llama3
      await _chatbotService.initialize(model: 'llama3');
      
      if (_chatbotService.conversationHistory.isEmpty) {
        // Ajouter un message de bienvenue si aucun message n'existe encore
        final welcomeMessage = {
          'id': 'welcome',
          'role': 'assistant',
          'content': "Bonjour ! Je suis GreenBot, votre assistant écologique propulsé par Llama3. Comment puis-je vous aider aujourd'hui ?",
        };
        _chatbotService.clearConversation();
        _chatbotService.conversationHistory.add(welcomeMessage);
        if (mounted) setState(() {});
      }
      
      // Vérifier si nous sommes en mode hors ligne et afficher une notification
      if (!_chatbotService.isInitialized) {
        // Ajouter un message informant l'utilisateur du mode hors ligne
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text(
                'Chatbot en mode hors ligne : Ollama n\'est pas disponible. Assurez-vous qu\'Ollama est en cours d\'exécution.',
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
        final errorMessage = {
          'id': 'error',
          'role': 'assistant',
          'content': "Je rencontre des problèmes de connexion avec Ollama.\n\n"
               "Pour utiliser le chatbot :\n\n"
               "1. Assurez-vous qu'Ollama est installé sur votre machine\n"
               "2. Vérifiez qu'Ollama est en cours d'exécution\n"
               "3. Vérifiez que le modèle llama3 est disponible\n\n"
               "Si le problème persiste, contactez le support technique.",
        };
        
        _chatbotService.conversationHistory.add(errorMessage);
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
                  ? "Connecté à Ollama (Llama3)"
                  : "Mode hors ligne - Ollama non disponible",
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
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(16),
      itemCount: _chatbotService.conversationHistory.length,
      itemBuilder: (context, index) {
        final message = _chatbotService.conversationHistory[index];
        final isUser = message['role'] == 'user';
        
        return Align(
          alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            margin: const EdgeInsets.only(bottom: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isUser ? AppColors.primaryColor : Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            child: Text(
              message['content'] ?? '',
              style: TextStyle(
                color: isUser ? Colors.white : Colors.black87,
                fontSize: 14,
              ),
            ),
          ),
        );
      },
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
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: "Écrivez votre message...",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey[100],
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.primaryColor,
              borderRadius: BorderRadius.circular(24),
            ),
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: _sendMessage,
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
        title: const Text("Aide - Assistant Écologique"),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Comment utiliser l'assistant :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "• Posez vos questions sur l'écologie et le développement durable\n"
                "• Demandez des conseils pour réduire votre empreinte carbone\n"
                "• Obtenez des informations sur les pratiques écologiques\n"
                "• Discutez des sujets liés à l'environnement",
              ),
              const SizedBox(height: 16),
              const Text(
                "Fonctionnalités :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "• Réponses en temps réel\n"
                "• Historique des conversations\n"
                "• Mode hors ligne disponible\n"
                "• Interface intuitive",
              ),
              const SizedBox(height: 16),
              const Text(
                "Note :",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Ce chatbot utilise Ollama avec le modèle Llama3 pour vous fournir des informations précises sur l'écologie et le développement durable.",
              ),
            ],
          ),
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
}
