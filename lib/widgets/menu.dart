import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_styles.dart';

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
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: AppColors.surfaceColor,
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
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(context, 'home.png', 0, 'Home'),
          _buildNavItem(context, 'article.png', 1, 'Articles'),
          _buildChatbotButton(context),
          _buildNavItem(context, 'panier.png', 2, 'Produits'),
          _buildNavItem(context, 'profil.png', 3, 'Profile'),
          _buildMoreButton(context),
        ],
      ),
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
            if (ModalRoute.of(context)?.settings.name != AppRoutes.home) {
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.home, (route) => false);
            }
            break;
          case 1: // Articles
            if (ModalRoute.of(context)?.settings.name != AppRoutes.articles) {
              Navigator.pushNamed(context, AppRoutes.articles);
            }
            break;
          case 2: // Produits
            if (ModalRoute.of(context)?.settings.name != AppRoutes.products) {
              Navigator.pushNamed(context, AppRoutes.products);
            }
            break;
          case 3: // Profil
            if (ModalRoute.of(context)?.settings.name != AppRoutes.profile) {
              Navigator.pushNamed(context, AppRoutes.profile);
            }
            break;
        }
      },
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
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
                  index == 3 ? Icons.person :
                  Icons.menu,
                  size: 24,
                  color: isActive ? AppColors.secondaryColor : AppColors.textLightColor,
                );
              },
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
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

  Widget _buildChatbotButton(BuildContext context) {
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!(4); // Index spécial pour le chatbot
        }
        if (ModalRoute.of(context)?.settings.name != AppRoutes.ecoChatbot) {
          Navigator.pushNamed(context, AppRoutes.ecoChatbot);
        }
      },
      customBorder: const CircleBorder(),
      child: Container(
        width: 60,
        height: 60,
        margin: const EdgeInsets.only(bottom: 15),
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
    );
  }

  Widget _buildMoreButton(BuildContext context) {
    return InkWell(
      onTap: () {
        _showMoreMenu(context);
      },
      child: Container(
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.apps_rounded,
              size: 24,
              color: AppColors.textLightColor,
            ),
            const SizedBox(height: 4),
            Text(
              'Plus',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.normal,
                color: AppColors.textLightColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.7,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceColor,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Plus d\'options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Section Empreinte Carbone
                    _buildSectionHeader('Empreinte Carbone', Icons.nature),
                    
                    _buildGridMenuItems(context, [
                      MenuOption(
                        icon: Icons.calculate,
                        label: 'Calculateur',
                        color: AppColors.secondaryColor, 
                        onTap: () => Navigator.pushNamed(context, AppRoutes.carbonCalculator),
                      ),
                      MenuOption(
                        icon: Icons.bar_chart,
                        label: 'Tableau de bord',
                        color: AppColors.accentColor,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.carbonDashboard),
                      ),
                    ]),
                    
                    const SizedBox(height: 16),
                    
                    // Section Défis et Communauté
                    _buildSectionHeader('Défis et Objectifs', Icons.emoji_events),
                    
                    _buildGridMenuItems(context, [
                      MenuOption(
                        icon: Icons.eco,
                        label: 'Objectifs',
                        color: AppColors.successColor,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.goals),
                      ),
                      MenuOption(
                        icon: Icons.people,
                        label: 'Communauté',
                        color: AppColors.warningColor,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.community),
                      ),
                    ]),
                    
                    const SizedBox(height: 16),
                    
                    // Section Outils
                    _buildSectionHeader('Outils', Icons.handyman),
                    
                    _buildGridMenuItems(context, [
                      MenuOption(
                        icon: Icons.qr_code_scanner,
                        label: 'Scanner produits',
                        color: AppColors.primaryColor,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.productScanner),
                      ),
                      MenuOption(
                        icon: Icons.chat,
                        label: 'Assistant éco',
                        color: AppColors.infoColor,
                        onTap: () => Navigator.pushNamed(context, AppRoutes.ecoChatbot),
                      ),
                    ]),
                    
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 12),
      child: Row(
        children: [
          Icon(
            icon,
            size: 20,
            color: AppColors.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.primaryColor,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildGridMenuItems(BuildContext context, List<MenuOption> options) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 1.4,
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      children: options.map((option) => _buildGridMenuItem(context, option)).toList(),
    );
  }
  
  Widget _buildGridMenuItem(BuildContext context, MenuOption option) {
    return InkWell(
      onTap: () {
        Navigator.pop(context); // Fermer le menu
        option.onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: option.color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: option.color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              option.icon,
              color: option.color,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              option.label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: AppColors.textColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoreMenuItem(
    BuildContext context,
    IconData icon,
    String label,
    VoidCallback onTap,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: AppColors.primaryColor,
        size: 28,
      ),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.textColor,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        color: AppColors.textLightColor,
        size: 16,
      ),
      onTap: () {
        Navigator.pop(context); // Fermer le menu
        onTap();
      },
    );
  }
}

/// Classe pour les options du menu en grille
class MenuOption {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  MenuOption({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });
}