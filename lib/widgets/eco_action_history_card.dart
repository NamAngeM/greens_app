import 'package:flutter/material.dart';
import 'package:greens_app/models/eco_digital_twin_model.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:intl/intl.dart';

class EcoActionHistoryCard extends StatelessWidget {
  final EcoAction action;
  
  const EcoActionHistoryCard({
    Key? key,
    required this.action,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Formater la date
    final formattedDate = _formatDate(action.timestamp);
    
    // Obtenir l'icône et la couleur en fonction du type d'action
    final IconData actionIcon = _getActionIcon(action.actionType);
    final Color actionColor = _getActionColor(action.actionType);
    
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icône de l'action
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: actionColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                actionIcon,
                color: actionColor,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Détails de l'action
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    action.description,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textColor,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formattedDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            
            // Impact carbone
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.eco,
                        color: Colors.green,
                        size: 14,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '-${action.carbonImpact.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Badges supplémentaires (si disponibles)
                if (action.additionalData != null && 
                    action.additionalData!['badges'] != null)
                  ..._buildBadges(action.additionalData!['badges']),
              ],
            ),
          ],
        ),
      ),
    );
  }
  
  // Formate la date de l'action
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        return 'Il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      }
      return 'Il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
    } else {
      return DateFormat('dd/MM/yyyy').format(date);
    }
  }
  
  // Obtient l'icône en fonction du type d'action
  IconData _getActionIcon(String actionType) {
    switch (actionType) {
      case 'transport_public':
        return Icons.directions_bus;
      case 'vegetarian_meal':
        return Icons.restaurant;
      case 'reusable_bag':
        return Icons.shopping_bag;
      case 'recycle':
        return Icons.recycling;
      case 'energy_saving':
        return Icons.power;
      case 'water_saving':
        return Icons.water_drop;
      case 'product_scan':
        return Icons.qr_code_scanner;
      case 'challenge_complete':
        return Icons.emoji_events;
      default:
        return Icons.eco;
    }
  }
  
  // Obtient la couleur en fonction du type d'action
  Color _getActionColor(String actionType) {
    switch (actionType) {
      case 'transport_public':
        return Colors.blue;
      case 'vegetarian_meal':
        return Colors.orange;
      case 'reusable_bag':
        return Colors.amber;
      case 'recycle':
        return Colors.teal;
      case 'energy_saving':
        return Colors.purple;
      case 'water_saving':
        return Colors.lightBlue;
      case 'product_scan':
        return Colors.indigo;
      case 'challenge_complete':
        return Colors.deepOrange;
      default:
        return AppColors.primaryColor;
    }
  }
  
  // Construit les badges supplémentaires
  List<Widget> _buildBadges(List<dynamic> badges) {
    return badges.map<Widget>((badge) {
      return Container(
        margin: const EdgeInsets.only(top: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(
          color: _getBadgeColor(badge['type']).withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          badge['name'],
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: _getBadgeColor(badge['type']),
          ),
        ),
      );
    }).toList();
  }
  
  // Obtient la couleur du badge
  Color _getBadgeColor(String badgeType) {
    switch (badgeType) {
      case 'streak':
        return Colors.orange;
      case 'achievement':
        return Colors.purple;
      case 'milestone':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }
} 