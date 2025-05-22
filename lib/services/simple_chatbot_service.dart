import 'package:flutter/material.dart';
import 'dart:math';

class SimpleChatbotService extends ChangeNotifier {
  static final SimpleChatbotService instance = SimpleChatbotService._internal();
  final Random _random = Random();
  bool _isInitialized = true; // Toujours initialisé par défaut
  
  SimpleChatbotService._internal();
  
  // Getter pour vérifier si le service est initialisé
  bool get isInitialized => _isInitialized;
  
  // Méthode d'initialisation (ne fait rien mais est nécessaire pour la compatibilité)
  Future<void> initialize() async {
    // Rien à initialiser, mais on garde la méthode pour la compatibilité
    _isInitialized = true;
    return;
  }
  
  // Liste de questions-réponses prédéfinies
  final List<Map<String, String>> _qaDatabase = [
    {
      'question': 'qu\'est-ce que l\'écologie',
      'answer': 'L\'écologie est la science qui étudie les relations des êtres vivants entre eux et avec leur environnement. Dans un sens plus large, c\'est aussi un mouvement qui prône la protection de l\'environnement et une utilisation durable des ressources naturelles.'
    },
    {
      'question': 'comment réduire mon empreinte carbone',
      'answer': 'Pour réduire votre empreinte carbone, vous pouvez : utiliser les transports en commun ou le vélo plutôt que la voiture, réduire votre consommation de viande, privilégier les produits locaux et de saison, isoler votre logement, et limiter votre consommation d\'énergie au quotidien.'
    },
    {
      'question': 'qu\'est-ce que le réchauffement climatique',
      'answer': 'Le réchauffement climatique est l\'augmentation de la température moyenne à la surface de la Terre, principalement due aux émissions de gaz à effet de serre produites par les activités humaines comme la combustion de combustibles fossiles et la déforestation.'
    },
    {
      'question': 'comment économiser l\'eau',
      'answer': 'Pour économiser l\'eau, vous pouvez : prendre des douches courtes plutôt que des bains, installer des mousseurs sur vos robinets, récupérer l\'eau de pluie pour arroser vos plantes, réparer les fuites rapidement, et utiliser des appareils électroménagers économes en eau.'
    },
    {
      'question': 'qu\'est-ce que le zéro déchet',
      'answer': 'Le zéro déchet est une démarche visant à réduire au maximum sa production de déchets. Cela passe par les 5R : Refuser (ce dont on n\'a pas besoin), Réduire (sa consommation), Réutiliser (plutôt que jeter), Recycler, et Redonner à la terre (composter).'
    },
    {
      'question': 'comment faire du compost',
      'answer': 'Pour faire du compost, vous avez besoin d\'un composteur où vous alternerez des couches de déchets verts (épluchures, marc de café, thé) et de déchets bruns (feuilles mortes, carton). Remuez régulièrement et maintenez une humidité correcte. En quelques mois, vous obtiendrez un compost utilisable pour vos plantes.'
    },
    {
      'question': 'qu\'est-ce que l\'agriculture biologique',
      'answer': 'L\'agriculture biologique est un mode de production qui n\'utilise pas de produits chimiques de synthèse (pesticides, engrais) et qui respecte le bien-être animal. Elle vise à préserver les sols, la biodiversité et les ressources naturelles tout en produisant des aliments de qualité.'
    },
    {
      'question': 'comment réduire les déchets plastiques',
      'answer': 'Pour réduire les déchets plastiques, utilisez des alternatives réutilisables : sacs en tissu, gourdes, contenants en verre, pailles en inox, etc. Achetez en vrac, évitez les produits suremballés, et recyclez correctement les plastiques que vous ne pouvez pas éviter.'
    },
    {
      'question': 'qu\'est-ce que l\'énergie renouvelable',
      'answer': 'Les énergies renouvelables sont des sources d\'énergie dont le renouvellement naturel est assez rapide pour qu\'elles puissent être considérées comme inépuisables à l\'échelle humaine. Elles incluent l\'énergie solaire, éolienne, hydraulique, géothermique et la biomasse.'
    },
    {
      'question': 'comment réduire sa consommation d\'énergie',
      'answer': 'Pour réduire votre consommation d\'énergie : éteignez les appareils en veille, utilisez des ampoules LED, isolez votre logement, baissez le chauffage de 1°C, privilégiez les appareils économes (classe A+++), et séchez votre linge à l\'air libre plutôt qu\'au sèche-linge.'
    },
    {
      'question': 'qu\'est-ce que la fast fashion',
      'answer': 'La fast fashion (mode rapide) est un modèle économique basé sur la production rapide et à bas coût de vêtements, suivant les dernières tendances. Ce système a un impact environnemental désastreux : pollution, consommation d\'eau excessive, conditions de travail précaires, et encouragement à la surconsommation.'
    },
    {
      'question': 'comment adopter une mode éthique',
      'answer': 'Pour adopter une mode plus éthique : achetez moins mais mieux, privilégiez les marques éco-responsables, optez pour la seconde main, réparez vos vêtements, choisissez des matières naturelles et durables, et renseignez-vous sur les conditions de fabrication des vêtements.'
    },
    {
      'question': 'qu\'est-ce que l\'obsolescence programmée',
      'answer': 'L\'obsolescence programmée est une stratégie visant à réduire délibérément la durée de vie d\'un produit pour augmenter son taux de remplacement. Cela peut se faire par des défauts techniques, des incompatibilités logicielles, ou simplement par l\'effet de mode.'
    },
    {
      'question': 'comment réduire l\'impact environnemental du numérique',
      'answer': 'Pour réduire l\'impact du numérique : conservez vos appareils plus longtemps, réparez-les, achetez reconditionné, limitez le streaming vidéo en haute définition, nettoyez régulièrement vos emails, et utilisez le wifi plutôt que la 4G/5G qui consomme plus d\'énergie.'
    },
    {
      'question': 'qu\'est-ce que la biodiversité',
      'answer': 'La biodiversité désigne l\'ensemble des êtres vivants ainsi que les écosystèmes dans lesquels ils vivent. Elle comprend la diversité des espèces, la diversité génétique au sein de chaque espèce, et la diversité des écosystèmes. C\'est un élément essentiel à l\'équilibre de notre planète.'
    },
    {
      'question': 'comment protéger la biodiversité',
      'answer': 'Pour protéger la biodiversité : créez un jardin favorable aux insectes et oiseaux, évitez les pesticides, soutenez l\'agriculture biologique, limitez votre consommation de viande, privilégiez les produits respectueux des forêts (label FSC), et soutenez les associations de protection de la nature.'
    }
  ];
  
