import 'package:flutter/material.dart';
import 'package:greens_app/models/reward_model.dart';
import 'package:greens_app/models/user_model.dart';
import 'package:greens_app/services/reward_service.dart';

class RewardController extends ChangeNotifier {
  final RewardService _rewardService = RewardService();
  List<RewardModel> _availableRewards = [];
  List<RewardModel> _userRewards = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<RewardModel> get availableRewards => _availableRewards;
  List<RewardModel> get userRewards => _userRewards;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Récupérer toutes les récompenses disponibles
  Future<void> getAvailableRewards() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _availableRewards = await _rewardService.getAvailableRewards();
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération des récompenses: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Récupérer les récompenses d'un utilisateur
  Future<void> getUserRewards(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userRewards = await _rewardService.getUserRewards(userId);
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération des récompenses utilisateur: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Échanger des points contre une récompense
  Future<bool> redeemReward(String rewardId, UserModel userModel) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reward = await _rewardService.redeemReward(rewardId);
      
      if (reward != null) {
        // Mettre à jour les listes de récompenses
        _availableRewards.removeWhere((r) => r.id == rewardId);
        _userRewards.add(reward);
        return true;
      }
      
      return false;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'échange de points: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Vérifier si un coupon est valide pour un produit
  Future<bool> isCouponValidForProduct(String couponId, String productId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final isValid = await _rewardService.isCouponValidForProduct(couponId, productId);
      return isValid;
    } catch (e) {
      _errorMessage = 'Erreur lors de la vérification du coupon: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  markRewardAsUsed(RewardModel reward) {}
}
