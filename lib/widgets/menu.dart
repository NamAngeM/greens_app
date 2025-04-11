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
    return Container(
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
        Navigator.pushNamed(context, AppRoutes.chatbot);
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
              Icons.more_horiz,
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
          color: AppColors.cardColor,
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
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Section Empreinte Carbone
                    _buildMoreMenuItem(
                      context,
                      Icons.calculate,
                      'Calculateur d\'empreinte carbone',
                      () => Navigator.pushNamed(context, AppRoutes.carbonCalculator),
                    ),
                    const Divider(),
                    _buildMoreMenuItem(
                      context,
                      Icons.bar_chart,
                      'Tableau de bord carbone',
                      () => Navigator.pushNamed(context, AppRoutes.carbonDashboard),
                    ),
                    const Divider(),
                    // Section Objectifs et Défis
                    _buildMoreMenuItem(
                      context,
                      Icons.eco,
                      'Objectifs écologiques',
                      () => Navigator.pushNamed(context, AppRoutes.goals),
                    ),
                    const Divider(),
                    _buildMoreMenuItem(
                      context,
                      Icons.people,
                      'Défis communautaires',
                      () => Navigator.pushNamed(context, AppRoutes.community),
                    ),
                    const Divider(),
                    // Section Scanner
                    _buildMoreMenuItem(
                      context,
                      Icons.qr_code_scanner,
                      'Scanner de produits',
                      () => Navigator.pushNamed(context, AppRoutes.productScanner),
                    ),
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