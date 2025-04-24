import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greens_app/services/auth_service.dart';
import 'package:greens_app/utils/app_router.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  RouteSettings? redirect(String? route) {
    final authService = Get.find<AuthService>();
    
    // Si l'utilisateur n'est pas connecté, rediriger vers la page de connexion
    if (authService.currentUser == null) {
      return const RouteSettings(name: AppRouter.login);
    }
    
    // Si l'utilisateur est connecté, permettre l'accès à la route demandée
    return null;
  }
} 