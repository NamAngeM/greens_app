import 'package:flutter/material.dart';
import 'package:greens_app/services/eco_dialogflow_service.dart';

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

/// Vue du chatbot écologique qui utilise Dialogflow
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

  @override
  void initState() {
    super.initState();
    _initializeService();
    // Ajouter un message de bienvenue
    _addBotMessage("Bonjour ! Je suis votre assistant écologique. Comment puis-je vous aider aujourd'hui ?");
  }

  /// Initialiser le service Dialogflow
  Future<void> _initializeService() async {
    setState(() => _isLoading = true);
    try {
      await EcoDialogflowService.initialize();
      setState(() => _isInitialized = true);
    } catch (e) {
      print('Erreur lors de l\'initialisation du service: $e');
      _addBotMessage("Je fonctionne actuellement en mode hors ligne avec des réponses limitées.");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  /// Ajouter un message de l'utilisateur
  void _addUserMessage(String message) {
    if (message.trim().isEmpty) return;
    
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    
    _textController.clear();
    _scrollToBottom();
    
    // Envoyer la question et obtenir une réponse
    _getResponse(message);
  }

  /// Ajouter un message du bot
  void _addBotMessage(String message) {
    setState(() {
      _messages.add(ChatMessage(
        text: message,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    
    _scrollToBottom();
  }

  /// Obtenir une réponse à une question
  Future<void> _getResponse(String question) async {
    setState(() => _isLoading = true);
    
    try {
      if (_isInitialized) {
        final response = await EcoDialogflowService.instance.getEcoResponse(question);
        _addBotMessage(response);
      } else {
        // En mode hors-ligne ou non initialisé
        _addBotMessage(_getFallbackResponse(question));
      }
    } catch (e) {
      print('Erreur lors de l\'obtention de la réponse: $e');
      _addBotMessage("Désolé, je n'ai pas pu traiter votre demande. Pouvez-vous reformuler ou essayer autre chose ?");
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  /// Fournir une réponse de secours locale quand Dialogflow n'est pas disponible
  String _getFallbackResponse(String question) {
    final q = question.toLowerCase();
    final List<String> fallbackResponses = [
      "Pour réduire votre empreinte écologique, essayez de limiter votre consommation de produits à usage unique.",
      "Le recyclage est un excellent moyen de contribuer à la protection de l'environnement.",
      "Économiser l'eau est crucial pour la préservation des ressources naturelles.",
      "Les transports en commun et le covoiturage sont des alternatives écologiques à la voiture individuelle.",
      "Privilégiez les produits locaux et de saison pour réduire l'impact environnemental de votre alimentation.",
      "L'énergie solaire et éolienne sont des sources d'énergie renouvelables qui contribuent à la réduction des émissions de CO2.",
      "Réduire sa consommation de viande a un impact positif significatif sur l'environnement.",
      "Les déchets plastiques sont particulièrement nocifs pour les écosystèmes marins."
    ];
    
    // Recherche simple par mots-clés
    if (q.contains('plastique') || q.contains('déchet')) {
      return "Pour réduire vos déchets plastiques, pensez à utiliser des alternatives réutilisables comme les sacs en tissu, les gourdes et les pailles en métal ou bambou.";
    } else if (q.contains('eau')) {
      return "Pour économiser l'eau au quotidien, prenez des douches courtes, installez des économiseurs d'eau sur vos robinets, et récupérez l'eau de pluie pour vos plantes.";
    } else if (q.contains('énergie') || q.contains('électricité')) {
      return "Pour réduire votre consommation d'énergie, éteignez les appareils en veille, utilisez des ampoules LED, et privilégiez les appareils électroménagers économes (classe A+++).";
    } else if (q.contains('transport') || q.contains('voiture')) {
      return "Pour des déplacements plus écologiques, privilégiez la marche ou le vélo pour les courts trajets, les transports en commun ou le covoiturage pour les plus longs.";
    } else if (q.contains('aliment') || q.contains('manger') || q.contains('nourriture')) {
      return "Pour une alimentation plus durable, privilégiez les produits locaux et de saison, réduisez votre consommation de viande, et limitez le gaspillage alimentaire.";
    } else {
      // Réponse générique aléatoire
      return fallbackResponses[DateTime.now().millisecondsSinceEpoch % fallbackResponses.length];
    }
  }

  /// Faire défiler la liste jusqu'en bas
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
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assistant Écologique'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('À propos'),
                  content: const Text(
                    'Cet assistant écologique vous aide à trouver des informations '
                    'sur les pratiques durables et écologiques. Posez des questions '
                    'sur le recyclage, la réduction des déchets, l\'économie d\'énergie, etc.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('OK'),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? const Center(
                    child: Text(
                      'Posez une question sur l\'écologie ou le développement durable',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(8.0),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      final message = _messages[index];
                      return _buildMessageItem(message);
                    },
                  ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(
                backgroundColor: Colors.green,
              ),
            ),
          _buildInputArea(),
        ],
      ),
    );
  }

  /// Construire un élément de message
  Widget _buildMessageItem(ChatMessage message) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
        padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 14.0),
        decoration: BoxDecoration(
          color: message.isUser ? Colors.green.shade200 : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12.0),
        ),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 4.0),
            Text(
              '${message.timestamp.hour}:${message.timestamp.minute.toString().padLeft(2, '0')}',
              style: TextStyle(
                fontSize: 12.0,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Construire la zone de saisie
  Widget _buildInputArea() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              decoration: InputDecoration(
                hintText: 'Posez une question sur l\'écologie...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24.0),
                  borderSide: BorderSide.none,
                ),
                filled: true,
                fillColor: Colors.grey.shade200,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 10.0,
                ),
              ),
              textInputAction: TextInputAction.send,
              onSubmitted: (value) => _addUserMessage(value),
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: () => _addUserMessage(_textController.text),
            backgroundColor: Colors.green,
            mini: true,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
} 