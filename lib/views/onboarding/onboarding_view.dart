import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/widgets/custom_button.dart';

import '../../utils/app_colors.dart';
import '../../utils/app_router.dart';
import '../../widgets/custom_button.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  State<OnboardingView> createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  
  final List<Map<String, dynamic>> _onboardingData = [
    {
      'title': 'Bienvenue sur Greens App',
      'description': 'Votre compagnon pour un mode de vie plus écologique et durable.',
      'image': 'assets/images/onboarding1.png',
      'icon': Icons.eco,
    },
    {
      'title': 'Calculez votre empreinte carbone',
      'description': 'Mesurez votre impact sur l\'environnement et recevez des conseils personnalisés.',
      'image': 'assets/images/onboarding2.png',
      'icon': Icons.calculate,
    },
    {
      'title': 'Gagnez des récompenses',
      'description': 'Obtenez des points et échangez-les contre des coupons de réduction sur des produits écologiques.',
      'image': 'assets/images/onboarding3.png',
      'icon': Icons.card_giftcard,
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _onboardingData.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacementNamed(context, AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _onboardingData.length,
                onPageChanged: (index) {
                  setState(() {
                    _currentPage = index;
                  });
                },
                itemBuilder: (context, index) {
                  return OnboardingPage(
                    title: _onboardingData[index]['title'],
                    description: _onboardingData[index]['description'],
                    image: _onboardingData[index]['image'],
                    icon: _onboardingData[index]['icon'],
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Indicateurs de page
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      _onboardingData.length,
                      (index) => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4.0),
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _currentPage == index
                              ? AppColors.primaryColor
                              : AppColors.textLightColor.withOpacity(0.3),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  // Bouton suivant ou commencer
                  CustomButton(
                    text: _currentPage < _onboardingData.length - 1
                        ? 'Suivant'
                        : 'Commencer',
                    onPressed: _nextPage,
                  ),
                  
                  // Bouton passer
                  if (_currentPage < _onboardingData.length - 1)
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacementNamed(context, AppRoutes.home);
                      },
                      child: const Text(
                        'Passer',
                        style: TextStyle(
                          color: AppColors.textLightColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final String title;
  final String description;
  final String image;
  final IconData icon;

  const OnboardingPage({
    Key? key,
    required this.title,
    required this.description,
    required this.image,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image ou icône
          Image.asset(
            image,
            height: 240,
            errorBuilder: (context, error, stackTrace) => Icon(
              icon,
              size: 120,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 40),
          
          // Titre
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          
          // Description
          Text(
            description,
            style: const TextStyle(
              fontSize: 16,
              color: AppColors.textLightColor,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
