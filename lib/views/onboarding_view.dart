// lib/views/onboarding_view.dart
import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_styles.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingView extends StatefulWidget {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  _OnboardingViewState createState() => _OnboardingViewState();
}

class _OnboardingViewState extends State<OnboardingView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final int _numPages = 4;

  final List<Map<String, dynamic>> _pages = [
    {
      'title': 'Bienvenue dans votre parcours écologique',
      'description': 'Découvrez comment réduire votre empreinte carbone et contribuer à un monde plus durable.',
      'image': 'assets/images/onboarding_welcome.png',
      'color': Color(0xFF4CAF50),
    },
    {
      'title': 'Fixez vos objectifs écologiques',
      'description': 'Créez des objectifs personnalisés pour l\'eau, l\'énergie, les déchets, le transport et l\'alimentation.',
      'image': 'assets/images/onboarding_goals.png',
      'color': Color(0xFF2196F3),
    },
    {
      'title': 'Rejoignez des défis communautaires',
      'description': 'Amplifiez votre impact en participant à des défis avec d\'autres personnes engagées.',
      'image': 'assets/images/onboarding_community.png',
      'color': Color(0xFFFF9800),
    },
    {
      'title': 'Suivez votre progression',
      'description': 'Visualisez votre impact écologique et gagnez des badges pour vos accomplissements.',
      'image': 'assets/images/onboarding_progress.png',
      'color': Color(0xFF9C27B0),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              _pages[_currentPage]['color'],
              _pages[_currentPage]['color'].withOpacity(0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (int page) {
                    setState(() {
                      _currentPage = page;
                    });
                  },
                  itemCount: _numPages,
                  itemBuilder: (context, index) {
                    return _buildPage(
                      title: _pages[index]['title'],
                      description: _pages[index]['description'],
                      image: _pages[index]['image'],
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Indicateurs de page
                    Row(
                      children: List.generate(
                        _numPages,
                        (index) => _buildDotIndicator(index),
                      ),
                    ),
                    // Bouton suivant ou commencer
                    _currentPage == _numPages - 1
                        ? ElevatedButton(
                            onPressed: _onGetStarted,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: _pages[_currentPage]['color'],
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            child: const Text(
                              'Commencer',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : IconButton(
                            icon: const Icon(
                              Icons.arrow_forward,
                              size: 30,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              _pageController.nextPage(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            },
                          ),
                  ],
                ),
              ),
              // Bouton passer
              if (_currentPage < _numPages - 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 24.0),
                  child: Center(
                    child: TextButton(
                      onPressed: _onGetStarted,
                      child: const Text(
                        'Passer',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage({
    required String title,
    required String description,
    required String image,
  }) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            image,
            height: 240,
          ),
          const SizedBox(height: 40),
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDotIndicator(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      height: 8,
      width: _currentPage == index ? 24 : 8,
      decoration: BoxDecoration(
        color: _currentPage == index ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  void _onGetStarted() async {
    // Marquer l'onboarding comme terminé
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    
    // Naviguer vers l'écran principal
    Navigator.pushReplacementNamed(context, AppRoutes.home);
  }
}