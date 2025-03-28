import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/carbon_footprint_controller.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/widgets/custom_button.dart';
import 'package:greens_app/utils/app_router.dart';

import '../../controllers/carbon_footprint_controller.dart';
import '../../utils/app_colors.dart';
import '../../utils/app_router.dart';
import '../../widgets/custom_button.dart';

class CarbonResultsView extends StatelessWidget {
  final int score;
  final List<Map<String, dynamic>> answers;
  final List<Map<String, dynamic>> questions;

  const CarbonResultsView({
    Key? key,
    required this.score,
    required this.answers,
    required this.questions,
  }) : super(key: key);

  String get _scoreCategory {
    if (score <= 5) {
      return 'Excellent';
    } else if (score <= 10) {
      return 'Bon';
    } else if (score <= 15) {
      return 'Moyen';
    } else if (score <= 20) {
      return 'Élevé';
    } else {
      return 'Très élevé';
    }
  }

  Color get _scoreColor {
    if (score <= 5) {
      return AppColors.lowCarbonColor;
    } else if (score <= 10) {
      return AppColors.lowCarbonColor.withOpacity(0.7);
    } else if (score <= 15) {
      return AppColors.mediumCarbonColor;
    } else if (score <= 20) {
      return AppColors.highCarbonColor.withOpacity(0.7);
    } else {
      return AppColors.highCarbonColor;
    }
  }

  List<String> get _recommendations {
    final List<String> recs = [];
    
    // Recommandations basées sur les réponses
    for (int i = 0; i < answers.length; i++) {
      final answer = answers[i];
      final question = questions[i];
      
      if (i == 0 && answer['value'] > 2) {
        recs.add('Essayez d\'utiliser davantage les transports en commun, le vélo ou la marche pour vos déplacements quotidiens.');
      }
      
      if (i == 1 && answer['value'] > 2) {
        recs.add('Réduisez votre consommation de viande en introduisant plus de repas végétariens dans votre alimentation.');
      }
      
      if (i == 2 && answer['value'] > 1) {
        recs.add('Améliorez votre tri des déchets et envisagez de réduire vos déchets à la source en évitant les emballages.');
      }
      
      if (i == 3 && answer['value'] > 1) {
        recs.add('Optimisez votre consommation d\'énergie en utilisant des appareils économes et en éteignant les appareils en veille.');
      }
      
      if (i == 4 && answer['value'] > 0) {
        recs.add('Limitez vos voyages en avion et privilégiez le train pour les trajets où c\'est possible.');
      }
    }
    
    // Ajouter des recommandations générales si nécessaire
    if (recs.isEmpty) {
      recs.add('Continuez vos efforts pour maintenir une faible empreinte carbone !');
    }
    
    return recs;
  }

  int get _earnedPoints {
    // Calcul des points gagnés en fonction du score
    // Plus le score est bas, plus les points sont élevés
    final maxScore = questions.length * 5; // Score maximum possible
    final normalizedScore = maxScore - score; // Inverser pour que les bons scores donnent plus de points
    
    // Convertir en points (entre 10 et 100)
    return (normalizedScore / maxScore * 90 + 10).round();
  }

  @override
  Widget build(BuildContext context) {
    final carbonFootprintController = Provider.of<CarbonFootprintController>(context);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Résultats'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte de résultat principal
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'Votre empreinte carbone',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Jauge d'empreinte carbone
                  SizedBox(
                    height: 160,
                    width: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          height: 160,
                          width: 160,
                          child: CircularProgressIndicator(
                            value: score / (questions.length * 5),
                            strokeWidth: 12,
                            backgroundColor: Colors.grey.withOpacity(0.2),
                            color: _scoreColor,
                          ),
                        ),
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _scoreCategory,
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: _scoreColor,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$score points',
                              style: const TextStyle(
                                fontSize: 16,
                                color: AppColors.textLightColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Points gagnés
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.eco,
                          color: AppColors.secondaryColor,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Points gagnés',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textColor,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                'Vous avez gagné $_earnedPoints points carbone !',
                                style: const TextStyle(
                                  color: AppColors.textLightColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Recommandations
            const Text(
              'Recommandations',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _recommendations.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.lightbulb_outline,
                              color: AppColors.primaryColor,
                              size: 18,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _recommendations[index],
                            style: const TextStyle(
                              color: AppColors.textColor,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            
            // Boutons d'action
            CustomButton(
              text: 'Voir mes récompenses',
              onPressed: () {
                // Naviguer vers la page des récompenses
                Navigator.pushReplacementNamed(context, AppRoutes.rewards);
              },
              backgroundColor: AppColors.secondaryColor,
              icon: Icons.card_giftcard,
            ),
            const SizedBox(height: 12),
            CustomButton(
              text: 'Retour à l\'accueil',
              onPressed: () {
                Navigator.pushReplacementNamed(context, AppRoutes.home);
              },
              backgroundColor: Colors.white,
              textColor: AppColors.primaryColor,
              icon: Icons.home,
            ),
          ],
        ),
      ),
    );
  }
}