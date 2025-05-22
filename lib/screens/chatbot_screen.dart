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
    else if (lowerQuestion.contains("empreinte carbone") || (lowerQuestion.contains("réduire") && lowerQuestion.contains("carbone"))) {
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
    // Nouvelles questions-réponses
    else if (lowerQuestion.contains("voiture électrique") || lowerQuestion.contains("véhicule électrique")) {
      return "Les voitures électriques produisent moins d'émissions de CO2 lors de leur utilisation que les véhicules à essence ou diesel. Cependant, leur fabrication, notamment celle des batteries, a un impact environnemental important. Pour maximiser leur bénéfice écologique, il est préférable de les recharger avec de l'électricité d'origine renouvelable et de les utiliser le plus longtemps possible.";
    }
    else if (lowerQuestion.contains("alimentation durable") || lowerQuestion.contains("manger écologique")) {
      return "Pour une alimentation plus durable : privilégiez les produits locaux et de saison, réduisez votre consommation de viande et de produits animaux, choisissez des aliments issus de l'agriculture biologique, limitez les emballages, et évitez le gaspillage alimentaire en planifiant vos repas et en conservant correctement vos aliments.";
    }
    else if (lowerQuestion.contains("gaspillage alimentaire") || lowerQuestion.contains("déchets alimentaires")) {
      return "Pour réduire le gaspillage alimentaire : planifiez vos repas et vos courses, vérifiez les dates de péremption, stockez correctement vos aliments, apprenez à cuisiner les restes, compostez les déchets organiques, et n'hésitez pas à congeler ce que vous ne consommerez pas immédiatement.";
    }
    else if (lowerQuestion.contains("pollution air") || lowerQuestion.contains("qualité air")) {
      return "La pollution de l'air est causée par divers polluants comme les particules fines, l'ozone, les oxydes d'azote et le dioxyde de soufre. Pour améliorer la qualité de l'air, il faut réduire l'utilisation des combustibles fossiles, limiter les déplacements en voiture, éviter de brûler des déchets, et privilégier les transports en commun ou le vélo.";
    }
    else if (lowerQuestion.contains("pollution eau") || lowerQuestion.contains("pollution marine")) {
      return "La pollution de l'eau est causée par les rejets industriels, les pesticides, les engrais, les médicaments et les déchets plastiques. Pour la réduire, utilisez des produits ménagers écologiques, évitez de jeter des médicaments dans les toilettes, réduisez votre consommation de plastique, et soutenez les initiatives de nettoyage des cours d'eau et des plages.";
    }
    else if (lowerQuestion.contains("jardinage écologique") || lowerQuestion.contains("jardin bio")) {
      return "Pour un jardinage écologique : n'utilisez pas de pesticides chimiques, favorisez la biodiversité en plantant des espèces locales, récupérez l'eau de pluie, pratiquez le paillage pour limiter l'arrosage, compostez vos déchets verts, et créez des abris pour les insectes auxiliaires comme les coccinelles.";
    }
    else if (lowerQuestion.contains("transport écologique") || lowerQuestion.contains("mobilité durable")) {
      return "Les transports écologiques incluent la marche, le vélo, les transports en commun, le covoiturage et les véhicules électriques. Pour réduire l'impact de vos déplacements, privilégiez les modes actifs pour les courtes distances, combinez différents modes de transport, et limitez les voyages en avion qui sont très émetteurs de CO2.";
    }
    else if (lowerQuestion.contains("isolation maison") || lowerQuestion.contains("économie chauffage")) {
      return "Une bonne isolation permet de réduire considérablement votre consommation d'énergie. Isolez en priorité le toit (30% des pertes), puis les murs (25%) et les fenêtres (13%). Utilisez des matériaux écologiques comme la laine de bois, la ouate de cellulose ou le liège. Pensez aussi à installer des rideaux épais et à calfeutrer les portes et fenêtres.";
    }
    else if (lowerQuestion.contains("éco-construction") || lowerQuestion.contains("maison écologique")) {
      return "L'éco-construction vise à créer des bâtiments respectueux de l'environnement. Elle utilise des matériaux naturels et locaux (bois, terre, paille), privilégie une bonne orientation pour profiter de l'énergie solaire, intègre une isolation performante, et peut inclure des systèmes comme la récupération d'eau de pluie ou les panneaux solaires.";
    }
    else if (lowerQuestion.contains("panneaux solaires") || lowerQuestion.contains("énergie solaire")) {
      return "Les panneaux solaires photovoltaïques transforment la lumière du soleil en électricité. Ils permettent de produire une énergie renouvelable et de réduire sa facture d'électricité. Leur installation nécessite un investissement initial, mais des aides financières existent. Leur rentabilité dépend de l'ensoleillement de votre région et de l'orientation de votre toit.";
    }
    else if (lowerQuestion.contains("éolienne") || lowerQuestion.contains("énergie éolienne")) {
      return "L'énergie éolienne est produite par des turbines qui convertissent l'énergie cinétique du vent en électricité. C'est une source d'énergie renouvelable qui ne produit pas de gaz à effet de serre lors de son fonctionnement. Les petites éoliennes domestiques sont possibles mais leur rentabilité est souvent limitée en zone urbaine où les vents sont irréguliers.";
    }
    else if (lowerQuestion.contains("géothermie") || lowerQuestion.contains("pompe à chaleur")) {
      return "La géothermie utilise la chaleur du sol pour chauffer ou climatiser les bâtiments. Les pompes à chaleur géothermiques sont très efficaces énergétiquement et peuvent réduire considérablement les factures de chauffage. Leur installation nécessite des travaux importants mais des aides financières existent pour encourager cette solution écologique.";
    }
    else if (lowerQuestion.contains("biomasse") || lowerQuestion.contains("chauffage bois")) {
      return "La biomasse désigne la matière organique utilisée comme source d'énergie, principalement le bois. Le chauffage au bois est considéré comme neutre en CO2 si le bois provient de forêts gérées durablement. Pour limiter la pollution de l'air, privilégiez les appareils modernes à haut rendement (poêles à granulés, chaudières à condensation) et utilisez du bois sec.";
    }
    else if (lowerQuestion.contains("label écologique") || lowerQuestion.contains("écolabel")) {
      return "Les labels écologiques garantissent qu'un produit respecte certains critères environnementaux. Les plus fiables sont l'Écolabel Européen, l'Écolabel Nordique, l'Ange Bleu (Allemagne) et l'Agriculture Biologique. Méfiez-vous du greenwashing : certains logos verts n'ont aucune valeur officielle et sont créés par les marques elles-mêmes.";
    }
    else if (lowerQuestion.contains("greenwashing") || lowerQuestion.contains("écoblanchiment")) {
      return "Le greenwashing (ou écoblanchiment) est une pratique marketing qui consiste à donner une image écologique trompeuse à un produit ou une entreprise. Pour l'éviter, méfiez-vous des allégations vagues ('respectueux de l'environnement'), recherchez des labels officiels, et renseignez-vous sur les pratiques réelles des entreprises au-delà de leur communication.";
    }
    else if (lowerQuestion.contains("permaculture") || lowerQuestion.contains("agroécologie")) {
      return "La permaculture est une méthode de conception de systèmes agricoles durables qui s'inspire des écosystèmes naturels. Elle repose sur trois principes éthiques : prendre soin de la Terre, prendre soin de l'humain, et partager équitablement les ressources. Elle intègre la biodiversité, optimise les interactions entre les éléments, et minimise les déchets et l'énergie nécessaire.";
    }
    // Nouvelles questions-réponses supplémentaires
    else if (lowerQuestion.contains("économie circulaire") || lowerQuestion.contains("circularité")) {
      return "L'économie circulaire est un modèle économique qui vise à produire des biens et services de manière durable, en limitant la consommation et le gaspillage de ressources. Elle repose sur l'éco-conception, la réutilisation, la réparation, le recyclage et la valorisation des déchets. Contrairement à l'économie linéaire (extraire, fabriquer, jeter), elle forme une boucle où les déchets deviennent des ressources.";
    }
    else if (lowerQuestion.contains("impact environnemental") || lowerQuestion.contains("empreinte écologique")) {
      return "L'impact environnemental mesure les effets d'une activité humaine sur l'environnement. L'empreinte écologique calcule la surface terrestre nécessaire pour soutenir notre mode de vie. Actuellement, l'humanité consomme l'équivalent de 1,7 planète par an. Pour réduire votre impact, privilégiez les produits locaux, limitez votre consommation de viande, économisez l'énergie et l'eau, et réduisez vos déchets.";
    }
    else if (lowerQuestion.contains("végétarisme") || lowerQuestion.contains("végétalisme") || lowerQuestion.contains("véganisme")) {
      return "Le végétarisme exclut la viande et le poisson mais conserve les produits animaux comme les œufs et les produits laitiers. Le végétalisme exclut tous les produits d'origine animale. Le véganisme est un mode de vie qui refuse toute exploitation animale (alimentation, vêtements, loisirs). Ces régimes réduisent l'impact environnemental de l'alimentation, la production animale étant responsable de 14,5% des émissions de gaz à effet de serre.";
    }
    else if (lowerQuestion.contains("produits ménagers") || lowerQuestion.contains("nettoyants écologiques")) {
      return "Pour un ménage écologique, utilisez des produits naturels comme le vinaigre blanc (détartrant, désinfectant), le bicarbonate de soude (nettoyant, désodorisant), le savon noir (nettoyant multi-usage) et le citron (dégraissant, désodorisant). Vous pouvez aussi fabriquer vos produits ménagers vous-même ou choisir des produits commerciaux avec des écolabels officiels.";
    }
    else if (lowerQuestion.contains("slow fashion") || lowerQuestion.contains("mode durable")) {
      return "La slow fashion (mode lente) s'oppose à la fast fashion en privilégiant des vêtements de qualité, durables et éthiques. Pour l'adopter : achetez moins mais mieux, choisissez des matières naturelles et durables (coton bio, lin, chanvre), privilégiez les marques transparentes sur leurs conditions de production, entretenez bien vos vêtements, et donnez-leur une seconde vie (don, revente, upcycling).";
    }
    else if (lowerQuestion.contains("microplastiques") || lowerQuestion.contains("micro-plastiques")) {
      return "Les microplastiques sont des particules plastiques de moins de 5 mm qui polluent les océans, les sols et l'air. Ils proviennent de la dégradation des déchets plastiques et de sources directes comme les cosmétiques, les vêtements synthétiques ou les pneus. Pour limiter leur dispersion, évitez les produits contenant des microbilles, préférez les textiles naturels, et utilisez des filtres à microplastiques pour votre machine à laver.";
    }
    else if (lowerQuestion.contains("cosmétiques naturels") || lowerQuestion.contains("beauté écologique")) {
      return "Les cosmétiques naturels utilisent des ingrédients d'origine naturelle plutôt que des composés synthétiques. Pour une routine beauté écologique : choisissez des produits avec des labels bio reconnus, limitez le nombre de produits, privilégiez les formules solides et les contenants rechargeables, et essayez les recettes maison (masque à l'argile, huile de coco comme démaquillant, etc.).";
    }
    else if (lowerQuestion.contains("minimalisme") || lowerQuestion.contains("simplicité volontaire")) {
      return "Le minimalisme ou la simplicité volontaire est un mode de vie qui consiste à réduire ses possessions et sa consommation pour se concentrer sur l'essentiel. Cette démarche a des bénéfices écologiques (moins de ressources consommées), économiques (moins de dépenses) et psychologiques (moins de stress, plus de liberté). Pour commencer, désencombrez votre espace et questionnez chaque nouvel achat.";
    }
    else if (lowerQuestion.contains("tourisme durable") || lowerQuestion.contains("écotourisme")) {
      return "Le tourisme durable vise à minimiser l'impact environnemental et maximiser les bénéfices pour les communautés locales. Pour voyager de manière plus responsable : privilégiez les destinations proches et les transports peu polluants, séjournez dans des hébergements éco-responsables, respectez la nature et la culture locale, consommez local, et limitez votre consommation d'eau et d'énergie pendant votre séjour.";
    }
    else if (lowerQuestion.contains("low-tech") || lowerQuestion.contains("basse technologie")) {
      return "Les low-tech sont des technologies simples, durables, accessibles et réparables, qui répondent à nos besoins essentiels avec un minimum de ressources et d'impact environnemental. Exemples : fours solaires, toilettes sèches, systèmes de récupération d'eau de pluie. Contrairement aux high-tech, elles privilégient la sobriété, l'autonomie et la résilience plutôt que la performance et la complexité.";
    }
    else if (lowerQuestion.contains("déchets électroniques") || lowerQuestion.contains("e-déchets")) {
      return "Les déchets électroniques (e-déchets) sont les équipements électriques et électroniques en fin de vie. Ils contiennent des substances toxiques et des métaux précieux. Pour les gérer de manière responsable : prolongez la durée de vie de vos appareils, réparez-les, donnez-les ou vendez-les s'ils fonctionnent encore, et déposez-les dans des points de collecte spécifiques pour qu'ils soient correctement recyclés.";
    }
    else if (lowerQuestion.contains("finance verte") || lowerQuestion.contains("investissement responsable")) {
      return "La finance verte désigne les investissements qui soutiennent des projets respectueux de l'environnement. Pour investir de manière responsable : choisissez des banques éthiques qui ne financent pas les énergies fossiles, optez pour des fonds ISR (Investissement Socialement Responsable), investissez dans des obligations vertes, ou participez au financement participatif de projets écologiques.";
    }
    else if (lowerQuestion.contains("justice environnementale") || lowerQuestion.contains("justice climatique")) {
      return "La justice environnementale vise à répartir équitablement les bénéfices environnementaux et les fardeaux de la pollution. La justice climatique reconnaît que les populations les plus vulnérables et les moins responsables du changement climatique en subissent souvent les pires conséquences. Ces mouvements militent pour que les politiques environnementales prennent en compte les inégalités sociales et économiques.";
    }
    else if (lowerQuestion.contains("sobriété numérique") || lowerQuestion.contains("numérique responsable")) {
      return "La sobriété numérique vise à réduire l'impact environnemental des technologies numériques. Conseils pratiques : conservez vos appareils plus longtemps, privilégiez le reconditionné, désactivez les fonctions inutiles, réduisez le streaming vidéo en haute définition, limitez l'envoi de pièces jointes volumineuses, nettoyez régulièrement vos emails et stockages cloud, et éteignez vos appareils quand vous ne les utilisez pas.";
    }
    else if (lowerQuestion.contains("bonjour") || lowerQuestion.contains("salut") || lowerQuestion.contains("hello")) {
      return "Bonjour ! Je suis votre assistant écologique. Comment puis-je vous aider aujourd'hui ?";
    }
    else if (lowerQuestion.contains("merci") || lowerQuestion.contains("au revoir") || lowerQuestion.contains("a plus")) {
      return "Je vous en prie ! N'hésitez pas à revenir si vous avez d'autres questions sur l'écologie ou le développement durable. À bientôt !";
    }
    else if (lowerQuestion.contains("comment vas-tu") || lowerQuestion.contains("ça va") || lowerQuestion.contains("comment ça va")) {
      return "Je vais très bien, merci ! Je suis toujours heureux de pouvoir aider sur des questions liées à l'écologie et au développement durable. Comment puis-je vous aider aujourd'hui ?";
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