import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:greens_app/models/carbon_footprint_model.dart';
import 'package:greens_app/services/auth_service.dart';

class CarbonFootprintService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();

  // Méthode pour calculer l'empreinte carbone
  Future<CarbonFootprintModel> calculateCarbonFootprint({
    required double transportScore,
    required double energyScore,
    required double foodScore,
    required double consumptionScore,
    required double digitalScore,
    required Map<String, dynamic> details,
  }) async {
    try {
      final user = await _authService.getCurrentUser();
      if (user == null) {
        throw Exception('Utilisateur non connecté');
      }

      // Calcul du score total
      final totalScore = transportScore + energyScore + foodScore + consumptionScore + digitalScore;
      
      // Génération de recommandations basées sur les scores
      final recommendations = _generateRecommendations(
        transportScore: transportScore,
        energyScore: energyScore,
        foodScore: foodScore,
        consumptionScore: consumptionScore,
        digitalScore: digitalScore,
      );
      
      // Calcul des points gagnés (plus le score est bas, plus les points sont élevés)
      final pointsEarned = _calculatePointsEarned(totalScore);
      
      // Création du modèle d'empreinte carbone
      final carbonFootprint = CarbonFootprintModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: user.uid,
        date: DateTime.now(),
        transportScore: transportScore,
        energyScore: energyScore,
        foodScore: foodScore,
        consumptionScore: consumptionScore,
        digitalScore: digitalScore,
        totalScore: totalScore,
        details: details,
        recommendations: recommendations,
        pointsEarned: pointsEarned,
      );
      
      // Enregistrement dans Firestore
      await _saveFootprintToFirestore(carbonFootprint);
      
      // Mise à jour des points de l'utilisateur
      await _authService.updateCarbonPoints(user.uid, pointsEarned);
      
      return carbonFootprint;
    } catch (e) {
      debugPrint('Erreur lors du calcul de l\'empreinte carbone: $e');
      rethrow;
    }
  }

  // Méthode pour enregistrer l'empreinte carbone dans Firestore
  Future<void> _saveFootprintToFirestore(CarbonFootprintModel footprint) async {
    try {
      await _firestore
          .collection('carbon_footprints')
          .doc(footprint.id)
          .set(footprint.toJson());
    } catch (e) {
      debugPrint('Erreur lors de l\'enregistrement de l\'empreinte carbone: $e');
      rethrow;
    }
  }

  // Méthode publique pour sauvegarder une empreinte carbone
  Future<bool> saveFootprint(CarbonFootprintModel footprint) async {
    try {
      // Si l'utilisateur n'est pas défini, récupérer l'utilisateur actuel
      if (footprint.userId.isEmpty) {
        final user = await _authService.getCurrentUser();
        if (user == null) {
          throw Exception('Utilisateur non connecté');
        }
        footprint = footprint.copyWith(userId: user.uid);
      }
      
      // Sauvegarder dans Firestore
      await _saveFootprintToFirestore(footprint);
      
      // Mettre à jour les points de l'utilisateur
      await _authService.updateCarbonPoints(footprint.userId, footprint.pointsEarned);
      
      return true;
    } catch (e) {
      debugPrint('Erreur lors de la sauvegarde de l\'empreinte carbone: $e');
      return false;
    }
  }

  // Méthode pour récupérer l'historique des empreintes carbone d'un utilisateur
  Future<List<CarbonFootprintModel>> getUserFootprintHistory(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('carbon_footprints')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => CarbonFootprintModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'historique: $e');
      return [];
    }
  }

  // Méthode pour générer des recommandations basées sur les scores
  List<String> _generateRecommendations({
    required double transportScore,
    required double energyScore,
    required double foodScore,
    required double consumptionScore,
    required double digitalScore,
  }) {
    final recommendations = <String>[];
    
    if (transportScore > 3) {
      recommendations.add('Essayez d\'utiliser les transports en commun ou le vélo pour vos déplacements quotidiens.');
    }
    
    if (energyScore > 3) {
      recommendations.add('Réduisez votre consommation d\'énergie en éteignant les appareils non utilisés et en optant pour des ampoules LED.');
    }
    
    if (foodScore > 3) {
      recommendations.add('Privilégiez une alimentation locale et de saison, et réduisez votre consommation de viande.');
    }
    
    if (consumptionScore > 3) {
      recommendations.add('Favorisez les produits durables et réparables, et limitez les achats impulsifs.');
    }
    
    if (digitalScore > 3) {
      recommendations.add('Réduisez votre consommation numérique en désactivant les notifications inutiles et en utilisant des applications éco-responsables.');
    }
    
    return recommendations;
  }

  // Méthode pour calculer les points gagnés
  int _calculatePointsEarned(double totalScore) {
    // Plus le score est bas, plus les points sont élevés
    if (totalScore < 5) {
      return 100;
    } else if (totalScore < 10) {
      return 75;
    } else if (totalScore < 15) {
      return 50;
    } else {
      return 25;
    }
  }
}
