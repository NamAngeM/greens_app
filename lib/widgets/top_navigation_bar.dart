import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';

class TopNavigationBar extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const TopNavigationBar({
    Key? key,
    required this.currentIndex,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(context, Icons.home_outlined, 0, 'Home'),
          _buildNavItem(context, Icons.menu_book_outlined, 1, 'Articles'),
          _buildCenterLogo(context),
          _buildNavItem(context, Icons.shopping_bag_outlined, 3, 'Produits'),
          _buildNavItem(context, Icons.person_outline, 4, 'Profile'),
          _buildNavItem(context, Icons.more_horiz, 5, 'Plus'),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index, String label) {
    final bool isSelected = currentIndex == index;
    final Color color = isSelected ? AppColors.secondaryColor : Colors.grey;

    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!(index);
        } else {
          _handleNavigation(context, index);
        }
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: color,
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 10,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCenterLogo(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!(2);
        } else {
          _handleNavigation(context, 2);
        }
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: const BoxDecoration(
          color: AppColors.secondaryColor,
          shape: BoxShape.circle,
        ),
        child: const Center(
          child: Text(
            'g',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  void _handleNavigation(BuildContext context, int index) {
    switch (index) {
      case 0: // Home
        Navigator.pushReplacementNamed(context, AppRoutes.home);
        break;
      case 1: // Articles
        Navigator.pushReplacementNamed(context, AppRoutes.articles);
        break;
      case 2: // Logo central (Chatbot)
        Navigator.pushReplacementNamed(context, AppRoutes.ecoChatbot);
        break;
      case 3: // Produits
        Navigator.pushReplacementNamed(context, AppRoutes.products);
        break;
      case 4: // Profile
        Navigator.pushReplacementNamed(context, AppRoutes.profile);
        break;
      case 5: // Plus
        _showMoreMenu(context);
        break;
    }
  }

  void _showMoreMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
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
            _buildMenuItem(
              context,
              Icons.settings,
              'Paramètres',
              () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
            const Divider(),
            _buildMenuItem(
              context,
              Icons.eco,
              'Objectifs écologiques',
              () => Navigator.pushNamed(context, AppRoutes.goals),
            ),
            const Divider(),
            _buildMenuItem(
              context,
              Icons.dashboard,
              'Tableau de bord carbone',
              () => Navigator.pushNamed(context, AppRoutes.carbonDashboard),
            ),
            const Divider(),
            _buildMenuItem(
              context,
              Icons.help_outline,
              'Aide et support',
              () => Navigator.pushNamed(context, AppRoutes.help),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
    );
  }
} 