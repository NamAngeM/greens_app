import 'package:flutter/material.dart';
import 'package:greens_app/services/chatbot_service.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/models/unified_product_model.dart';
import 'package:greens_app/models/eco_challenge_model.dart';
import 'package:greens_app/services/eco_content_integration_service.dart';

/// Service qui enrichit le chatbot pour en faire un guide transversal
/// à travers toutes les fonctionnalités de l'application
class EcoAssistantService {
  final ChatbotService _chatbotService;
  final EcoContentIntegrationService _contentService;
  
  // Singleton
  static final EcoAssistantService _instance = 
      EcoAssistantService._internal(
        ChatbotService(),
        EcoContentIntegrationService(),
      );
  
  factory EcoAssistantService() {
    return _instance;
  }
  
  EcoAssistantService._internal(this._chatbotService, this._contentService);
  
  /// Actions personnalisées pour naviguer dans l'application
  final Map<String, String> _navigationActions = {
    'empreinte_carbone': AppRoutes.carbonDashboard,
    'calculateur': AppRoutes.carbonCalculator,
    'objectifs': AppRoutes.goals,
    'defis': AppRoutes.challenges,
    'scanner': AppRoutes.productScanner,
    'achats': AppRoutes.products,
    'articles': AppRoutes.articles,
    'communaute': AppRoutes.community,
    'profil': AppRoutes.profile,
  };

  /// Extraire des actions contextualistes pour le chatbot à partir d'un message
  List<ChatbotAction> extractContextualActions(String message) {
    final List<ChatbotAction> actions = [];
    final String lowercaseMessage = message.toLowerCase();
    
    // Vérifier si le message concerne des actions de navigation
    for (final entry in _navigationActions.entries) {
      final keyword = entry.key;
      final route = entry.value;
      
      if (lowercaseMessage.contains(keyword)) {
        actions.add(
          ChatbotAction(
            type: ChatbotActionType.navigate,
            title: 'Aller vers ${_getReadableRouteName(route)}',
            data: {'route': route},
          ),
        );
      }
    }
    
    // Vérifier les intentions liées aux produits
    if (_containsProductIntent(lowercaseMessage)) {
      actions.add(
        ChatbotAction(
          type: ChatbotActionType.scanProduct,
          title: 'Scanner un produit',
          data: {},
        ),
      );
      
      actions.add(
        ChatbotAction(
          type: ChatbotActionType.showProducts,
          title: 'Voir les produits recommandés',
          data: {},
        ),
      );
    }
    
    // Vérifier les intentions liées aux défis
    if (_containsChallengeIntent(lowercaseMessage)) {
      actions.add(
        ChatbotAction(
          type: ChatbotActionType.navigate,
          title: 'Voir les défis écologiques',
          data: {'route': AppRoutes.challenges},
        ),
      );
    }
    
    // Vérifier les intentions liées à l'empreinte carbone
    if (_containsCarbonIntent(lowercaseMessage)) {
      actions.add(
        ChatbotAction(
          type: ChatbotActionType.calculateFootprint,
          title: 'Calculer mon empreinte carbone',
          data: {},
        ),
      );
      
      actions.add(
        ChatbotAction(
          type: ChatbotActionType.navigate,
          title: 'Voir mon tableau de bord carbone',
          data: {'route': AppRoutes.carbonDashboard},
        ),
      );
    }
    
    return actions;
  }
  
  /// Vérifier si un message contient des intentions liées aux produits
  bool _containsProductIntent(String message) {
    final productKeywords = [
      'produit', 'acheter', 'scanner', 'achat', 'écologique', 'achats', 
      'shopping', 'article', 'marque', 'verte', 'durable', 'alternatives'
    ];
    
    return productKeywords.any((keyword) => message.contains(keyword));
  }
  
  /// Vérifier si un message contient des intentions liées aux défis
  bool _containsChallengeIntent(String message) {
    final challengeKeywords = [
      'défi', 'challenge', 'objectif', 'mission', 'tâche', 'eco-défi',
      'accomplir', 'compléter', 'réaliser', 'participer'
    ];
    
    return challengeKeywords.any((keyword) => message.contains(keyword));
  }
  
