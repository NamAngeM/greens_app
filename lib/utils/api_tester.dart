import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'domain_manager.dart';

/// Classe utilitaire pour tester la disponibilité de l'API et des produits
class ApiTester {
  /// Teste la disponibilité de l'API sur tous les domaines configurés
  static Future<Map<String, bool>> testAllDomains() async {
    Map<String, bool> results = {};
    
    for (String domain in DomainManager.domains) {
      try {
        final response = await http.get(
          Uri.parse('$domain/api/products'),
          headers: {'Accept': 'application/json'},
        ).timeout(const Duration(seconds: 5));
        
        results[domain] = response.statusCode == 200;
        print('Test domaine $domain: ${response.statusCode == 200 ? 'OK' : 'ÉCHEC (${response.statusCode})'}');
      } catch (e) {
        results[domain] = false;
        print('Test domaine $domain: ERREUR ($e)');
      }
    }
    
    return results;
  }
  
  /// Récupère et affiche les produits depuis le nouveau domaine principal
  static Future<List<dynamic>?> fetchAndDisplayProducts({bool verbose = true}) async {
    try {
      // Utiliser le nouveau domaine pour l'API
      final response = await http.get(
        Uri.parse('${DomainManager.domains.first}/api/products'),
        headers: {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 10));
      
      if (response.statusCode == 200) {
        final List<dynamic> products = json.decode(response.body);
        
        if (verbose) {
          print('Nombre de produits trouvés: ${products.length}');
          
          // Afficher les détails de chaque produit
          for (var product in products) {
            print('ID: ${product['id']}');
            print('Nom: ${product['name']}');
            print('Prix: ${product['price']} €');
            print('Description: ${product['shortDescription'] ?? product['description']}');
            print('------------------------');
          }
        }
        
        return products;
      } else {
        print('Erreur lors de la récupération des produits: ${response.statusCode}');
        print('Réponse: ${response.body}');
        return null;
      }
    } catch (e) {
      print('Exception lors de la récupération des produits: $e');
      return null;
    }
  }
  
  /// Affiche un dialogue de test des domaines dans l'application
  static Future<void> showDomainTestDialog(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test des domaines'),
        content: FutureBuilder<Map<String, bool>>(
          future: testAllDomains(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const SizedBox(
                height: 100,
                child: Center(child: CircularProgressIndicator()),
              );
            }
            
            if (snapshot.hasError) {
              return Text('Erreur: ${snapshot.error}');
            }
            
            final results = snapshot.data ?? {};
            
            return SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var domain in results.keys)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            results[domain]! ? Icons.check_circle : Icons.error,
                            color: results[domain]! ? Colors.green : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              domain,
                              style: TextStyle(
                                color: results[domain]! ? Colors.black : Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 16),
                  const Text(
                    'Résultats des tests de domaines. Un domaine fonctionnel est nécessaire pour accéder aux produits.',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            );
          },
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Fermer'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              fetchAndDisplayProducts();
            },
            child: const Text('Tester les produits'),
          ),
        ],
      ),
    );
  }
}
