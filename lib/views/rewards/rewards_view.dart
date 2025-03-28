import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/reward_controller.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/models/reward_model.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/widgets/custom_button.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/reward_controller.dart';
import '../../models/reward_model.dart';
import '../../utils/app_colors.dart';
import '../../widgets/custom_button.dart';

class RewardsView extends StatefulWidget {
  const RewardsView({Key? key}) : super(key: key);

  @override
  State<RewardsView> createState() => _RewardsViewState();
}

class _RewardsViewState extends State<RewardsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialiser les contrôleurs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final rewardController = Provider.of<RewardController>(context, listen: false);
      rewardController.getAvailableRewards();
      rewardController.getUserRewards();
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final rewardController = Provider.of<RewardController>(context);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Mes récompenses'),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Disponibles'),
            Tab(text: 'Mes coupons'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Points carbone
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.eco,
                    color: AppColors.secondaryColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Points carbone',
                        style: TextStyle(
                          color: AppColors.textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Vous avez ${authController.currentUser?.carbonPoints ?? 0} points',
                        style: const TextStyle(
                          color: AppColors.textLightColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                CustomButton(
                  text: 'Gagner plus',
                  onPressed: () {
                    Navigator.pushNamed(context, '/carbon_calculator');
                  },
                  backgroundColor: AppColors.secondaryColor,
                  height: 40,
                ),
              ],
            ),
          ),
          
          // Contenu des onglets
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                // Onglet des récompenses disponibles
                _buildAvailableRewardsTab(rewardController, authController),
                
                // Onglet des coupons de l'utilisateur
                _buildUserCouponsTab(rewardController),
                
                // Onglet de l'historique
                _buildHistoryTab(rewardController),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvailableRewardsTab(RewardController rewardController, AuthController authController) {
    if (rewardController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (rewardController.availableRewards.isEmpty) {
      return const Center(
        child: Text('Aucune récompense disponible pour le moment'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rewardController.availableRewards.length,
      itemBuilder: (context, index) {
        final reward = rewardController.availableRewards[index];
        final bool canRedeem = (authController.currentUser?.carbonPoints ?? 0) >= reward.pointsCost;
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getRewardIcon(reward.type),
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reward.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reward.description,
                            style: const TextStyle(
                              color: AppColors.textLightColor,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.eco,
                            color: AppColors.secondaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${reward.pointsCost} points',
                            style: const TextStyle(
                              color: AppColors.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    CustomButton(
                      text: 'Échanger',
                      onPressed: canRedeem
                          ? () => _redeemReward(context, reward)
                          : null,
                      backgroundColor: canRedeem
                          ? AppColors.primaryColor
                          : AppColors.textLightColor.withOpacity(0.5),
                      height: 40,
                    ),
                  ],
                ),
                if (!canRedeem) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Il vous manque ${reward.pointsCost - (authController.currentUser?.carbonPoints ?? 0)} points',
                    style: const TextStyle(
                      color: AppColors.errorColor,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.end,
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserCouponsTab(RewardController rewardController) {
    if (rewardController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (rewardController.userRewards.isEmpty) {
      return const Center(
        child: Text('Vous n\'avez pas encore de coupons'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: rewardController.userRewards.length,
      itemBuilder: (context, index) {
        final reward = rewardController.userRewards[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        _getRewardIcon(reward.type),
                        color: AppColors.primaryColor,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            reward.title,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            reward.description,
                            style: const TextStyle(
                              color: AppColors.textLightColor,
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: reward.isUsed
                            ? Colors.grey.withOpacity(0.1)
                            : AppColors.secondaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            reward.isUsed ? Icons.check : Icons.access_time,
                            color: reward.isUsed
                                ? Colors.grey
                                : AppColors.secondaryColor,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            reward.isUsed ? 'Utilisé' : 'Valide jusqu\'au ${_formatDate(reward.expiryDate)}',
                            style: TextStyle(
                              color: reward.isUsed
                                  ? Colors.grey
                                  : AppColors.secondaryColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(),
                    if (!reward.isUsed)
                      CustomButton(
                        text: 'Utiliser',
                        onPressed: () => _useReward(context, reward),
                        backgroundColor: AppColors.primaryColor,
                        height: 40,
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHistoryTab(RewardController rewardController) {
    if (rewardController.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    final usedRewards = rewardController.userRewards.where((r) => r?.isUsed).toList();
    
    if (usedRewards.isEmpty) {
      return const Center(
        child: Text('Aucun historique disponible'),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: usedRewards.length,
      itemBuilder: (context, index) {
        final reward = usedRewards[index];
        
        return Card(
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getRewardIcon(reward.type),
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        reward.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Utilisé le ${_formatDate(reward.usedDate ?? DateTime.now())}',
                        style: const TextStyle(
                          color: AppColors.textLightColor,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _redeemReward(BuildContext context, RewardModel reward) {
    final rewardController = Provider.of<RewardController>(context, listen: false);
    final authController = Provider.of<AuthController>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Échanger des points'),
        content: Text(
          'Voulez-vous échanger ${reward.pointsCost} points contre "${reward.title}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await rewardController.redeemReward(
                reward as String,
                authController.currentUser!,
              );
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Récompense obtenue avec succès !'),
                    backgroundColor: AppColors.successColor,
                  ),
                );
                
                // Mettre à jour les points de l'utilisateur
                authController.updateCarbonPoints(
                  -reward.pointsCost, // Utiliser une valeur négative pour soustraire les points
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(rewardController.errorMessage ?? 'Erreur lors de l\'échange'),
                    backgroundColor: AppColors.errorColor,
                  ),
                );
              }
            },
            child: const Text('Échanger'),
          ),
        ],
      ),
    );
  }

  void _useReward(BuildContext context, RewardModel reward) {
    final rewardController = Provider.of<RewardController>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Utiliser le coupon'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Icon(
                    _getRewardIcon(reward.type),
                    color: AppColors.primaryColor,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    reward.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    reward.description,
                    style: const TextStyle(
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Code: ${reward.couponCode}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: AppColors.primaryColor,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Présentez ce code au moment de l\'achat pour bénéficier de votre réduction.',
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              
              final success = await rewardController.markRewardAsUsed(reward);
              
              if (success && context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Coupon marqué comme utilisé'),
                    backgroundColor: AppColors.successColor,
                  ),
                );
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(rewardController.errorMessage ?? 'Erreur lors de l\'utilisation du coupon'),
                    backgroundColor: AppColors.errorColor,
                  ),
                );
              }
            },
            child: const Text('Marquer comme utilisé'),
          ),
        ],
      ),
    );
  }

  IconData _getRewardIcon(String type) {
    switch (type) {
      case 'discount':
        return Icons.local_offer;
      case 'freeShipping':
        return Icons.local_shipping;
      case 'giftCard':
        return Icons.card_giftcard;
      case 'product':
        return Icons.shopping_bag;
      default:
        return Icons.redeem;
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

extension on Object? {
  get isUsed => null;
}
