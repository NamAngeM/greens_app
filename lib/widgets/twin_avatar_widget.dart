import 'package:flutter/material.dart';
import 'package:greens_app/models/eco_digital_twin_model.dart';
import 'package:greens_app/utils/app_colors.dart';

class TwinAvatarWidget extends StatelessWidget {
  final EcoDigitalTwinModel twin;
  final String statusMessage;
  
  const TwinAvatarWidget({
    Key? key,
    required this.twin,
    required this.statusMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sélectionner la couleur en fonction du niveau
    final avatarColor = _getAvatarColor(twin.ecoLevel);
    
    // Sélectionner l'environnement en fonction du niveau
    final environment = _getEnvironment(twin.ecoLevel);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            avatarColor.withOpacity(0.8),
            avatarColor.withOpacity(0.4),
          ],
        ),
      ),
      child: Column(
        children: [
          const SizedBox(height: 20),
          
          // L'avatar du jumeau numérique
          Stack(
            alignment: Alignment.center,
            children: [
              // Environnement en arrière-plan
              Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.2),
                  image: DecorationImage(
                    image: AssetImage(environment),
                    fit: BoxFit.cover,
                    colorFilter: ColorFilter.mode(
                      Colors.white.withOpacity(0.3),
                      BlendMode.lighten,
                    ),
                  ),
                ),
              ),
              
              // Avatar principal
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: avatarColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _getAvatarIcon(twin.ecoLevel),
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              
              // Niveau écologique
              Positioned(
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 5,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Text(
                    'Niveau ${twin.ecoLevel}',
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              
              // Accessoires (si présents)
              if (twin.visualFeatures['avatarAccessories'] != null) ...[
                for (String accessory in twin.visualFeatures['avatarAccessories'])
                  _buildAccessory(accessory),
              ],
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Message de statut
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              statusMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w500,
                shadows: [
                  Shadow(
                    offset: Offset(1, 1),
                    blurRadius: 3,
                    color: Color.fromRGBO(0, 0, 0, 0.3),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }
  
  // Construit un accessoire pour l'avatar
  Widget _buildAccessory(String accessory) {
    IconData icon;
    Color color;
    Alignment position;
    
    switch (accessory) {
      case 'leaf':
        icon = Icons.eco;
        color = Colors.lightGreen;
        position = Alignment.topRight;
        break;
      case 'water_drop':
        icon = Icons.water_drop;
        color = Colors.lightBlue;
        position = Alignment.topLeft;
        break;
      case 'energy':
        icon = Icons.bolt;
        color = Colors.amber;
        position = Alignment.bottomRight;
        break;
      case 'recycling':
        icon = Icons.recycling;
        color = Colors.teal;
        position = Alignment.bottomLeft;
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Positioned(
      top: position == Alignment.topLeft || position == Alignment.topRight ? 5 : null,
      bottom: position == Alignment.bottomLeft || position == Alignment.bottomRight ? 25 : null,
      left: position == Alignment.topLeft || position == Alignment.bottomLeft ? 15 : null,
      right: position == Alignment.topRight || position == Alignment.bottomRight ? 15 : null,
      child: Container(
        padding: const EdgeInsets.all(5),
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 3,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Icon(
          icon,
          size: 18,
          color: color,
        ),
      ),
    );
  }
  
  // Obtient la couleur de l'avatar en fonction du niveau
  Color _getAvatarColor(int level) {
    if (level <= 2) return AppColors.primaryColor;
    if (level <= 5) return Colors.teal;
    if (level <= 8) return Colors.indigo;
    if (level <= 12) return Colors.deepPurple;
    return Colors.deepOrange;
  }
  
  // Obtient l'icône de l'avatar en fonction du niveau
  IconData _getAvatarIcon(int level) {
    if (level <= 2) return Icons.eco;
    if (level <= 5) return Icons.park;
    if (level <= 8) return Icons.forest;
    if (level <= 12) return Icons.nature;
    return Icons.emoji_nature;
  }
  
  // Obtient l'image d'environnement en fonction du niveau
  String _getEnvironment(int level) {
    if (level <= 2) return 'assets/images/environments/sprout.png';
    if (level <= 5) return 'assets/images/environments/garden.png';
    if (level <= 8) return 'assets/images/environments/forest.png';
    if (level <= 12) return 'assets/images/environments/mountain.png';
    return 'assets/images/environments/planet.png';
  }
} 