  /// Vérifier si un message contient des intentions liées à l'empreinte carbone
  bool _containsCarbonIntent(String message) {
    final carbonKeywords = [
      'carbone', 'co2', 'empreinte', 'impact', 'environnement', 'climat',
      'pollution', 'écologique', 'émission', 'gaz', 'effet de serre'
    ];
    
    return carbonKeywords.any((keyword) => message.contains(keyword));
  }
  
  /// Obtenir un nom lisible pour une route
  String _getReadableRouteName(String route) {
    switch (route) {
      case AppRoutes.carbonDashboard:
        return 'Tableau de bord carbone';
      case AppRoutes.carbonCalculator:
        return 'Calculateur d\'empreinte';
      case AppRoutes.goals:
        return 'Objectifs écologiques';
      case AppRoutes.challenges:
        return 'Défis écologiques';
      case AppRoutes.productScanner:
        return 'Scanner de produits';
      case AppRoutes.products:
        return 'Produits écologiques';
      case AppRoutes.articles:
        return 'Articles et actus';
      case AppRoutes.community:
        return 'Communauté éco';
      case AppRoutes.profile:
        return 'Profil';
      default:
        return 'cette section';
    }
  }
  
  /// Générer une introduction contextuelle basée sur la section actuelle
  String generateContextualIntroduction(String currentRoute) {
    switch (currentRoute) {
      case AppRoutes.carbonDashboard:
        return 'Je vois que vous consultez votre tableau de bord carbone. Je peux vous aider à comprendre vos données ou vous suggérer des actions pour réduire votre empreinte. Que souhaitez-vous savoir ?';
        
      case AppRoutes.carbonCalculator:
        return 'Vous utilisez le calculateur d\'empreinte carbone. Je peux vous accompagner pendant le processus et vous expliquer l\'impact de vos habitudes. Comment puis-je vous aider ?';
        
      case AppRoutes.goals:
        return 'Bienvenue dans vos objectifs écologiques ! Je peux vous suggérer de nouveaux objectifs adaptés à votre profil ou vous aider à progresser sur ceux en cours. Que puis-je faire pour vous ?';
        
      case AppRoutes.challenges:
        return 'Vous explorez les défis écologiques ! Je peux vous recommander des défis qui correspondent à vos intérêts ou vous aider à accomplir ceux que vous avez déjà acceptés. Que cherchez-vous ?';
        
      case AppRoutes.productScanner:
        return 'Prêt à scanner un produit ? Je vous donnerai des informations détaillées sur son impact environnemental et des alternatives plus écologiques si besoin. Comment puis-je vous aider ?';
        
      case AppRoutes.products:
        return 'Vous êtes sur la page des produits écologiques. Je peux vous aider à trouver des articles spécifiques ou vous recommander des produits adaptés à vos objectifs actuels. Que recherchez-vous ?';
        
      case AppRoutes.articles:
        return 'Vous consultez notre section articles. Je peux vous suggérer des lectures basées sur vos centres d\'intérêt ou répondre à vos questions sur le contenu. Qu\'aimeriez-vous découvrir ?';
        
      case AppRoutes.community:
        return 'Bienvenue dans l\'espace communautaire ! Je peux vous aider à trouver des défis collaboratifs ou vous connecter avec d\'autres utilisateurs partageant vos valeurs. Comment puis-je vous être utile ?';
        
      default:
        return 'Bonjour ! Je suis votre assistant écologique. Je peux vous aider à naviguer dans l\'application, vous donner des conseils personnalisés ou répondre à vos questions. N\'hésitez pas à me demander de l\'aide.';
    }
  }
  
