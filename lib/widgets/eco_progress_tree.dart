// lib/widgets/eco_progress_tree.dart
import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_styles.dart';
import 'package:greens_app/services/eco_journey_service.dart';
import 'package:provider/provider.dart';
import 'dart:math';

/// Widget qui affiche un arbre de progression écologique visuel
/// L'arbre grandit et se développe avec les actions écologiques de l'utilisateur
class EcoProgressTree extends StatelessWidget {
  final Map<String, dynamic> treeData;
  final double height;
  final double width;
  
  const EcoProgressTree({
    Key? key,
    required this.treeData,
    this.height = 300,
    this.width = double.infinity,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    final level = treeData['level'] as int;
    final growthPercentage = treeData['growthPercentage'] as double;
    final totalLeaves = treeData['totalLeaves'] as int;
    final totalBranches = treeData['totalBranches'] as int;
    final milestones = treeData['milestones'] as List<Map<String, dynamic>>;
    
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: AppColors.lightGreen.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          // Fond de ciel
          Positioned.fill(
            child: CustomPaint(
              painter: SkyPainter(
                timeOfDay: TimeOfDay.now(),
              ),
            ),
          ),
          
          // Arbre qui grandit
          Positioned.fill(
            child: CustomPaint(
              painter: TreePainter(
                growthPercentage: growthPercentage,
                leavesCount: totalLeaves,
                branchesCount: totalBranches,
                level: level,
              ),
            ),
          ),
          
          // Informations sur le niveau
          Positioned(
            top: 16,
            left: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Niveau ${level}',
                  style: AppStyles.heading2.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  Provider.of<EcoJourneyService>(context).getLevelTitle(level),
                  style: AppStyles.bodyText.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Progression
          Positioned(
            bottom: 16,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '${growthPercentage.toStringAsFixed(1)}% de croissance',
                  style: AppStyles.bodyText.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: growthPercentage / 100,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                  borderRadius: BorderRadius.circular(10),
                ),
                const SizedBox(height: 8),
                Text(
                  '$totalLeaves feuilles • $totalBranches branches',
                  style: AppStyles.caption.copyWith(
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 2,
                        offset: const Offset(1, 1),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bouton pour voir les jalons
          Positioned(
            top: 16,
            right: 16,
            child: IconButton(
              icon: const Icon(Icons.timeline, color: Colors.white),
              onPressed: () {
                _showMilestones(context, milestones);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  void _showMilestones(BuildContext context, List<Map<String, dynamic>> milestones) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.4,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Votre parcours écologique',
                  style: AppStyles.heading2,
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: scrollController,
                  itemCount: milestones.length,
                  itemBuilder: (context, index) {
                    final milestone = milestones[index];
                    final isGoal = milestone['type'] == 'goal';
                    
                    return ListTile(
                      leading: Icon(
                        isGoal ? Icons.flag : Icons.emoji_events,
                        color: isGoal 
                          ? (milestone['isCompleted'] ? AppColors.successGreen : AppColors.primaryColor)
                          : Colors.amber,
                      ),
                      title: Text(milestone['title']),
                      subtitle: Text(
                        isGoal 
                          ? 'Objectif ${milestone['isCompleted'] ? 'complété' : 'en cours'}'
                          : 'Badge obtenu'
                      ),
                      trailing: isGoal 
                        ? CircularProgressIndicator(
                            value: milestone['progress'],
                            strokeWidth: 2,
                            backgroundColor: Colors.grey.shade200,
                            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primaryColor),
                          )
                        : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Peintre personnalisé pour le ciel
class SkyPainter extends CustomPainter {
  final TimeOfDay timeOfDay;
  
  SkyPainter({required this.timeOfDay});
  
  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    // Couleurs du ciel selon l'heure
    Color topColor;
    Color bottomColor;
    
    final hour = timeOfDay.hour;
    if (hour >= 6 && hour < 10) {
      // Matin
      topColor = const Color(0xFF64B5F6);
      bottomColor = const Color(0xFFE3F2FD);
    } else if (hour >= 10 && hour < 16) {
      // Journée
      topColor = const Color(0xFF2196F3);
      bottomColor = const Color(0xFF90CAF9);
    } else if (hour >= 16 && hour < 20) {
      // Soir
      topColor = const Color(0xFFFF9800);
      bottomColor = const Color(0xFFFFE0B2);
    } else {
      // Nuit
      topColor = const Color(0xFF1A237E);
      bottomColor = const Color(0xFF3949AB);
    }
    
    final gradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [topColor, bottomColor],
    );
    
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
    
    // Ajouter des étoiles la nuit
    if (hour >= 20 || hour < 6) {
      final starPaint = Paint()..color = Colors.white;
      final random = DateTime.now().millisecondsSinceEpoch;
      
      for (int i = 0; i < 50; i++) {
        final x = (random * (i + 1)) % size.width;
        final y = (random * (i + 2)) % (size.height * 0.7);
        final radius = ((random * (i + 3)) % 2) + 1.0;
        
        canvas.drawCircle(Offset(x, y), radius, starPaint);
      }
    }
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Peintre personnalisé pour l'arbre
class TreePainter extends CustomPainter {
  final double growthPercentage;
  final int leavesCount;
  final int branchesCount;
  final int level;
  
  TreePainter({
    required this.growthPercentage,
    required this.leavesCount,
    required this.branchesCount,
    required this.level,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final centerX = size.width / 2;
    final groundY = size.height * 0.9;
    
    // Dessiner le sol
    final groundPaint = Paint()..color = const Color(0xFF795548);
    canvas.drawRect(
      Rect.fromLTWH(0, groundY, size.width, size.height - groundY),
      groundPaint,
    );
    
    // Dessiner l'herbe
    final grassPaint = Paint()..color = const Color(0xFF8BC34A);
    for (int i = 0; i < size.width ~/ 10; i++) {
      final x = i * 10.0;
      final height = 5 + (i % 3) * 3.0;
      canvas.drawRect(
        Rect.fromLTWH(x, groundY - height, 3, height),
        grassPaint,
      );
    }
    
    // Calculer la hauteur de l'arbre en fonction de la croissance
    final treeHeight = size.height * 0.7 * (growthPercentage / 100);
    final trunkWidth = 20.0 + (level * 2.0);
    
    // Dessiner le tronc
    final trunkPaint = Paint()..color = const Color(0xFF795548);
    canvas.drawRect(
      Rect.fromLTWH(
        centerX - trunkWidth / 2,
        groundY - treeHeight,
        trunkWidth,
        treeHeight,
      ),
      trunkPaint,
    );
    
    // Dessiner les branches
    final branchPaint = Paint()..color = const Color(0xFF5D4037);
    final random = DateTime.now().millisecondsSinceEpoch;
    
    for (int i = 0; i < branchesCount; i++) {
      final branchY = groundY - treeHeight * (0.3 + (i * 0.1) % 0.6);
      final direction = i % 2 == 0 ? 1 : -1;
      final branchLength = 30.0 + (i % 3) * 10.0;
      
      canvas.drawLine(
        Offset(centerX, branchY),
        Offset(centerX + (branchLength * direction), branchY - 10 - (i % 20)),
        branchPaint..strokeWidth = 5 + (i % 3),
      );
    }
    
    // Dessiner le feuillage
    final leafRadius = 30.0 + (level * 3.0);
    final leafPaint = Paint()..color = const Color(0xFF4CAF50);
    
    for (int i = 0; i < leavesCount; i++) {
      final angle = (random * (i + 1)) % 360 * (3.14159 / 180);
      final distance = leafRadius * 0.8 * ((random * (i + 2)) % 100) / 100;
      final x = centerX + distance * cos(angle);
      final y = groundY - treeHeight * 0.7 - distance * sin(angle);
      
      canvas.drawCircle(
        Offset(x, y),
        leafRadius * 0.3,
        leafPaint,
      );
    }
    
    // Dessiner un cercle principal de feuillage
    canvas.drawCircle(
      Offset(centerX, groundY - treeHeight * 0.7),
      leafRadius * (growthPercentage / 100),
      leafPaint,
    );
  }
  
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}