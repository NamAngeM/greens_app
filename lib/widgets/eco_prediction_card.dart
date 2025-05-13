import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';

class EcoPredictionCard extends StatelessWidget {
  final String title;
  final double value;
  final String unit;
  final String description;
  final IconData icon;
  final Color color;
  
  const EcoPredictionCard({
    Key? key,
    required this.title,
    required this.value,
    required this.unit,
    required this.description,
    required this.icon,
    this.color = AppColors.primaryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                // Icône
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                
                // Titre
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textColor,
                    ),
                  ),
                ),
                
                // Valeur et unité
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1),
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      unit,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: color,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Description et graphique
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 46), // Aligner avec l'icône
                
                // Description
                Expanded(
                  child: Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                    ),
                  ),
                ),
                
                // Indicateur de tendance
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: _getTrendColor().withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTrendIcon(),
                        color: _getTrendColor(),
                        size: 12,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        _getTrendText(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _getTrendColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Barre de progression pour visualiser la prédiction
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: _getProgressValue(),
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(color),
                minHeight: 6,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  // Obtient la valeur de progression pour la barre
  double _getProgressValue() {
    // Différentes logiques selon le type de prédiction
    if (unit == '%') {
      return value / 100;
    } else if (title.contains('Projection')) {
      // Pour les projections, on utilise une échelle relative
      return value > 200 ? 0.8 : value / 250;
    } else {
      // Valeur par défaut
      return 0.6;
    }
  }
  
  // Obtient l'icône de tendance
  IconData _getTrendIcon() {
    if (title.contains('réduction') || title.contains('Amélioration')) {
      return Icons.trending_up;
    } else if (value < 50) {
      return Icons.trending_down;
    } else {
      return Icons.trending_up;
    }
  }
  
  // Obtient la couleur de tendance
  Color _getTrendColor() {
    if (title.contains('réduction') || title.contains('Amélioration')) {
      return Colors.green;
    } else if (value < 50) {
      return Colors.orange;
    } else {
      return Colors.green;
    }
  }
  
  // Obtient le texte de tendance
  String _getTrendText() {
    if (title.contains('réduction')) {
      return 'Positif';
    } else if (title.contains('Amélioration')) {
      return 'En hausse';
    } else if (value < 50) {
      return 'En baisse';
    } else {
      return 'En hausse';
    }
  }
} 