import 'package:greens_app/models/product_unified.dart';
import 'package:greens_app/models/article_model.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/models/community_challenge_model.dart';

/// Service pour fournir des données mock (test) à l'application
/// Centralise toutes les données de test pour éviter la duplication
class MockDataService {
  // Singleton pattern
  static final MockDataService _instance = MockDataService._internal();
  factory MockDataService() => _instance;
  MockDataService._internal();

  /// Retourne une liste de produits écologiques fictifs
  List<UnifiedProduct> getEcoFriendlyProducts() {
    return [
      UnifiedProduct(
        id: 'product-1',
        name: 'Amoseeds',
        description: 'Mélange de graines bio pour petit-déjeuner nutritif',
        price: 12.99,
        imageUrl: 'assets/images/products/amoseeds.png',
        categories: ['Alimentation'],
        isEcoFriendly: true,
        brand: 'Amoseeds',
        ecoRating: 4.5,
        certifications: ['Bio', 'Commerce équitable'],
        ecoCriteria: {'packaging': 'recyclable', 'sourcing': 'local'},
      ),
      UnifiedProduct(
        id: 'product-2',
        name: 'June Shine',
        description: 'Kombucha alcoolisé aux fruits',
        price: 9.50,
        imageUrl: 'assets/images/products/june_shine.png',
        categories: ['Boissons'],
        isEcoFriendly: true,
        brand: 'June Shine',
        ecoRating: 4.0,
        certifications: ['Bio', 'Artisanal'],
        ecoCriteria: {'ingredients': 'bio', 'packaging': 'recyclable'},
      ),
      UnifiedProduct(
        id: 'product-3',
        name: 'Jen\'s Sorbet',
        description: 'Sorbet vegan aux fruits rouges',
        price: 6.99,
        imageUrl: 'assets/images/products/sorbet.png',
        categories: ['Alimentation'],
        isEcoFriendly: true,
        brand: 'Jen\'s',
        ecoRating: 3.8,
        certifications: ['Vegan'],
        ecoCriteria: {'ingredients': 'bio', 'energy': 'optimized'},
      ),
      UnifiedProduct(
        id: 'product-4',
        name: 'Gourde écologique',
        description: 'Gourde réutilisable en acier inoxydable',
        price: 19.99,
        imageUrl: 'assets/images/products/botle.png',
        categories: ['Accessoires'],
        isEcoFriendly: true,
        brand: 'GreenMinds',
        ecoRating: 4.0,
        certifications: ['Sans BPA'],
        ecoCriteria: {'durability': 'high', 'material': 'sustainable'},
      ),
      UnifiedProduct(
        id: 'product-5',
        name: 'Allbirds',
        description: 'Baskets écologiques en laine mérinos',
        price: 95.00,
        imageUrl: 'assets/images/products/allbirds.png',
        categories: ['Mode'],
        isEcoFriendly: true,
        brand: 'Allbirds',
        ecoRating: 4.8,
        certifications: ['B Corp', 'Carbon Neutral'],
        ecoCriteria: {'material': 'natural', 'labor': 'ethical'},
      ),
      UnifiedProduct(
        id: 'product-6',
        name: 'Organic Basics',
        description: 'Sous-vêtements en coton bio durable',
        price: 39.00,
        imageUrl: 'assets/images/products/organic_basics.png',
        categories: ['Mode'],
        isEcoFriendly: true,
        brand: 'Organic Basics',
        ecoRating: 4.5,
        certifications: ['GOTS', 'Commerce équitable'],
        ecoCriteria: {'material': 'organic', 'labor': 'ethical'},
      ),
    ];
  }

