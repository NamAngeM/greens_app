import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/qa_model.dart';
import '../utils/app_colors.dart';
import '../utils/app_styles.dart';
import '../utils/app_router.dart';
import '../widgets/menu.dart';
import 'package:intl/intl.dart';

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

    // Scroll to bottom after adding user message
    _scrollToBottom();

    // Simuler un délai de réponse
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      // Réponses hardcodées pour les questions courantes
      String response = _getHardcodedResponse(text);

      // Vérifier si le widget est toujours monté
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: response,
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
        });

        // Scroll to bottom after adding bot response
        _scrollToBottom();
      }
    } catch (e) {
      // Gérer l'erreur
      if (mounted) {
        setState(() {
          _messages.add(ChatMessage(
            text: "Désolé, je n'ai pas pu traiter votre demande. Veuillez réessayer.",
            isUser: false,
            timestamp: DateTime.now(),
          ));
          _isTyping = false;
        });
        _scrollToBottom();
      }
      print("Erreur dans le chatbot: $e");
    }
  }

  // Méthode pour obtenir une réponse hardcodée
  String _getHardcodedResponse(String question) {
    // Convertir la question en minuscules pour faciliter la correspondance
    final lowerQuestion = question.toLowerCase();
    
    // Réponses aux questions courantes
    if (lowerQuestion.contains("écologie") || lowerQuestion.contains("ecologie")) {
      return "L'écologie est la science qui étudie les relations des êtres vivants entre eux et avec leur environnement. Dans un sens plus large, c'est aussi un mouvement qui prône la protection de l'environnement et une utilisation durable des ressources naturelles.";
    } 
    else if (lowerQuestion.contains("empreinte carbone") || lowerQuestion.contains("réduire") && lowerQuestion.contains("carbone")) {
      return "Pour réduire votre empreinte carbone, vous pouvez : utiliser les transports en commun ou le vélo plutôt que la voiture, réduire votre consommation de viande, privilégier les produits locaux et de saison, isoler votre logement, et limiter votre consommation d'énergie au quotidien.";
    }
    else if (lowerQuestion.contains("réchauffement") || lowerQuestion.contains("climat")) {
      return "Le réchauffement climatique est l'augmentation de la température moyenne à la surface de la Terre, principalement due aux émissions de gaz à effet de serre produites par les activités humaines comme la combustion de combustibles fossiles et la déforestation.";
    }
    else if (lowerQuestion.contains("eau") || lowerQuestion.contains("économiser l'eau")) {
      return "Pour économiser l'eau, vous pouvez : prendre des douches courtes plutôt que des bains, installer des mousseurs sur vos robinets, récupérer l'eau de pluie pour arroser vos plantes, réparer les fuites rapidement, et utiliser des appareils électroménagers économes en eau.";
    }
    else if (lowerQuestion.contains("zéro déchet") || lowerQuestion.contains("zero dechet")) {
      return "Le zéro déchet est une démarche visant à réduire au maximum sa production de déchets. Cela passe par les 5R : Refuser (ce dont on n'a pas besoin), Réduire (sa consommation), Réutiliser (plutôt que jeter), Recycler, et Redonner à la terre (composter).";
    }
    else if (lowerQuestion.contains("compost") || lowerQuestion.contains("composter")) {
      return "Pour faire du compost, vous avez besoin d'un composteur où vous alternerez des couches de déchets verts (épluchures, marc de café, thé) et de déchets bruns (feuilles mortes, carton). Remuez régulièrement et maintenez une humidité correcte. En quelques mois, vous obtiendrez un compost utilisable pour vos plantes.";
    }
    else if (lowerQuestion.contains("agriculture bio") || lowerQuestion.contains("biologique")) {
      return "L'agriculture biologique est un mode de production qui n'utilise pas de produits chimiques de synthèse (pesticides, engrais) et qui respecte le bien-être animal. Elle vise à préserver les sols, la biodiversité et les ressources naturelles tout en produisant des aliments de qualité.";
    }
    else if (lowerQuestion.contains("plastique") || lowerQuestion.contains("déchets plastiques")) {
      return "Pour réduire les déchets plastiques, utilisez des alternatives réutilisables : sacs en tissu, gourdes, contenants en verre, pailles en inox, etc. Achetez en vrac, évitez les produits suremballés, et recyclez correctement les plastiques que vous ne pouvez pas éviter.";
    }
    else if (lowerQuestion.contains("énergie renouvelable") || lowerQuestion.contains("renouvelables")) {
      return "Les énergies renouvelables sont des sources d'énergie dont le renouvellement naturel est assez rapide pour qu'elles puissent être considérées comme inépuisables à l'échelle humaine. Elles incluent l'énergie solaire, éolienne, hydraulique, géothermique et la biomasse.";
    }
    else if (lowerQuestion.contains("consommation d'énergie") || lowerQuestion.contains("économiser l'énergie")) {
      return "Pour réduire votre consommation d'énergie : éteignez les appareils en veille, utilisez des ampoules LED, isolez votre logement, baissez le chauffage de 1°C, privilégiez les appareils économes (classe A+++), et séchez votre linge à l'air libre plutôt qu'au sèche-linge.";
    }
    else if (lowerQuestion.contains("fast fashion") || lowerQuestion.contains("mode rapide")) {
      return "La fast fashion (mode rapide) est un modèle économique basé sur la production rapide et à bas coût de vêtements, suivant les dernières tendances. Ce système a un impact environnemental désastreux : pollution, consommation d'eau excessive, conditions de travail précaires, et encouragement à la surconsommation.";
    }
    else if (lowerQuestion.contains("mode éthique") || lowerQuestion.contains("vêtements éthiques")) {
      return "Pour adopter une mode plus éthique : achetez moins mais mieux, privilégiez les marques éco-responsables, optez pour la seconde main, réparez vos vêtements, choisissez des matières naturelles et durables, et renseignez-vous sur les conditions de fabrication des vêtements.";
    }
    else if (lowerQuestion.contains("obsolescence") || lowerQuestion.contains("programmée")) {
      return "L'obsolescence programmée est une stratégie visant à réduire délibérément la durée de vie d'un produit pour augmenter son taux de remplacement. Cela peut se faire par des défauts techniques, des incompatibilités logicielles, ou simplement par l'effet de mode.";
    }
    else if (lowerQuestion.contains("numérique") || lowerQuestion.contains("impact environnemental")) {
      return "Pour réduire l'impact du numérique : conservez vos appareils plus longtemps, réparez-les, achetez reconditionné, limitez le streaming vidéo en haute définition, nettoyez régulièrement vos emails, et utilisez le wifi plutôt que la 4G/5G qui consomme plus d'énergie.";
    }
    else if (lowerQuestion.contains("biodiversité") || lowerQuestion.contains("biodiversite")) {
      return "La biodiversité désigne l'ensemble des êtres vivants ainsi que les écosystèmes dans lesquels ils vivent. Elle comprend la diversité des espèces, la diversité génétique au sein de chaque espèce, et la diversité des écosystèmes. C'est un élément essentiel à l'équilibre de notre planète.";
    }
    else if (lowerQuestion.contains("bonjour") || lowerQuestion.contains("salut") || lowerQuestion.contains("hello")) {
      return "Bonjour ! Je suis votre assistant écologique. Comment puis-je vous aider aujourd'hui ?";
    }
    else {
      // Réponse par défaut si aucune correspondance n'est trouvée
      return "Je ne suis pas sûr de comprendre votre question. Pourriez-vous me demander quelque chose sur l'écologie, le développement durable, ou comment réduire votre impact environnemental ?";
    }
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
    final bool keyboardIsOpen = MediaQuery.of(context).viewInsets.bottom > 0;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Contenu principal (90% de l'écran ou 100% si clavier ouvert)
          Expanded(
            child: SafeArea(
              bottom: false,
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
                  
                  // Description du chatbot (masquée si clavier ouvert)
                  if (!keyboardIsOpen)
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
          
          // Menu de navigation (masqué si clavier ouvert)
          if (!keyboardIsOpen)
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
    // Formatter l'heure pour l'affichage (HH:mm)
    final timeFormat = DateFormat('HH:mm', 'fr_FR'); // Assurez-vous d'importer intl
    final formattedTime = timeFormat.format(message.timestamp);

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0), // Réduire les marges horizontales
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end, // Alignement pour l'heure
        children: [
          if (!message.isUser) _buildAvatar(),
          Column(
            crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65, // Réduire la largeur max
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: message.isUser
                      ? AppColors.primaryColor // Vert pour l'utilisateur
                      : AppColors.backgroundColor, // Gris clair pour le bot
                  borderRadius: BorderRadius.circular(16.0),
                ),
                child: Text(
                  message.text,
                  style: TextStyle(
                    color: message.isUser ? Colors.white : Colors.black87,
                    fontSize: 15.0,
                  ),
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                formattedTime,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 10.0,
                ),
              ),
            ],
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