import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';

class BottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;

  const BottomNavigation({
    Key? key,
    this.currentIndex = 0,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildNavItem(context, Icons.home_filled, 0),
          _buildNavItem(context, Icons.book_outlined, 1),
          // Espace pour le bouton central
          const SizedBox(width: 50),
          _buildNavItem(context, Icons.shopping_bag_outlined, 3),
          _buildNavItem(context, Icons.person_outline, 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(BuildContext context, IconData icon, int index) {
    final bool isSelected = currentIndex == index;
    final Color itemColor = isSelected ? AppColors.primaryColor : Colors.grey;
    
    return InkWell(
      onTap: () {
        if (onTap != null) {
          onTap!(index);
        }
      },
      child: SizedBox(
        width: 40,
        child: Icon(
          icon,
          size: 24,
          color: itemColor,
        ),
      ),
    );
  }
}

class CenterLogoButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isSelected;
  
  const CenterLogoButton({
    Key? key, 
    this.onTap,
    this.isSelected = false,
  }) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: -20,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
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
          child: const Center(
            child: Text(
              'g',
              style: TextStyle(
                color: Colors.white,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class BottomNavWithFloatingLogo extends StatelessWidget {
  final int currentIndex;
  final Function(int)? onTap;
  final VoidCallback? onLogoTap;

  const BottomNavWithFloatingLogo({
    Key? key,
    this.currentIndex = 0,
    this.onTap,
    this.onLogoTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Le bouton central a l'index 2
    final bool isLogoSelected = currentIndex == 2;
    
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.bottomCenter,
      children: [
        BottomNavigation(
          currentIndex: currentIndex,
          onTap: onTap,
        ),
        CenterLogoButton(
          onTap: () {
            if (onTap != null) {
              onTap!(2); // Index 2 pour le bouton central
            }
            if (onLogoTap != null) {
              onLogoTap!();
            }
          },
          isSelected: isLogoSelected,
        ),
      ],
    );
  }
}

// Ce widget ajoute le bouton "Plus" qui pourra être affiché séparément
class MoreButton extends StatelessWidget {
  final VoidCallback? onTap;
  
  const MoreButton({Key? key, this.onTap}) : super(key: key);
  
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.more_horiz,
            size: 24,
            color: Colors.grey,
          ),
          SizedBox(height: 4),
          Text(
            'Plus',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
} 