import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:greens_app/models/reward_model.dart';
import 'package:greens_app/models/user_model.dart';
import 'package:greens_app/services/auth_service.dart';

class RewardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Méthode pour récupérer toutes les récompenses disponibles
  Future<List<RewardModel>> getAvailableRewards() async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      final snapshot = await _firestore
          .collection('rewards')
          .where('isRedeemed', isEqualTo: false)
          .get();
      
      return snapshot.docs
          .map((doc) => RewardModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des récompenses: $e');
      return [];
    }
  }

  // Méthode pour récupérer les récompenses d'un utilisateur
  Future<List<RewardModel>> getUserRewards(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('rewards')
          .where('userId', isEqualTo: userId)
          .where('isRedeemed', isEqualTo: true)
          .get();
      
      return snapshot.docs
          .map((doc) => RewardModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération des récompenses utilisateur: $e');
      return [];
    }
  }

  // Méthode pour échanger des points contre une récompense
  Future<RewardModel?> redeemReward(String rewardId) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Récupérer la récompense
      final rewardDoc = await _firestore.collection('rewards').doc(rewardId).get();
      if (!rewardDoc.exists) {
        throw Exception('Récompense non trouvée');
      }

      final reward = RewardModel.fromJson(rewardDoc.data() as Map<String, dynamic>);
      
      // Vérifier si l'utilisateur a assez de points
      if (user.carbonPoints < reward.pointsCost) {
        throw Exception('Points insuffisants pour cette récompense');
      }

      // Mettre à jour la récompense
      final updatedReward = RewardModel(
        id: reward.id,
        title: reward.title,
        description: reward.description,
        pointsCost: reward.pointsCost,
        imageUrl: reward.imageUrl,
        type: reward.type,
        expiryDate: reward.expiryDate,
        productId: reward.productId,
        discountPercentage: reward.discountPercentage,
        isRedeemed: true,
        userId: user.uid,
      );

      // Enregistrer la récompense mise à jour
      await _firestore
          .collection('rewards')
          .doc(rewardId)
          .update(updatedReward.toJson());

      // Déduire les points de l'utilisateur
      await _firestore.collection('users').doc(user.uid).update({
        'carbonPoints': FieldValue.increment(-reward.pointsCost),
      });

      return updatedReward;
    } catch (e) {
      debugPrint('Erreur lors de l\'échange de points: $e');
      rethrow;
    }
  }

  // Méthode pour créer une nouvelle récompense (pour l'admin)
  Future<RewardModel> createReward({
    required String title,
    required String description,
    required int pointsCost,
    String? imageUrl,
    required String type,
    required DateTime expiryDate,
    String? productId,
    required double discountPercentage,
  }) async {
    try {
      final rewardId = DateTime.now().millisecondsSinceEpoch.toString();
      
      final reward = RewardModel(
        id: rewardId,
        title: title,
        description: description,
        pointsCost: pointsCost,
        imageUrl: imageUrl,
        type: type,
        expiryDate: expiryDate,
        productId: productId,
        discountPercentage: discountPercentage,
        isRedeemed: false,
        userId: '',
      );

      await _firestore
          .collection('rewards')
          .doc(rewardId)
          .set(reward.toJson());

      return reward;
    } catch (e) {
      debugPrint('Erreur lors de la création de la récompense: $e');
      rethrow;
    }
  }

  // Méthode pour vérifier si un coupon est valide pour un produit
  Future<bool> isCouponValidForProduct(String couponId, String productId) async {
    try {
      final couponDoc = await _firestore.collection('rewards').doc(couponId).get();
      if (!couponDoc.exists) {
        return false;
      }

      final coupon = RewardModel.fromJson(couponDoc.data() as Map<String, dynamic>);
      
      // Vérifier si le coupon est expiré
      if (coupon.expiryDate.isBefore(DateTime.now())) {
        return false;
      }

      // Vérifier si le coupon est déjà utilisé
      if (coupon.isRedeemed) {
        return false;
      }

      // Vérifier si le coupon est valide pour ce produit
      if (coupon.productId != null && coupon.productId != productId) {
        return false;
      }

      return true;
    } catch (e) {
      debugPrint('Erreur lors de la vérification du coupon: $e');
      return false;
    }
  }
}
