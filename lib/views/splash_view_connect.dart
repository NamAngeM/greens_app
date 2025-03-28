import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_router.dart';

import '../utils/app_router.dart';

class SplashViewConnect extends StatefulWidget {
  const SplashViewConnect({Key? key}) : super(key: key);

  @override
  State<SplashViewConnect> createState() => _SplashViewConnectState();
}

class _SplashViewConnectState extends State<SplashViewConnect> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Image de fond de montagne
          Image.asset(
            'assets/images/backgrounds/mountain_background.png',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            // Utiliser une couleur de fond si l'image n'est pas disponible
            errorBuilder: (context, error, stackTrace) => Container(
              color: const Color(0xFF1E3246),
            ),
          ),
          
          // Overlay semi-transparent pour améliorer la lisibilité
          Container(
            color: Colors.black.withOpacity(0.3),
          ),
          
          // Contenu principal
          SafeArea(
            child: Column(
              children: [
                const Spacer(flex: 2),
                
                // Logo
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Image.asset(
                          'assets/images/logo/green_minds_logo.png',
                          height: 420,
                          // Utiliser une icône par défaut si le logo n'est pas disponible
                          errorBuilder: (context, error, stackTrace) => 
                              const Icon(Icons.eco, size: 120, color: Colors.white),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 0.1), // Remplace le Spacer par un espace fixe de 20 pixels,
                
                // Texte "Step into a greener future"
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 40),
                        child: Text(
                          'Step into a\ngreener future',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'RethinkSans',
                            height: 1.2,
                          ),
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 50 ),
                
                // Bouton "Log in"
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40),
                        child: SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, AppRoutes.login);
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.2),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text(
                              'Log in',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                fontFamily: 'RethinkSans',
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 20),
                
                // Lien "Create a new account"
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.signup);
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white,
                        ),
                        child: const Text(
                          'Create a new account',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            fontFamily: 'RethinkSans',
                          ),
                        ),
                      ),
                    );
                  },
                ),
                
                const Spacer(flex: 2),
                
                // Texte GreenMinds en bas
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: const Padding(
                        padding: EdgeInsets.only(bottom: 16),
                        child: Text(
                          'GreenMinds',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}