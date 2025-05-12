import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DomainManager {
  // Liste des domaines disponibles, par ordre de priorité
  static final List<String> domains = [
    'https://green-commerce-gamma.vercel.app', // Nouveau domaine principal
    'https://green-commerce-ecg15tmtx-nams-projects-08436685.vercel.app',
    'https://green-commerce-m4wttggxd-nams-projects-08436685.vercel.app',
    // Ajouter ici le domaine de production quand disponible
    // 'https://green-commerce.vercel.app',
  ];
  
  // Domaine actuellement utilisé (par défaut le premier)
  static String? _currentDomain;
  
  // Récupérer le domaine actuel avec fallback
  static String get currentDomain {
    return _currentDomain ?? domains.first;
  }
  
  // Récupérer l'URL de base de l'API
  static String get apiBaseUrl => '$currentDomain/api';
  
  // Initialiser le gestionnaire de domaines
  static Future<void> initialize() async {
    // Rechercher un domaine fonctionnel
    await findWorkingDomain();
  }
  
  // Trouver un domaine fonctionnel
  static Future<bool> findWorkingDomain() async {
    for (String domain in domains) {
      try {
        final response = await http.head(Uri.parse('$domain/produit/1'))
            .timeout(const Duration(seconds: 3));
        
        if (response.statusCode < 400) {
          _currentDomain = domain;
          print('Domaine fonctionnel trouvé: $_currentDomain');
          return true;
        }
      } catch (e) {
        print('Échec de connexion à $domain: $e');
        // Ce domaine ne répond pas, essayer le suivant
      }
    }
    print('Aucun domaine fonctionnel trouvé');
    return false;
  }
  
  // Ouvrir l'URL d'un produit avec gestion des erreurs
  static Future<bool> openProductUrl(String productId, {BuildContext? context}) async {
    // Si nous n'avons pas encore de domaine fonctionnel, essayer d'en trouver un
    if (_currentDomain == null) {
      await findWorkingDomain();
    }
    
    bool success = false;
    String? errorMessage;
    
    // Extraire l'ID numérique si possible
    String numericId = productId.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericId.isEmpty) {
      numericId = '1'; // Fallback sur l'ID 1 si aucun ID numérique n'est trouvé
    }
    
    // Essayer les domaines, en commençant par le domaine actuel
    List<String> orderedDomains = [...domains];
    if (_currentDomain != null) {
      // Mettre le domaine actuel en premier
      orderedDomains.remove(_currentDomain);
      orderedDomains.insert(0, _currentDomain!);
    }
    
    for (String domain in orderedDomains) {
      String url = '$domain/produit/$numericId';
      try {
        print('Tentative d\'ouverture de l\'URL: $url');
        // Vérifier si l'URL est accessible
        final response = await http.head(Uri.parse(url))
            .timeout(const Duration(seconds: 3));
        
        if (response.statusCode < 400) {
          // Mettre à jour le domaine actuel
          _currentDomain = domain;
          
          // Ouvrir l'URL
          final uri = Uri.parse(url);
          if (await canLaunchUrl(uri)) {
            print('Lancement de l\'URL: $url');
            final result = await launchUrl(
              uri,
              mode: LaunchMode.externalApplication,
            );
            
            if (result) {
              success = true;
              break;
            } else {
              errorMessage = 'Impossible de lancer l\'URL: $url';
            }
          } else {
            errorMessage = 'URL non supportée: $url';
          }
        } else {
          errorMessage = 'URL inaccessible (${response.statusCode}): $url';
        }
      } catch (e) {
        errorMessage = e.toString();
        print('Erreur lors de l\'ouverture de l\'URL: $url - $e');
        // Continuer avec le prochain domaine
      }
    }
    
    // Si aucun domaine n'a fonctionné et que nous avons un contexte
    if (!success && context != null && errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible d\'ouvrir le site marchand: $errorMessage'),
          backgroundColor: Colors.red,
          action: SnackBarAction(
            label: 'Réessayer',
            onPressed: () => openProductUrl(productId, context: context),
          ),
        ),
      );
    }
    
    return success;
  }
  
  // Obtenir l'URL d'un produit (sans l'ouvrir)
  static Future<String?> getProductUrl(String productId) async {
    // Si nous n'avons pas encore de domaine fonctionnel, essayer d'en trouver un
    if (_currentDomain == null) {
      await findWorkingDomain();
    }
    
    // Extraire l'ID numérique si possible
    String numericId = productId.replaceAll(RegExp(r'[^0-9]'), '');
    if (numericId.isEmpty) {
      numericId = '1'; // Fallback sur l'ID 1 si aucun ID numérique n'est trouvé
    }
    
    if (_currentDomain != null) {
      return '$_currentDomain/produit/$numericId';
    }
    
    return null;
  }
}
