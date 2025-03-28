import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/utils/app_colors.dart';

class CustomMenu extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const CustomMenu({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        Container(
          height: 70,
          decoration: BoxDecoration(
            color: AppColors.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                spreadRadius: 0,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(context, 'home.png', 0, 'Home'),
                _buildNavItem(context, 'article.png', 1, 'Articles'),
                // Espace pour le bouton central
                const SizedBox(width: 40),
                _buildNavItem(context, 'panier.png', 2, 'Produits'),
                _buildNavItem(context, 'profil.png', 3, 'Profile'),
              ],
            ),
          ),
        ),
        // Bouton central surélevé
        Positioned(
          top: -15,
          child: InkWell(
            onTap: () {
              if (onTap != null) {
                onTap!(4); // Index spécial pour le chatbot
              }
              Navigator.pushNamed(context, AppRoutes.chatbot);
            },
            customBorder: const CircleBorder(),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Image.asset(
                  'assets/images/logo/green_minds_logo.png',
                  width: 36,
                  height: 36,
                  color: Colors.white,
                  errorBuilder: (context, error, stackTrace) {
                    return const Icon(
                      Icons.chat,
                      size: 36,
                      color: Colors.white,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavItem(BuildContext context, String iconName, int index, String label) {
    final bool isActive = currentIndex == index;
    
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!(index);
        }
        // Navigation basée sur l'index
        switch (index) {
          case 0: // Accueil
            Navigator.pushNamed(context, AppRoutes.home);
            break;
          case 1: // Articles
            Navigator.pushNamed(context, AppRoutes.articles);
            break;
          case 2: // Produits
            Navigator.pushNamed(context, AppRoutes.products);
            break;
          case 3: // Profil
            Navigator.pushNamed(context, AppRoutes.profile);
            break;
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              'assets/images/icons/$iconName',
              width: 24,
              height: 24,
              color: isActive ? AppColors.secondaryColor : AppColors.textLightColor,
              errorBuilder: (context, error, stackTrace) {
                // En cas d'erreur, afficher une icône par défaut
                return Icon(
                  index == 0 ? Icons.home :
                  index == 1 ? Icons.article :
                  index == 2 ? Icons.shopping_cart :
                  Icons.person,
                  size: 24,
                  color: isActive ? AppColors.secondaryColor : AppColors.textLightColor,
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppColors.secondaryColor : AppColors.textLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}