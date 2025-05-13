import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/services/hybrid_chatbot_service.dart';
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
  late HybridChatbotService _chatbotService;
  int _currentIndex = 4; // Index pour le menu (4 = Chatbot)
  
  @override
  void initState() {
    super.initState();
    _initChatbotService();
  }
  
  Future<void> _initChatbotService() async {
    try {
      _chatbotService = HybridChatbotService.instance;
      
      // Configuration des URLs pour les services locaux
      // Utiliser l'adresse IP de l'ordinateur sur le réseau local
      // pour permettre l'accès depuis un appareil physique
      await _chatbotService.initialize(
        rasaUrl: 'http://192.168.1.97:5005',  // URL Rasa sur le réseau local
        ollamaUrl: 'http://192.168.1.97:11434', // URL Ollama sur le réseau local
        ollamaModel: 'llama3',  // Modèle par défaut
      );
      
      if (!_chatbotService.messages.any((msg) => !msg.isUser)) {
        // Ajouter un message de bienvenue si aucun message du bot n'existe encore
        final welcomeMessage = ChatbotMessage(
          id: 'welcome',
          text: "Bonjour ! Je suis GreenBot, votre assistant écologique. Comment puis-je vous aider aujourd'hui ?",
          isUser: false,
          timestamp: DateTime.now(),
        );
        _chatbotService.clearHistory();
        await _chatbotService.sendMessage("", initialMessage: welcomeMessage);
        if (mounted) setState(() {});
      }
      
      // Vérifier si nous sommes en mode hors ligne et afficher une notification
      if (!_chatbotService.isRasaAvailable && !_chatbotService.isOllamaAvailable) {
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
          text: "Je rencontre des problèmes de connexion avec les services de chatbot (Rasa/Ollama).\n\n"
               "Pour utiliser le chatbot sur un appareil physique :\n\n"
               "1. Assurez-vous que votre téléphone et votre ordinateur sont sur le même réseau WiFi\n"
               "2. Sur votre ordinateur, exécutez :\n"
               "   • Rasa : 'rasa run --enable-api --cors \"*\" --host 0.0.0.0 --port 5005'\n"
               "   • Ollama : 'ollama run llama3'\n\n"
               "3. Vérifiez que les services sont accessibles depuis votre téléphone en visitant http://192.168.1.97:5005 et http://192.168.1.97:11434 dans un navigateur.",
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
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFF1F3140)),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatbotSettingsView(),
                ),
              );
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
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
  
  Widget _buildStatusBar() {
    return AnimatedBuilder(
      animation: _chatbotService,
      builder: (context, child) {
        final isRasaAvailable = _chatbotService.isRasaAvailable;
        final isOllamaAvailable = _chatbotService.isOllamaAvailable;
        
        return Column(
          children: [
            Container(
              color: AppColors.cardColor,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: AppColors.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    'Système: ${isRasaAvailable && isOllamaAvailable ? "Hybride (Rasa + Ollama)" : isRasaAvailable ? "Rasa" : isOllamaAvailable ? "Ollama" : "Hors ligne"}',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                  ),
                  const Spacer(),
                  // Bouton pour tester manuellement la connexion
                  if (!isRasaAvailable || !isOllamaAvailable)
                    TextButton.icon(
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text("Reconnecter", style: TextStyle(fontSize: 12)),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _initChatbotService(),
                    ),
                  if (_chatbotService.isProcessing)
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                      ),
                    ),
                ],
              ),
            ),
            // Ligne d'état de Rasa et Ollama
            Container(
              color: Colors.grey.shade100,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: Row(
                children: [
                  Icon(
                    isRasaAvailable ? Icons.check_circle : Icons.error_outline,
                    size: 14, 
                    color: isRasaAvailable ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Rasa: ${isRasaAvailable ? "Connecté" : "Déconnecté"}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isRasaAvailable ? Colors.green : Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    isOllamaAvailable ? Icons.check_circle : Icons.error_outline,
                    size: 14, 
                    color: isOllamaAvailable ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Ollama: ${isOllamaAvailable ? "Connecté" : "Déconnecté"}',
                    style: TextStyle(
                      fontSize: 11,
                      color: isOllamaAvailable ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
  
  Widget _buildMessageList() {
    final messages = _chatbotService.messages;
    
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppColors.primaryColor.withOpacity(0.3),
            ),
            const SizedBox(height: 16),
            const Text(
              'Commencez la conversation !',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
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
          if (!isUser)
            CircleAvatar(
              backgroundColor: AppColors.secondaryColor,
              radius: 18,
              child: const Icon(Icons.eco, color: Colors.white, size: 18),
            ),
          if (!isUser) const SizedBox(width: 8),
          
          Flexible(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: isUser ? AppColors.primaryColor : AppColors.cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : Colors.black87,
                      fontSize: 15,
                    ),
                  ),
                  
                  // Afficher les suggestions s'il y en a
                  if (!isUser && message.suggestedActions.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 12),
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: message.suggestedActions.map((suggestion) {
                          return GestureDetector(
                            onTap: () {
                              _messageController.text = suggestion;
                              _sendMessage();
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: AppColors.secondaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: AppColors.secondaryColor.withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                suggestion,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: AppColors.secondaryColor,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                ],
              ),
            ),
          ),
          
          if (isUser) const SizedBox(width: 8),
          if (isUser)
            CircleAvatar(
              backgroundColor: Colors.blueGrey.shade300,
              radius: 18,
              child: const Icon(Icons.person, color: Colors.white, size: 18),
            ),
        ],
      ),
    );
  }
  
  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 5,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                hintText: 'Tapez votre message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                prefixIcon: Icon(
                  Icons.chat_bubble_outline,
                  color: AppColors.primaryColor.withOpacity(0.7),
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8),
          AnimatedBuilder(
            animation: _chatbotService,
            builder: (context, child) {
              return FloatingActionButton(
                onPressed: _chatbotService.isProcessing ? null : _sendMessage,
                backgroundColor: AppColors.secondaryColor,
                elevation: 2,
                child: const Icon(Icons.send, color: Colors.white),
              );
            },
          ),
        ],
      ),
    );
  }

  // Afficher un dialogue d'aide
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.help_outline, color: AppColors.primaryColor),
            const SizedBox(width: 8),
            const Text('Guide de configuration'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pour utiliser toutes les fonctionnalités du chatbot :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text('1. Configuration de Rasa sur votre PC :'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'rasa run --enable-api --cors "*" --host 0.0.0.0 --port 5005',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text('2. Configuration d\'Ollama sur votre PC :'),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ollama run llama3',
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '3. Vérifiez que votre téléphone et votre PC sont sur le même réseau WiFi.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Adresses utilisées :',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('• Rasa : http://192.168.1.97:5005'),
              Text('• Ollama : http://192.168.1.97:11434'),
              const SizedBox(height: 16),
              const Text(
                'Note : Sans Rasa et Ollama, le chatbot fonctionnera en mode limité.',
                style: TextStyle(fontStyle: FontStyle.italic, color: Colors.grey),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _initChatbotService(); // Réessayer la connexion
            },
            child: const Text('Reconnecter'),
          ),
        ],
      ),
    );
  }
}