  /// Obtenir des recommandations de produits contextualisées
  Future<List<UnifiedProduct>> getContextualProductRecommendations(String userId, String context) async {
    if (_containsCarbonIntent(context.toLowerCase())) {
      // Recommandations basées sur l'empreinte carbone
      final featuredContent = await _contentService.getFeaturedContentForUser(userId);
      final products = featuredContent['products'] as List<UnifiedProduct>;
      
      // Filtrer les produits pertinents pour la réduction de l'empreinte carbone
      return products.where((product) => 
        product.ecoTags.any((tag) => 
          ['carbon_reducing', 'eco_friendly', 'sustainable'].contains(tag)
        )
      ).toList();
    } else if (_containsChallengeIntent(context.toLowerCase())) {
      // Recommandations basées sur les défis actifs
      final featuredContent = await _contentService.getFeaturedContentForUser(userId);
      final challenges = featuredContent['challenges'] as List<EcoChallenge>;
      
      if (challenges.isNotEmpty) {
        // Obtenir des produits pour le premier défi
        return await _contentService.getProductsForChallenge(challenges.first);
      }
    }
    
    // Par défaut, retourner les produits en vedette
    final featuredContent = await _contentService.getFeaturedContentForUser(userId);
    return featuredContent['products'] as List<UnifiedProduct>;
  }
  
  /// Gérer les actions spéciales du chatbot
  Future<void> handleChatbotAction(ChatbotAction action, BuildContext context, String userId) async {
    switch (action.type) {
      case ChatbotActionType.navigate:
        // Navigation vers une autre page
        final route = action.data['route'] as String;
        Navigator.pushNamed(context, route);
        break;
      
      case ChatbotActionType.calculateFootprint:
        // Rediriger vers le calculateur d'empreinte carbone
        Navigator.pushNamed(context, AppRoutes.carbonCalculator);
        break;
      
      case ChatbotActionType.showProducts:
        // Afficher des produits recommandés
        final products = await getContextualProductRecommendations(
          userId, 
          action.title,
        );
        
        // Rediriger vers la page produits avec les recommandations
        Navigator.pushNamed(
          context, 
          AppRoutes.products,
          arguments: {'recommended_products': products},
        );
        break;
      
      case ChatbotActionType.scanProduct:
        // Rediriger vers le scanner de produits
        Navigator.pushNamed(context, AppRoutes.productScanner);
        break;
      
      default:
        // Laisser le service ChatbotService gérer les autres types d'actions
        await _chatbotService.processAction(action, context, userId);
    }
  }
  
  /// Générer des conseils personnalisés basés sur le profil utilisateur et ses activités récentes
  Future<String> generatePersonalizedTip(String userId) async {
    // Liste de conseils génériques
    const List<String> genericTips = [
      "Saviez-vous que remplacer une journée de viande par des protéines végétales réduit votre empreinte carbone de 4kg de CO2 ?",
      "Pensez à éteindre complètement vos appareils électroniques plutôt que de les laisser en veille pour économiser jusqu'à 10% d'énergie.",
      "Une gourde réutilisable peut remplacer jusqu'à 167 bouteilles en plastique par an !",
      "Prenez des douches plus courtes : réduire de 2 minutes votre temps sous la douche peut économiser 38 litres d'eau.",
      "Faire sécher votre linge à l'air libre plutôt qu'au sèche-linge peut réduire votre empreinte carbone de 2.6 kg de CO2 par charge.",
    ];
    
    // Récupérer le contenu en vedette pour cet utilisateur
    final featuredContent = await _contentService.getFeaturedContentForUser(userId);
    final challenges = featuredContent['challenges'] as List<EcoChallenge>? ?? [];
    
    // Si l'utilisateur a des défis actifs, générer un conseil basé sur un défi
    if (challenges.isNotEmpty) {
      final challenge = challenges.first;
      return "Pour progresser dans votre défi \"${challenge.title}\", essayez ceci : "
          "${challenge.tips.isNotEmpty ? challenge.tips.first : 'Fixez-vous un petit objectif quotidien pour rester motivé.'}";
    }
    
    // Sinon, retourner un conseil générique
    final random = DateTime.now().millisecondsSinceEpoch % genericTips.length;
    return genericTips[random];
  }
} 