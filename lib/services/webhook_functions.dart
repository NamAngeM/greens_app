import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Classe pour gérer les appels webhook pour le chatbot écologique
class WebhookService {
  static const String _webhookUrl = 'https://votre-fonction-cloud.cloudfunctions.net/ecoWebhook';
  
  /// Traite une requête webhook en fonction de l'intent et des paramètres
  /// Renvoie une réponse formatée pour Dialogflow
  static Future<String> processWebhook(String intentName, Map<String, dynamic> parameters) async {
    try {
      // En production, vous feriez un appel au webhook
      // return await _callWebhook(intentName, parameters);
      
      // Pour développement/test, nous simulons les réponses du webhook
      return _simulateWebhookResponse(intentName, parameters);
    } catch (e) {
      return "Désolé, je n'ai pas pu traiter votre demande avec le webhook. Erreur: $e";
    }
  }
  
  /// Appelle le webhook distant (à utiliser en production)
  static Future<String> _callWebhook(String intentName, Map<String, dynamic> parameters) async {
    try {
      final response = await http.post(
        Uri.parse(_webhookUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'intentName': intentName,
          'parameters': parameters,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['fulfillmentText'] ?? "Aucune réponse du webhook";
      } else {
        throw Exception('Erreur du webhook: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Erreur de communication avec le webhook: $e');
    }
  }
  
  /// Simule des réponses webhook localement pour le développement
  static String _simulateWebhookResponse(String intentName, Map<String, dynamic> parameters) {
    switch (intentName) {
      case 'calcul_empreinte_carbone':
        return _calculateCarbonFootprint(parameters);
      
      case 'eco_conseil_personnalise':
        return _generatePersonalizedEcoAdvice(parameters);
      
      case 'info_recyclage':
        return _getRecyclingInfo(parameters);
        
      case 'evenements_eco':
        return _getEcoEvents(parameters);
        
      case 'alternative_eco':
        return _getSustainableAlternative(parameters);
        
      default:
        return "Je ne peux pas traiter cette demande spécifique pour le moment.";
    }
  }
  
  /// Calcule une empreinte carbone approximative basée sur les paramètres
  static String _calculateCarbonFootprint(Map<String, dynamic> parameters) {
    final activity = parameters['activity'] ?? 'transport';
    final frequency = parameters['frequency'] ?? 'quotidien';
    final duration = parameters['duration'] ?? 0;
    
    String result = '';
    double carbonFootprint = 0;
    
    if (activity == 'transport') {
      final transportType = parameters['transport_type'] ?? 'voiture';
      
      // Calcul simplifié de l'empreinte
      switch (transportType) {
        case 'voiture':
          carbonFootprint = 120.0 * (duration / 60); // g CO2/km
          break;
        case 'bus':
          carbonFootprint = 68.0 * (duration / 60);
          break;
        case 'train':
          carbonFootprint = 14.0 * (duration / 60);
          break;
        case 'avion':
          carbonFootprint = 285.0 * (duration / 60);
          break;
        default:
          carbonFootprint = 0;
      }
      
      result = "Pour votre trajet en $transportType de ${duration.toInt()} minutes, "
          "l'empreinte carbone estimée est de ${carbonFootprint.toStringAsFixed(2)} kg de CO2. ";
      
      // Ajouter des conseils
      if (transportType == 'voiture') {
        result += "Saviez-vous qu'en prenant le train pour ce même trajet, "
            "vous réduiriez votre empreinte carbone de près de 90% ?";
      }
    } else if (activity == 'alimentation') {
      final foodType = parameters['food_type'] ?? 'viande';
      
      switch (foodType) {
        case 'viande':
          carbonFootprint = 13.3;
          break;
        case 'poisson':
          carbonFootprint = 3.9;
          break;
        case 'vegetarien':
          carbonFootprint = 1.7;
          break;
        case 'vegan':
          carbonFootprint = 1.1;
          break;
        default:
          carbonFootprint = 0;
      }
      
      result = "Un repas à base de $foodType génère environ ${carbonFootprint.toStringAsFixed(1)} kg de CO2. "
          "Sur une semaine, cela représente ${(carbonFootprint * 7).toStringAsFixed(1)} kg de CO2.";
    }
    
    return result;
  }
  
  /// Génère un conseil écologique personnalisé
  static String _generatePersonalizedEcoAdvice(Map<String, dynamic> parameters) {
    final domain = parameters['eco_domain'] ?? 'général';
    final level = parameters['expertise_level'] ?? 'débutant';
    
    switch (domain) {
      case 'énergie':
        if (level == 'débutant') {
          return "Pour réduire votre consommation d'énergie, commencez par remplacer vos ampoules par des LED, "
              "qui consomment jusqu'à 90% d'électricité en moins que les ampoules incandescentes et durent 15 fois plus longtemps. "
              "Éteignez également les appareils en veille, qui peuvent représenter jusqu'à 10% de votre facture d'électricité.";
        } else {
          return "Pour optimiser votre consommation énergétique, envisagez d'installer des panneaux solaires "
              "qui pourraient couvrir 30 à 50% de vos besoins. Complétez avec un système de domotique pour gérer intelligemment "
              "le chauffage et l'éclairage, réduisant ainsi votre consommation totale de 15 à 30%. "
              "Vous pourriez également rejoindre une coopérative d'énergie citoyenne locale.";
        }
        
      case 'déchets':
        if (level == 'débutant') {
          return "Pour réduire vos déchets, adoptez les 3R : Réduire, Réutiliser, Recycler. "
              "Commencez par utiliser un sac réutilisable pour vos courses, évitez les produits à usage unique, "
              "et assurez-vous de bien trier vos déchets recyclables. Ces gestes simples peuvent réduire vos déchets de 30%.";
        } else {
          return "Pour une démarche zéro déchet avancée, créez votre compost (même en appartement avec un lombricomposteur), "
              "achetez en vrac avec vos propres contenants, fabriquez vos produits ménagers et d'hygiène. "
              "Vous pouvez également pratiquer l'upcycling pour transformer vos déchets en objets utiles ou décoratifs. "
              "Ces pratiques peuvent réduire vos déchets de plus de 80%.";
        }
        
      case 'eau':
        if (level == 'débutant') {
          return "Pour économiser l'eau, installez des mousseurs sur vos robinets (réduction de 50% du débit), "
              "prenez des douches courtes plutôt que des bains, et réparez rapidement les fuites. "
              "Une simple fuite peut gaspiller jusqu'à 120 litres d'eau par jour !";
        } else {
          return "Pour une gestion avancée de l'eau, installez un système de récupération d'eau de pluie pour arroser votre jardin "
              "ou alimenter vos toilettes. Envisagez également un système de traitement des eaux grises pour réutiliser l'eau "
              "de la douche ou de la machine à laver. Ces systèmes peuvent réduire votre consommation d'eau potable de 40 à 50%.";
        }
        
      default:
        return "Pour commencer votre démarche écologique, concentrez-vous sur un aspect qui vous tient à cœur : "
            "alimentation, transport, énergie, déchets... Fixez-vous des objectifs réalistes et progressifs. "
            "Souvenez-vous que chaque petit geste compte et que l'impact collectif de nos actions individuelles est significatif.";
    }
  }
  
  /// Fournit des informations sur le recyclage d'un matériau spécifique
  static String _getRecyclingInfo(Map<String, dynamic> parameters) {
    final material = parameters['material'] ?? 'plastique';
    
    switch (material) {
      case 'plastique':
        return "Le plastique se recycle différemment selon son type. Recherchez le numéro dans le triangle ♻️ sous l'objet : "
            "Les types 1 (PET) et 2 (HDPE) sont les plus facilement recyclables et vont dans la poubelle jaune. "
            "Les types 3 (PVC) et 6 (PS) sont rarement recyclés. "
            "Important : les bouteilles doivent être vidées mais pas écrasées, et les bouchons vissés dessus.";
        
      case 'verre':
        return "Le verre est recyclable à 100% et indéfiniment sans perdre ses propriétés ! "
            "Déposez bouteilles, pots et bocaux en verre dans les conteneurs à verre, sans les bouchons ni couvercles. "
            "Attention : la vaisselle, les miroirs et les ampoules ne sont pas recyclables avec le verre d'emballage "
            "car ils ont une composition différente.";
        
      case 'papier':
        return "Le papier peut être recyclé jusqu'à 5-7 fois avant que ses fibres ne deviennent trop courtes. "
            "Déposez journaux, magazines, enveloppes et papiers imprimés dans le bac de recyclage. "
            "Évitez les papiers souillés (mouchoirs, essuie-tout), plastifiés ou adhésifs. "
            "Saviez-vous que recycler une tonne de papier permet d'économiser 17 arbres et 20 000 litres d'eau ?";
        
      case 'électronique':
        return "Les déchets électroniques contiennent des matériaux précieux et des substances toxiques. "
            "Ne les jetez jamais avec les ordures ménagères ! Rapportez-les en déchèterie, dans les points de collecte en magasin, "
            "ou donnez-les à des associations qui les reconditionnent. La directive européenne DEEE oblige les vendeurs "
            "à reprendre gratuitement votre ancien appareil lors de l'achat d'un équivalent neuf.";
        
      default:
        return "Pour savoir comment recycler correctement ce matériau, consultez le guide local de tri de votre commune "
            "ou utilisez l'application mobile Guide du Tri de CITEO qui vous donnera les consignes spécifiques pour votre localité.";
    }
  }
  
  /// Trouve des événements écologiques à proximité
  static String _getEcoEvents(Map<String, dynamic> parameters) {
    final location = parameters['location'] ?? 'Paris';
    final date = parameters['date'] ?? DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Dans une vraie implémentation, vous interrogeriez une API ou une base de données
    // Ici, nous simulons la réponse
    
    if (location.contains('Paris')) {
      return "Voici les prochains événements écologiques à Paris :\n"
          "• ${_getNextSaturday()}: Atelier de réparation Repair Café au Ground Control (12e arr.)\n"
          "• ${_getNextSunday()}: Balade urbaine 'Biodiversité en ville' au Parc de Belleville (20e arr.)\n"
          "• ${_getNextTuesday()}: Conférence 'Agriculture urbaine' à La REcyclerie (18e arr.)\n"
          "• ${_getNextWeekend()}: Festival Zéro Déchet à la Halle des Blancs Manteaux (4e arr.)";
    } else if (location.contains('Lyon')) {
      return "Voici les prochains événements écologiques à Lyon :\n"
          "• ${_getNextSaturday()}: Atelier compostage au Jardin partagé des Pentes (1er arr.)\n"
          "• ${_getNextWednesday()}: Projection-débat 'Demain' à la MJC Jean Macé (7e arr.)\n"
          "• ${_getNextWeekend()}: Marché des producteurs locaux Place Carnot (2e arr.)";
    } else {
      return "Je n'ai pas trouvé d'événements écologiques spécifiques pour $location. "
          "Je vous recommande de consulter le site de votre mairie ou les réseaux sociaux des associations "
          "environnementales locales. Vous pouvez également utiliser l'application GreenEvent ou consulter "
          "l'agenda du Réseau Action Climat.";
    }
  }
  
  /// Suggère des alternatives écologiques à des produits
  static String _getSustainableAlternative(Map<String, dynamic> parameters) {
    final product = parameters['product'] ?? 'bouteille plastique';
    
    switch (product) {
      case 'bouteille plastique':
        return "Pour remplacer les bouteilles en plastique, optez pour une gourde réutilisable en inox. "
            "Durable et sans BPA, elle conservera votre eau fraîche plus longtemps. "
            "Une gourde de qualité coûte entre 15€ et 30€, mais s'amortit en quelques mois : "
            "une famille de 4 personnes économise environ 800€ par an en arrêtant l'eau en bouteille.";
        
      case 'sac plastique':
        return "Pour remplacer les sacs plastiques, utilisez des sacs en tissu réutilisables. "
            "Les modèles pliables tiennent facilement dans une poche ou un sac à main. "
            "Pour vos fruits et légumes, privilégiez les sacs à vrac lavables en coton bio. "
            "Un Français utilise en moyenne 80 sacs plastiques par an, alors que votre sac en tissu "
            "peut durer plus de 10 ans !";
        
      case 'cotons démaquillants':
        return "Pour remplacer les cotons démaquillants jetables, adoptez les carrés démaquillants lavables "
            "en coton ou bambou bio. Utilisez-les avec de l'huile végétale ou un savon doux, "
            "puis lavez-les en machine dans un filet à 60°C. Un lot de 10-16 carrés coûte environ 15-20€ "
            "et remplace 1500 cotons jetables par an, pour une économie d'environ 30€ annuels.";
        
      case 'papier aluminium':
        return "Pour remplacer le papier aluminium, utilisez des emballages alimentaires réutilisables "
            "en cire d'abeille. Ces wraps naturels sont respirants, lavables à l'eau froide, "
            "et peuvent être utilisés jusqu'à un an. Vous pouvez aussi opter pour des boîtes en verre "
            "qui passent au four, ou des silicones alimentaires pour la cuisson. "
            "Un pack de 3 wraps différentes tailles coûte environ 15-20€ et permet d'économiser "
            "plusieurs rouleaux d'aluminium par an.";
        
      default:
        return "Pour trouver une alternative écologique à ce produit, demandez conseil dans une boutique "
            "zéro déchet près de chez vous. Ces commerces proposent généralement des solutions durables "
            "et vous aideront à choisir le produit adapté à vos besoins. "
            "Vous pouvez également consulter des sites comme 'ConsomAction' ou 'Slow Déco' "
            "qui référencent des alternatives écoresponsables.";
    }
  }
  
  // Fonctions utilitaires pour formater les dates
  static String _getNextSaturday() {
    return _getNextWeekday(DateTime.saturday);
  }
  
  static String _getNextSunday() {
    return _getNextWeekday(DateTime.sunday);
  }
  
  static String _getNextTuesday() {
    return _getNextWeekday(DateTime.tuesday);
  }
  
  static String _getNextWednesday() {
    return _getNextWeekday(DateTime.wednesday);
  }
  
  static String _getNextWeekend() {
    final nextSaturday = _getNextDateForWeekday(DateTime.saturday);
    return DateFormat('d MMMM', 'fr_FR').format(nextSaturday);
  }
  
  static String _getNextWeekday(int weekday) {
    final date = _getNextDateForWeekday(weekday);
    return DateFormat('d MMMM', 'fr_FR').format(date);
  }
  
  static DateTime _getNextDateForWeekday(int weekday) {
    DateTime date = DateTime.now();
    while (date.weekday != weekday) {
      date = date.add(const Duration(days: 1));
    }
    return date;
  }
} 