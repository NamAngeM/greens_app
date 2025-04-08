// File: lib/services/eco_purchase_integration_service.dart
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:greens_app/models/cart_item_model.dart';
import 'package:greens_app/controllers/eco_goal_controller.dart';
import 'package:greens_app/services/eco_impact_service.dart';

/// Service pour intégrer les achats de produits avec les objectifs écologiques
class EcoPurchaseIntegrationService {
  final EcoGoalController _goalController;
  final EcoImpactService _impactService;
  
  EcoPurchaseIntegrationService(this._goalController, this._impactService);
  
  /// Suggère des produits basés sur les objectifs écologiques actifs de l'utilisateur
  List<ProductModel> suggestProductsForGoals(List<ProductModel> allProducts, List<EcoGoal> activeGoals) {
    if (activeGoals.isEmpty) return allProducts;
    
    // Filtrer les produits pertinents pour les objectifs actifs
    final suggestedProducts = <ProductModel>[];
    
    for (final goal in activeGoals) {
      final relevantProducts = _findRelevantProducts(allProducts, goal.type);
      suggestedProducts.addAll(relevantProducts);
    }
    
    // Éliminer les doublons
    return suggestedProducts.toSet().toList();
  }
  
  /// Trouve les produits pertinents pour un type d'objectif spécifique
  List<ProductModel> _findRelevantProducts(List<ProductModel> products, GoalType goalType) {
    switch (goalType) {
      case GoalType.water:
        return products.where((p) => 
          p.tags.contains('water_saving') || 
          p.description.toLowerCase().contains('eau') ||
          p.description.toLowerCase().contains('water')
        ).toList();
      
      case GoalType.energy:
        return products.where((p) => 
          p.tags.contains('energy_efficient') || 
          p.description.toLowerCase().contains('énergie') ||
          p.description.toLowerCase().contains('energy')
        ).toList();
      
      case GoalType.waste:
        return products.where((p) => 
          p.tags.contains('zero_waste') || 
          p.tags.contains('compostable') ||
          p.description.toLowerCase().contains('déchet') ||
          p.description.toLowerCase().contains('waste')
        ).toList();
      
      case GoalType.transport:
        return products.where((p) => 
          p.tags.contains('sustainable_transport') ||
          p.description.toLowerCase().contains('transport')
        ).toList();
      
      case GoalType.food:
        return products.where((p) => 
          p.tags.contains('organic') || 
          p.tags.contains('local') ||
          p.description.toLowerCase().contains('bio') ||
          p.description.toLowerCase().contains('local')
        ).toList();
      
      default:
        return products.where((p) => 
          p.tags.contains('eco_friendly') ||
          p.tags.contains('sustainable')
        ).toList();
    }
  }
  
  /// Met à jour les progrès des objectifs écologiques basés sur les achats
  Future<void> updateGoalsFromPurchase(String userId, List<CartItemModel> purchasedItems) async {
    // Récupérer les objectifs actifs de l'utilisateur
    final activeGoals = await _goalController.getUserGoals(userId);
    
    for (final item in purchasedItems) {
      final product = item.product;
      final quantity = item.quantity;
      
      // Identifier les objectifs pertinents pour ce produit
      for (final goal in activeGoals) {
        if (_isProductRelevantForGoal(product, goal.type)) {
          // Calculer l'impact écologique de cet achat
          final impact = _calculateProductImpact(product, goal.type) * quantity;
          
          // Mettre à jour le progrès de l'objectif
          await _goalController.updateGoalProgress(goal.id, impact.toInt());
        }
      }
    }
  }
  
  /// Vérifie si un produit est pertinent pour un type d'objectif
  bool _isProductRelevantForGoal(ProductModel product, GoalType goalType) {
    switch (goalType) {
      case GoalType.water:
        return product.tags.contains('water_saving');
      case GoalType.energy:
        return product.tags.contains('energy_efficient');
      case GoalType.waste:
        return product.tags.contains('zero_waste') || product.tags.contains('compostable');
      case GoalType.transport:
        return product.tags.contains('sustainable_transport');
      case GoalType.food:
        return product.tags.contains('organic') || product.tags.contains('local');
      default:
        return product.tags.contains('eco_friendly');
    }
  }
  
  /// Calcule l'impact écologique d'un produit pour un type d'objectif
  double _calculateProductImpact(ProductModel product, GoalType goalType) {
    // Valeurs d'impact par défaut par type d'objectif
    const Map<GoalType, double> defaultImpacts = {
      GoalType.water: 5.0,     // 5 litres économisés
      GoalType.energy: 2.0,    // 2 kWh économisés
      GoalType.waste: 0.5,     // 0.5 kg de déchets évités
      GoalType.transport: 1.0, // 1 km en transport durable
      GoalType.food: 1.0,      // 1 repas durable
      GoalType.community: 1.0, // 1 action communautaire
      GoalType.other: 1.0,     // 1 action générique
    };
    
    // Si le produit a un impact spécifique défini, l'utiliser
    if (product.ecoImpact != null && product.ecoImpact!.containsKey(goalType.toString())) {
      return product.ecoImpact![goalType.toString()];
    }
    
    // Sinon, utiliser la valeur par défaut
    return defaultImpacts[goalType] ?? 1.0;
  }
}