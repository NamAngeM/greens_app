import 'package:flutter/material.dart';
import '../services/local_chatbot_service.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({Key? key}) : super(key: key);

  @override
  _ChatWidgetState createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  final TextEditingController _messageController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final LocalChatbotService _chatbotService = LocalChatbotService.instance;
  bool _isLoading = false;
  bool _isInitialized = false;
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _initializeChatbot();
  }

  Future<void> _initializeChatbot() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _chatbotService.initialize();
      setState(() {
        _isInitialized = true;
        _isLoading = false;
      });

      // Ajouter le message de bienvenue du service
      if (_chatbotService.messages.isNotEmpty) {
        final welcomeMessage = _chatbotService.messages.last;
        _addBotMessage(welcomeMessage.text);
      } else {
        _addBotMessage("Bonjour ! Je suis votre assistant écologique. Je peux vous aider avec des questions sur :\n"
            "- La réduction de l'empreinte carbone\n"
            "- La gestion des déchets plastiques\n"
            "- L'économie d'eau\n"
            "N'hésitez pas à me poser vos questions !");
      }
    } catch (e) {
      setState(() {
        _isInitialized = false;
        _isLoading = false;
      });
      _addBotMessage("Je suis désolé, je rencontre des difficultés techniques. Veuillez réessayer plus tard. Erreur: $e");
    }
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: false));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            reverse: true,
            itemCount: _messages.length + (_isLoading ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == 0 && _isLoading) {
                return _buildLoadingMessage();
              }
              final message = _messages[index - (_isLoading ? 1 : 0)];
              return _buildMessageBubble(message);
            },
          ),
        ),
        if (_suggestions.isNotEmpty) _buildSuggestions(),
        _buildMessageInput(),
      ],
    );
  }

  Widget _buildLoadingMessage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(20.0),
            ),
            child: const Text(
              '...',
              style: TextStyle(color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    // Définir les couleurs pour chaque catégorie
    final Map<String, Color> categoryColors = {
      'transport': Color(0xFFE3F2FD),
      'dechets': Color(0xFFFFF8E1),
      'eau': Color(0xFFE1F5FE),
      'alimentation': Color(0xFFE8F5E9),
      'numerique': Color(0xFFF3E5F5),
      'energie': Color(0xFFFFF3E0),
      'mode': Color(0xFFFCE4EC),
      'consommation': Color(0xFFE0F2F1),
    };
    
    // Définir les couleurs pour chaque catégorie (version foncée pour le texte et les icônes)
    final Map<String, Color> categoryDarkColors = {
      'transport': Color(0xFF1976D2),
      'dechets': Color(0xFFFFA000),
      'eau': Color(0xFF03A9F4),
      'alimentation': Color(0xFF4CAF50),
      'numerique': Color(0xFF9C27B0),
      'energie': Color(0xFFFF9800),
      'mode': Color(0xFFE91E63),
      'consommation': Color(0xFF009688),
    };
    
    // Déterminer la catégorie à partir du contenu du message
    String? category;
    if (!message.isUser) {
      for (var cat in categoryColors.keys) {
        if (message.text.toLowerCase().contains('($cat)') || 
            message.text.toLowerCase().contains('catégorie: $cat') ||
            message.text.toLowerCase().contains('sur $cat')) {
          category = cat;
          break;
        }
      }
    }
    
    // Couleur par défaut si aucune catégorie n'est détectée
    final Color bubbleColor = message.isUser
        ? Color(0xFF4CAF50)
        : category != null
            ? categoryColors[category]!
            : Colors.grey[100]!;
    
    final Color textColor = message.isUser
        ? Colors.white
        : category != null
            ? categoryDarkColors[category]!
            : Color(0xFF1F3140);
    
    // Icône à afficher en fonction de la catégorie
    IconData? categoryIcon;
    if (category != null) {
      switch (category) {
        case 'transport':
          categoryIcon = Icons.directions_bike;
          break;
        case 'dechets':
          categoryIcon = Icons.delete_outline;
          break;
        case 'eau':
          categoryIcon = Icons.water_drop_outlined;
          break;
        case 'alimentation':
          categoryIcon = Icons.restaurant_outlined;
          break;
        case 'numerique':
          categoryIcon = Icons.devices_outlined;
          break;
        case 'energie':
          categoryIcon = Icons.bolt_outlined;
          break;
        case 'mode':
          categoryIcon = Icons.checkroom_outlined;
          break;
        case 'consommation':
          categoryIcon = Icons.shopping_bag_outlined;
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        mainAxisAlignment: message.isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser && categoryIcon != null)
            Container(
              margin: const EdgeInsets.only(right: 8.0, top: 8.0),
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: category != null ? categoryDarkColors[category]! : Color(0xFF4CAF50),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(categoryIcon, size: 16, color: Colors.white),
            ),
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: bubbleColor,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      color: message.isUser ? Colors.white : Color(0xFF1F3140),
                      fontSize: 14,
                    ),
                  ),
                  if (!message.isUser && category != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            categoryIcon,
                            size: 12,
                            color: categoryDarkColors[category],
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Catégorie: $category',
                            style: TextStyle(
                              color: categoryDarkColors[category],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSuggestions() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _suggestions.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: InkWell(
              onTap: () => _handleSubmitted(_suggestions[index]),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(16.0),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Text(
                  _suggestions[index],
                  style: TextStyle(color: Colors.green.shade800),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Tapez votre message...',
                border: OutlineInputBorder(),
              ),
              onSubmitted: _handleSubmitted,
              enabled: !_isLoading,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.send),
            onPressed: _isLoading ? null : () => _handleSubmitted(_messageController.text),
          ),
        ],
      ),
    );
  }

  void _handleSubmitted(String text) async {
    if (text.trim().isEmpty || _isLoading) return;

    setState(() {
      _messages.insert(0, ChatMessage(text: text, isUser: true));
      _isLoading = true;
      _suggestions = []; // Effacer les suggestions pendant le chargement
    });

    _messageController.clear();

    try {
      final response = await _chatbotService.sendMessage(text);
      
      // Mettre à jour les suggestions après avoir reçu la réponse
      final newSuggestions = _chatbotService.getSuggestedQuestions(null);
      
      setState(() {
        _messages.insert(0, ChatMessage(
          text: response?.toString() ?? "Désolé, je n'ai pas compris votre question.",
          isUser: false,
          timestamp: DateTime.now(),
        ));
        _isLoading = false;
        _suggestions = newSuggestions;
      });
    } catch (e) {
      setState(() {
        _messages.insert(
          0,
          ChatMessage(
            text: "Désolé, une erreur s'est produite: $e",
            isUser: false,
          ),
        );
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime? timestamp;

  ChatMessage({required this.text, required this.isUser, this.timestamp});
}