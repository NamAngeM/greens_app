import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Classe utilitaire pour lancer des URLs externes de manière fiable
class UrlLauncherHelper {
  /// Lance une URL externe avec plusieurs tentatives et modes de lancement
  static Future<bool> launchUrlWithFallback(
    String url, {
    BuildContext? context,
    bool showErrorMessage = true,
  }) async {
    bool success = false;
    String? errorMessage;
    
    // Nettoyer l'URL
    url = url.trim();
    
    // Vérifier si l'URL est valide
    if (!url.startsWith('http://') && !url.startsWith('https://')) {
      url = 'https://$url';
    }
    
    print('Tentative de lancement de l\'URL: $url');
    
    try {
      final uri = Uri.parse(url);
      
      // Essayer d'abord avec LaunchMode.externalApplication
      if (await canLaunchUrl(uri)) {
        try {
          print('Lancement avec mode: externalApplication');
          success = await launchUrl(
            uri,
            mode: LaunchMode.externalApplication,
          );
        } catch (e) {
          print('Erreur lors du lancement en mode externalApplication: $e');
        }
        
        // Si cela échoue, essayer avec LaunchMode.platformDefault
        if (!success) {
          try {
            print('Lancement avec mode: platformDefault');
            success = await launchUrl(
              uri,
              mode: LaunchMode.platformDefault,
            );
          } catch (e) {
            print('Erreur lors du lancement en mode platformDefault: $e');
          }
        }
        
        // Si cela échoue également, essayer avec inAppWebView
        if (!success) {
          try {
            print('Lancement avec mode: inAppWebView');
            success = await launchUrl(
              uri,
              mode: LaunchMode.inAppWebView,
            );
          } catch (e) {
            print('Erreur lors du lancement en mode inAppWebView: $e');
            errorMessage = e.toString();
          }
        }
      } else {
        errorMessage = 'Impossible de lancer l\'URL: $url';
        print(errorMessage);
      }
    } catch (e) {
      errorMessage = 'URL invalide: $e';
      print(errorMessage);
    }
    
    // Afficher un message d'erreur si demandé et si un contexte est fourni
    if (!success && showErrorMessage && context != null && errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'ouvrir l\'URL: $url\n$errorMessage'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
          action: SnackBarAction(
            label: 'Réessayer',
            onPressed: () => launchUrlWithFallback(url, context: context),
          ),
        ),
      );
    }
    
    return success;
  }
}