  // Réponses génériques pour les questions sans correspondance
  final List<String> _fallbackResponses = [
    "Je ne suis pas sûr de comprendre votre question. Pourriez-vous la reformuler ?",
    "Je n'ai pas d'information précise sur ce sujet. Avez-vous une autre question sur l'écologie ?",
    "Cette question dépasse mes connaissances actuelles. Je peux vous aider sur des sujets comme la réduction des déchets, les économies d'énergie ou la consommation responsable.",
    "Je ne peux pas répondre à cette question. Essayez de me demander comment réduire votre empreinte carbone ou économiser l'eau par exemple.",
  ];
  
  // Méthode pour obtenir une réponse à une question
  Future<String> getResponse(String question) async {
    try {
      // Normaliser la question (minuscules, sans ponctuation)
      final normalizedQuestion = question.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
      
      print("Question normalisée: '$normalizedQuestion'");
      
      // Chercher une correspondance dans la base de données
      for (var qa in _qaDatabase) {
        final dbQuestion = qa['question']!.toLowerCase();
        if (normalizedQuestion.contains(dbQuestion) || 
            _isQuestionSimilar(normalizedQuestion, dbQuestion)) {
          print("Correspondance trouvée avec: '$dbQuestion'");
          return qa['answer']!;
        }
      }
      
      print("Aucune correspondance trouvée, utilisation d'une réponse générique");
      // Si aucune correspondance n'est trouvée, retourner une réponse générique
      return _getFallbackResponse();
    } catch (e) {
      print("Erreur dans getResponse: $e");
      return "Je suis désolé, une erreur s'est produite. Pourriez-vous reformuler votre question ?";
    }
  }
  
  // Méthode pour vérifier si deux questions sont similaires
  bool _isQuestionSimilar(String userQuestion, String dbQuestion) {
    try {
      // Liste de mots-clés importants dans la question de la base de données
      final keywords = dbQuestion.split(' ')
          .where((word) => word.length > 3)
          .toList();
      
      if (keywords.isEmpty) return false;
      
      // Compter combien de mots-clés sont présents dans la question de l'utilisateur
      int matchCount = 0;
      for (var keyword in keywords) {
        if (userQuestion.contains(keyword)) {
          matchCount++;
          print("Mot-clé correspondant: '$keyword'");
        }
      }
      
      // Si plus de la moitié des mots-clés correspondent, considérer les questions comme similaires
      final result = matchCount >= keywords.length / 2;
      print("Similarité: $matchCount/${keywords.length} mots-clés correspondent, résultat: $result");
      return result;
    } catch (e) {
      print("Erreur dans _isQuestionSimilar: $e");
      return false;
    }
  }
  
  // Méthode pour obtenir une réponse générique aléatoire
  String _getFallbackResponse() {
    return _fallbackResponses[_random.nextInt(_fallbackResponses.length)];
  }
}
