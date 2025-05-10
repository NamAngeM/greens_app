import 'package:flutter/material.dart';
import 'package:greens_app/services/chatbot_service.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:greens_app/utils/app_router.dart';

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
  int _currentIndex = 4; // Index pour la page chatbot
  
  // Suggestions de questions pour l'utilisateur
  List<String> _suggestions = [];
  
  // Indicateur pour montrer si le chatbot a détecté une action écologique
  bool _actionDetected = false;
  String _detectedAction = "";
  
  // Contrôleur d'animation pour les suggestions
  late AnimationController _suggestionsAnimationController;
  late Animation<double> _suggestionsAnimation;

  @override
  void initState() {
    super.initState();
    _initializeService();
    
    // Initialiser le contrôleur d'animation
    _suggestionsAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    
    _suggestionsAnimation = CurvedAnimation(
      parent: _suggestionsAnimationController,
      curve: Curves.easeInOut,
    );
    
    // Ajouter un message de bienvenue
    _addBotMessage("Bonjour ! Je suis votre assistant écologique. Comment puis-je vous aider aujourd'hui ?");
    
    // Charger les suggestions initiales
    _loadSuggestions();
  }
  
  /// Charger les suggestions de questions
  Future<void> _loadSuggestions() async {
    if (_chatbotService.isInitialized) {
      final suggestions = await _chatbotService.getSuggestions();
      setState(() {
        _suggestions = suggestions;
        _suggestionsAnimationController.forward();
      });
    }
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
      _actionDetected = false;
      _detectedAction = "";
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
      
      print("Envoi de la question au service n8n: $question");
      print("Contexte envoyé: ${context.map((m) => '${m['isUser'] ? 'User' : 'Bot'}: ${m['text']}').join('\n')}");
      
      final response = await _chatbotService.getResponse(question, context: context);
      print("Réponse reçue du service n8n: $response");
      
      if (response.isEmpty) {
        _addBotMessage("Désolé, je n'ai pas pu obtenir de réponse. Veuillez réessayer.");
      } else {
        _addBotMessage(response);
        
        // Analyser la réponse pour détecter des actions écologiques
        _detectEcoAction(question, response);
      }
      
      // Mettre à jour les suggestions après chaque échange
      _loadSuggestions();
    } catch (e) {
      print("Erreur lors de l'envoi du message: $e");
      _addBotMessage("Désolé, une erreur s'est produite lors de la communication avec le service: $e");
      
      // Tenter de réinitialiser la connexion après une erreur
      if (!_isInitialized) {
        _initializeService().then((_) {
          if (_isInitialized) {
            _addBotMessage("La connexion a été rétablie. Vous pouvez réessayer votre question.");
          }
        });
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }
  
  /// Détecter si l'utilisateur mentionne une action écologique
  void _detectEcoAction(String question, String response) {
    // Liste de mots-clés liés aux actions écologiques
    final List<String> ecoKeywords = [
      'recyclé', 'économisé', 'réduit', 'planté', 'composté', 
      'réutilisé', 'marché', 'vélo', 'transport', 'énergie'
    ];
    
    // Vérifier si la question contient des mots-clés
    bool containsKeyword = ecoKeywords.any((keyword) => 
      question.toLowerCase().contains(keyword));
    
    if (containsKeyword) {
      setState(() {
        _actionDetected = true;
        _detectedAction = "Il semble que vous ayez mentionné une action écologique. Voulez-vous l'ajouter à vos objectifs ?";
      });
    }
  }
  
  /// Ajouter l'action détectée aux objectifs écologiques
  void _addToEcoGoals() {
    // Cette fonction serait implémentée pour ajouter l'action aux objectifs
    // Elle pourrait appeler un service EcoGoalService par exemple
    setState(() {
      _actionDetected = false;
      _addBotMessage("Super ! J'ai ajouté cette action à vos objectifs écologiques.");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.eco,
              color: Color(0xFF4CAF50),
              size: 24,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                "Assistant Écologique",
                style: const TextStyle(
                  color: Color(0xFF1F3140),
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        actions: [
          // Indicateur de statut
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Icon(
                  _isInitialized ? Icons.check_circle : Icons.error,
                  color: _isInitialized ? Color(0xFF4CAF50) : Colors.red,
                  size: 16,
                ),
                const SizedBox(width: 4),
                Text(
                  _connectionStatus,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF1F3140),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages
          Expanded(
            child: _messages.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return _buildMessageBubble(_messages[index]);
                    },
                  ),
          ),
          
          // Bannière d'action écologique détectée
          if (_actionDetected)
            Container(
              padding: const EdgeInsets.all(12.0),
              margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.eco, color: Colors.green.shade700, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _detectedAction,
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _actionDetected = false;
                          });
                        },
                        child: const Text("Non merci"),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: _addToEcoGoals,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green.shade600,
                          foregroundColor: Colors.white,
                        ),
                        child: const Text("Ajouter"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          
          // Suggestions de questions
          AnimatedBuilder(
            animation: _suggestionsAnimation,
            builder: (context, child) {
              return SizeTransition(
                sizeFactor: _suggestionsAnimation,
                child: Container(
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _suggestions.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4.0),
                        child: InkWell(
                          onTap: () {
                            _textController.text = _suggestions[index];
                            _handleSubmit();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _suggestions[index],
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              );
            },
          ),
          
          // Barre de saisie
          Container(
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
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide(
                          color: Colors.grey.shade300,
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide(
                          color: Color(0xFF4CAF50),
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      fillColor: Colors.grey.shade50,
                      filled: true,
                    ),
                    onSubmitted: (_) => _handleSubmit(),
                  ),
                ),
                const SizedBox(width: 8.0),
                FloatingActionButton(
                  onPressed: _handleSubmit,
                  backgroundColor: Color(0xFF4CAF50),
                  child: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomMenu(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index != _currentIndex) {
            switch (index) {
              case 0: // Home
                Navigator.pushReplacementNamed(context, AppRoutes.home);
                break;
              case 1: // Articles
                Navigator.pushReplacementNamed(context, AppRoutes.articles);
                break;
              case 2: // Products
                Navigator.pushReplacementNamed(context, AppRoutes.products);
                break;
              case 3: // Profile
                Navigator.pushReplacementNamed(context, AppRoutes.profile);
                break;
            }
          }
        },
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
              backgroundColor: Color(0xFF4CAF50),
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
                    ? Color(0xFF4CAF50)
                    : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(16.0),
              ),
              child: Text(
                message.text,
                style: TextStyle(
                  color: message.isUser ? Colors.white : Color(0xFF1F3140),
                ),
              ),
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8.0),
            CircleAvatar(
              backgroundColor: Colors.blue.shade700,
              child: const Icon(
                Icons.person,
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Construire l'état vide (quand il n'y a pas de messages)
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.eco,
            size: 64,
            color: Colors.green.shade200,
          ),
          const SizedBox(height: 16),
          Text(
            "Discutez avec notre assistant écologique",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Posez des questions sur l'écologie, le développement durable\nou comment réduire votre empreinte carbone",
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    _suggestionsAnimationController.dispose();
    super.dispose();
  }
}