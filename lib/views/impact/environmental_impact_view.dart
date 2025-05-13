import 'package:flutter/material.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/models/environmental_impact_model.dart';
import 'package:greens_app/services/environmental_impact_service.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/widgets/environmental_impact_card.dart';
import 'package:greens_app/widgets/social_sharing_card.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class EnvironmentalImpactView extends StatefulWidget {
  const EnvironmentalImpactView({Key? key}) : super(key: key);

  @override
  State<EnvironmentalImpactView> createState() => _EnvironmentalImpactViewState();
}

class _EnvironmentalImpactViewState extends State<EnvironmentalImpactView> {
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadImpactData();
  }
  
  // Chargement des données d'impact
  Future<void> _loadImpactData() async {
    final authController = Provider.of<AuthController>(context, listen: false);
    final userId = authController.currentUser?.uid ?? '';
    
    if (userId.isEmpty) {
      setState(() => _isLoading = false);
      return;
    }
    
    final impactService = Provider.of<EnvironmentalImpactService>(context, listen: false);
    
    try {
      await impactService.getUserImpact(userId);
    } catch (e) {
      print('Erreur lors du chargement des données d\'impact: $e');
    }
    
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Votre impact environnemental'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textColor,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareImpact(context),
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Consumer<EnvironmentalImpactService>(
            builder: (context, impactService, child) {
              final impact = impactService.userImpact;
              
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Carte principale d'impact
                    EnvironmentalImpactCard(
                      impact: impact,
                      showDetails: true,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Message d'impact personnalisé
                    _buildImpactMessage(impactService),
                    
                    const SizedBox(height: 24),
                    
                    // Actions recommandées
                    _buildRecommendedActions(),
                    
                    const SizedBox(height: 24),
                    
                    // Partage social
                    SocialSharingCard(
                      impact: impact,
                    ),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              );
            },
          ),
    );
  }
  
  // Message d'impact personnalisé
  Widget _buildImpactMessage(EnvironmentalImpactService impactService) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.star,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Votre contribution',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              impactService.generateImpactMessage(),
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              impactService.generateCommunityImpactMessage(),
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Actions recommandées pour augmenter l'impact
  Widget _buildRecommendedActions() {
    // Liste d'actions fictives, à remplacer par des données réelles
    final actions = [
      {
        'title': 'Utilisez les transports en commun',
        'impact': '2.5 kg CO₂',
        'icon': Icons.directions_bus,
      },
      {
        'title': 'Mangez végétarien une journée',
        'impact': '1.5 kg CO₂',
        'icon': Icons.restaurant,
      },
      {
        'title': 'Éteignez les appareils en veille',
        'impact': '1.0 kg CO₂',
        'icon': Icons.power_settings_new,
      },
    ];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 8.0),
          child: Text(
            'Actions recommandées',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
        ),
        const SizedBox(height: 12),
        ...actions.map((action) => _buildActionItem(
          action['title'] as String,
          action['impact'] as String,
          action['icon'] as IconData,
        )).toList(),
      ],
    );
  }
  
  // Item d'action individuel
  Widget _buildActionItem(String title, String impact, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: AppColors.primaryColor,
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          'Économisez environ $impact',
          style: TextStyle(
            color: Colors.grey.shade700,
          ),
        ),
        trailing: ElevatedButton(
          onPressed: () {
            // Action à effectuer
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Défi "$title" accepté !'),
                backgroundColor: AppColors.primaryColor,
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
          ),
          child: const Text('Agir'),
        ),
      ),
    );
  }
  
  // Partage de l'impact par l'API standard
  void _shareImpact(BuildContext context) {
    final impactService = Provider.of<EnvironmentalImpactService>(context, listen: false);
    final impact = impactService.userImpact;
    
    String shareText = 'Mon impact environnemental avec Green Minds :\n\n';
    shareText += 'J\'ai économisé ${impact.carbonSaved.toStringAsFixed(1)} kg de CO₂, soit l\'équivalent de ${impact.treeEquivalent.toStringAsFixed(1)} arbres plantés !\n\n';
    shareText += 'Rejoignez-moi pour agir en faveur de la planète : https://green-minds-app.com';
    
    Share.share(shareText, subject: 'Mon impact environnemental');
  }
} 