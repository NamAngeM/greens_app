import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/app_router.dart';

class SplashView extends StatefulWidget {
  const SplashView({Key? key}) : super(key: key);

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
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
    
    // Naviguer vers l'écran suivant après l'animation
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Rediriger vers splash_view_connect.dart après 2 secondes
        Future.delayed(const Duration(milliseconds: 2000), () {
          if (mounted) {
            Navigator.pushReplacementNamed(context, AppRoutes.splashConnect);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3246), // Couleur bleu foncé comme dans l'image
      body: SafeArea(
        child: Stack(
          children: [
            // Logo centré
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: Transform.scale(
                      scale: _scaleAnimation.value,
                      child: Image.asset(
                        'assets/images/logo/green_minds_logo.png',
                        height: 800,
                        // Utiliser une image par défaut si le logo n'est pas disponible
                        errorBuilder: (context, error, stackTrace) => 
                            const Icon(Icons.eco, size: 150, color: Colors.white),
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Texte GreenMinds en bas
            Positioned(
              bottom: 30,
              left: 0,
              right: 0,
              child: Center(
                child: AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Opacity(
                      opacity: _fadeAnimation.value,
                      child: const Text(
                        'GreenMinds',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
