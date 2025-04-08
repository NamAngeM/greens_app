// Fichier: lib/services/eco_purchase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/product_model.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/controllers/eco_goal_controller.dart';

class EcoPurchaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final EcoGoalController _ecoGoalController;
  
  EcoPurchaseService(this._ecoGoalController);
  
  // Méthode pour connecter un achat à un objectif écologique
  Future<bool> connectPurchaseToGoal(ProductModel product, String userId) async {
    try {
      // Si le produit n'a pas de type d'objectif associé, on ne peut pas le connecter
      if (product.relatedGoalType == null) return false;
      
      // Trouver les objectifs actifs de l'utilisateur qui correspondent au type du produit
      final matchingGoals = _ecoGoalController.userGoals
          .where((goal) => 
              goal.userId == userId && 
              goal.type == product.relatedGoalType &&
              !goal.isCompleted)
          .toList();
      
      if (matchingGoals.isEmpty) return false;
      
      // Trier les objectifs par date de fin (priorité aux objectifs qui expirent bientôt)
      matchingGoals.sort((a, b) => a.endDate.compareTo(b.endDate));
      
      // Choisir le premier objectif correspondant
      final targetGoal = matchingGoals.first;
      
      // Calculer la contribution à l'objectif (par défaut 1, mais peut être personnalisé)
      int progressContribution = 1;
      
      // Si le produit a un impact environnemental spécifique, on peut l'utiliser
      if (product.environmentalImpact != null) {
        switch (product.relatedGoalType) {
          case GoalType.wasteReduction:
            progressContribution = (product.environmentalImpact!['wasteReduction'] ?? 1).toInt();
            break;
          case GoalType.waterSaving:
            progressContribution = (product.environmentalImpact!['waterSaving'] ?? 1).toInt();
            break;
          case GoalType.energySaving:
            progressContribution = (product.environmentalImpact!['energySaving'] ?? 1).toInt();
            break;
          case GoalType.sustainableShopping:
            progressContribution = 1; // Par défaut pour les achats durables
            break;
          case GoalType.transportation:
            progressContribution = (product.environmentalImpact!['transportationSaving'] ?? 1).toInt();
            break;
          default:
            progressContribution = 1;
        }
      }
      
      // Mettre à jour la progression de l'objectif
      final success = await _ecoGoalController.updateGoalProgress(
        targetGoal.id, 
        progressContribution
      );
      
      if (success) {
        // Enregistrer l'historique de la contribution
        await _firestore.collection('eco_goal_contributions').add({
          'goalId': targetGoal.id,
          'userId': userId,
          'productId': product.id,
          'productName': product.name,
          'contributionAmount': progressContribution,
          'contributionDate': FieldValue.serverTimestamp(),
          'goalType': targetGoal.type.toString().split('.').last,
        });
      }
      
      return success;
    } catch (e) {
      print('Error connecting purchase to goal: $e');
      return false;
    }
  }
  
  // Méthode pour obtenir des suggestions de produits basées sur les objectifs de l'utilisateur
  Future<List<ProductModel>> getSuggestedProductsForGoals(
    String userId, 
    List<ProductModel> availableProducts
  ) async {
    try {
      // Récupérer les objectifs actifs de l'utilisateur
      final activeGoals = _ecoGoalController.getActiveGoals();
      if (activeGoals.isEmpty) return [];
      
      // Extraire les types d'objectifs
      final goalTypes = activeGoals.map((goal) => goal.type).toSet();
      
      // Filtrer les produits qui correspondent aux types d'objectifs
      final suggestedProducts = availableProducts
          .where((product) => 
              product.relatedGoalType != null && 
              goalTypes.contains(product.relatedGoalType))
          .toList();
      
      // Trier par pertinence (points écologiques)
      suggestedProducts.sort((a, b) => b.ecoPoints.compareTo(a.ecoPoints));
      
      return suggestedProducts;
    } catch (e) {
      print('Error getting suggested products: $e');
      return [];
    }
  }
  
  // Méthode pour calculer l'impact environnemental total des achats d'un utilisateur
  Future<Map<String, dynamic>> calculateUserPurchaseImpact(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('eco_goal_contributions')
          .where('userId', isEqualTo: userId)
          .get();
      
      Map<String, dynamic> impact = {
        'wasteReduction': 0,
        'waterSaving': 0,
        'energySaving': 0,
        'sustainableShopping': 0,
        'transportation': 0,
        'totalContributions': 0,
      };
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final goalType = data['goalType'] as String;
        final contribution = data['contributionAmount'] as int;
        
        impact['totalContributions'] = (impact['totalContributions'] as int) + 1;
        
        switch (goalType) {
          case 'wasteReduction':
            impact['wasteReduction'] = (impact['wasteReduction'] as int) + contribution;
            break;
          case 'waterSaving':
            impact['waterSaving'] = (impact['waterSaving'] as int) + contribution;
            break;
          case 'energySaving':
            impact['energySaving'] = (impact['energySaving'] as int) + contribution;
            break;
          case 'sustainableShopping':
            impact['sustainableShopping'] = (impact['sustainableShopping'] as int) + contribution;
            break;
          case 'transportation':
            impact['transportation'] = (impact['transportation'] as int) + contribution;
            break;
        }
      }
      
      return impact;
    } catch (e) {
      print('Error calculating purchase impact: $e');
      return {
        'wasteReduction': 0,
        'waterSaving': 0,
        'energySaving': 0,
        'sustainableShopping': 0,
        'transportation': 0,
        'totalContributions': 0,
      };
    }
  }
}