  /// Retourne une liste d'articles fictifs
  List<ArticleModel> getRecentArticles() {
    return [
      ArticleModel(
        id: 'test-article-1',
        title: 'Comment réduire votre empreinte carbone à la maison',
        content: '''Faire de petits changements dans vos habitudes quotidiennes peut réduire considérablement votre empreinte carbone. Commencez par passer aux ampoules LED, réduire la consommation d'eau et composter les déchets alimentaires.''',
        imageUrl: 'https://images.unsplash.com/photo-1518531933037-91b2f5f229cc?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        categories: ['Développement durable', 'Maison'],
        readTimeMinutes: 4,
        publishDate: DateTime.now().subtract(const Duration(days: 2)),
        authorName: 'Emma Green',
      ),
      ArticleModel(
        id: 'test-article-2',
        title: 'Les avantages de passer aux énergies renouvelables',
        content: '''Les sources d'énergie renouvelable comme l'énergie solaire et éolienne peuvent aider à réduire les émissions de gaz à effet de serre et à lutter contre le changement climatique. Découvrez comment vous pouvez faire la transition dans votre maison.''',
        imageUrl: 'https://images.unsplash.com/photo-1508514177221-188c53300491?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        categories: ['Énergie', 'Développement durable'],
        readTimeMinutes: 5,
        publishDate: DateTime.now().subtract(const Duration(days: 5)),
        authorName: 'Michael Sun',
      ),
      ArticleModel(
        id: 'test-article-3',
        title: 'La mode durable : au-delà des tendances',
        content: '''La mode rapide a un impact environnemental significatif. Découvrez comment construire une garde-robe durable qui est à la fois élégante et respectueuse de l'environnement.''',
        imageUrl: 'https://images.unsplash.com/photo-1556905055-8f358a7a47b2?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        categories: ['Mode', 'Développement durable'],
        readTimeMinutes: 6,
        publishDate: DateTime.now().subtract(const Duration(days: 7)),
        authorName: 'Sophia Styles',
      ),
    ];
  }

  /// Retourne une liste d'objectifs écologiques fictifs
  List<EcoGoalModel> getUserEcoGoals(String userId) {
    return [
      EcoGoalModel(
        id: 'goal-1',
        title: 'Réduire ma consommation de plastique',
        description: 'Éviter les produits à usage unique et privilégier les alternatives durables',
        userId: userId,
        targetDate: DateTime.now().add(const Duration(days: 30)),
        progress: 0.65,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        category: 'Réduction des déchets',
        steps: [
          'Acheter une gourde réutilisable',
          'Utiliser des sacs en tissu pour faire les courses',
          'Éviter les pailles en plastique',
        ],
      ),
      EcoGoalModel(
        id: 'goal-2',
        title: 'Manger plus local et saisonnier',
        description: 'Privilégier les produits locaux et de saison pour réduire mon empreinte carbone',
        userId: userId,
        targetDate: DateTime.now().add(const Duration(days: 60)),
        progress: 0.3,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        category: 'Alimentation',
        steps: [
          'S\'abonner à un panier bio local',
          'Visiter le marché fermier une fois par semaine',
          'Apprendre quels fruits et légumes sont de saison',
        ],
      ),
    ];
  }

  /// Retourne une liste de défis communautaires fictifs
  List<CommunityChallengeModel> getUserChallenges(String userId) {
    return [
      CommunityChallengeModel(
        id: 'challenge-1',
        title: 'Zéro déchet pendant une semaine',
        description: 'Essayez de ne produire aucun déchet non-recyclable pendant 7 jours',
        startDate: DateTime.now().subtract(const Duration(days: 3)),
        endDate: DateTime.now().add(const Duration(days: 4)),
        participants: [userId, 'user123', 'user456'],
        creatorId: 'admin',
        category: 'Zéro déchet',
        difficulty: 'Intermédiaire',
        steps: [
          'Préparer des contenants réutilisables',
          'Planifier ses repas pour éviter le gaspillage',
          'Utiliser des alternatives durables aux produits jetables',
        ],
        completedBy: ['user123'],
      ),
      CommunityChallengeModel(
        id: 'challenge-2',
        title: 'Transport écologique',
        description: 'Utilisez uniquement des modes de transport écologiques pendant 10 jours',
        startDate: DateTime.now().subtract(const Duration(days: 5)),
        endDate: DateTime.now().add(const Duration(days: 5)),
        participants: [userId, 'user789'],
        creatorId: 'admin',
        category: 'Mobilité',
        difficulty: 'Facile',
        steps: [
          'Privilégier la marche pour les courtes distances',
          'Utiliser le vélo ou les transports en commun',
          'Organiser du covoiturage',
        ],
        completedBy: [],
      ),
    ];
  }
} 