// Fichier: lib/services/community_impact_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/community_challenge_model.dart';
import 'package:greens_app/models/carbon_footprint_model.dart';
import 'package:greens_app/controllers/carbon_footprint_controller.dart';
import 'package:greens_app/controllers/community_controller.dart';
import 'package:flutter/material.dart';

class CommunityImpactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CarbonFootprintController _carbonFootprintController;
  CommunityController? _communityController;
  
  CommunityImpactService(this._carbonFootprintController, this._communityController);
  
  // Méthode pour définir le CommunityController après l'initialisation
  void setCommunityController(CommunityController controller) {
    _communityController = controller;
  }
  
  // Méthode pour calculer l'impact collectif d'un défi communautaire
  Future<Map<String, dynamic>> calculateChallengeImpact(String challengeId) async {
    try {
      // Récupérer le défi
      final challenge = _communityController!.challenges
          .firstWhere((c) => c.id == challengeId, orElse: () => null as CommunityChallenge);
      
      if (challenge == null) return {'totalImpact': 0, 'participantsCount': 0};
      
      // Récupérer les contributions des participants
      final snapshot = await _firestore
          .collection('challenge_contributions')
          .where('challengeId', isEqualTo: challengeId)
          .get();
      
      double totalCarbonSaved = 0;
      int contributionsCount = 0;
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalCarbonSaved += (data['carbonSaved'] as num).toDouble();
        contributionsCount++;
      }
      
      // Calculer l'impact moyen par participant
      double averageImpact = challenge.participantsCount > 0 
          ? totalCarbonSaved / challenge.participantsCount 
          : 0;
      
      // Calculer des métriques environnementales supplémentaires
      final arbresPlantes = totalCarbonSaved / 20; // Un arbre absorbe environ 20kg de CO2 par an
      final litresEauEconomises = totalCarbonSaved * 100; // Estimation: 100L d'eau économisés par kg de CO2
      final dechetsEvites = totalCarbonSaved / 2; // Estimation: 0.5kg de déchets évités par kg de CO2
      
      return {
        'totalCarbonSaved': totalCarbonSaved,
        'contributionsCount': contributionsCount,
        'participantsCount': challenge.participantsCount,
        'averageImpact': averageImpact,
        'targetParticipants': challenge.targetParticipants,
        'completionPercentage': challenge.participantsCount / challenge.targetParticipants * 100,
        'arbresPlantes': arbresPlantes,
        'litresEauEconomises': litresEauEconomises,
        'dechetsEvites': dechetsEvites,
      };
    } catch (e) {
      print('Error calculating challenge impact: $e');
      return {
        'totalCarbonSaved': 0,
        'contributionsCount': 0,
        'participantsCount': 0,
        'averageImpact': 0,
        'targetParticipants': 0,
        'completionPercentage': 0,
        'arbresPlantes': 0,
        'litresEauEconomises': 0,
        'dechetsEvites': 0,
      };
    }
  }
  
  // Méthode pour enregistrer une contribution à un défi
  Future<bool> recordChallengeContribution(
    String challengeId, 
    String userId, 
    double carbonSaved, 
    String activityDescription
  ) async {
    try {
      await _firestore.collection('challenge_contributions').add({
        'challengeId': challengeId,
        'userId': userId,
        'carbonSaved': carbonSaved,
        'activityDescription': activityDescription,
        'timestamp': FieldValue.serverTimestamp(),
      });
      
      // Mettre à jour les statistiques du défi
      await _firestore.collection('community_challenges').doc(challengeId).update({
        'progress.totalCarbonSaved': FieldValue.increment(carbonSaved),
        'progress.contributionsCount': FieldValue.increment(1),
      });
      
      return true;
    } catch (e) {
      print('Error recording challenge contribution: $e');
      return false;
    }
  }
  
  // Méthode pour obtenir l'historique des contributions d'un utilisateur
  Future<List<Map<String, dynamic>>> getUserChallengeContributions(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('challenge_contributions')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .get();
      
      List<Map<String, dynamic>> contributions = [];
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        
        // Récupérer les informations du défi
        final challengeId = data['challengeId'] as String;
        final challenge = _communityController!.challenges
            .firstWhere((c) => c.id == challengeId, orElse: () => null as CommunityChallenge);
        
        if (challenge != null) {
          contributions.add({
            'id': doc.id,
            'challengeId': challengeId,
            'challengeTitle': challenge.title,
            'carbonSaved': data['carbonSaved'],
            'activityDescription': data['activityDescription'],
            'timestamp': (data['timestamp'] as Timestamp).toDate(),
          });
        }
      }
      
      return contributions;
    } catch (e) {
      print('Error getting user challenge contributions: $e');
      return [];
    }
  }
  
  // Méthode pour calculer l'impact total des défis communautaires
  Future<Map<String, dynamic>> calculateTotalCommunityImpact() async {
    try {
      final snapshot = await _firestore
          .collection('challenge_contributions')
          .get();
      
      double totalCarbonSaved = 0;
      int totalContributions = 0;
      Set<String> uniqueParticipants = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalCarbonSaved += (data['carbonSaved'] as num).toDouble();
        totalContributions++;
        uniqueParticipants.add(data['userId'] as String);
      }
      
      // Calculer des métriques environnementales supplémentaires
      final arbresPlantes = totalCarbonSaved / 20; // Un arbre absorbe environ 20kg de CO2 par an
      final litresEauEconomises = totalCarbonSaved * 100; // Estimation: 100L d'eau économisés par kg de CO2
      final dechetsEvites = totalCarbonSaved / 2; // Estimation: 0.5kg de déchets évités par kg de CO2
      final kmVoitureEvites = totalCarbonSaved * 4; // Estimation: 4km en voiture = 1kg de CO2
      
      // Calculer l'évolution mensuelle (exemple avec des données simulées)
      // Dans une application réelle, ces données viendraient de la base de données
      final List<Map<String, dynamic>> monthlyImpact = await getMonthlyImpactData();
      
      return {
        'totalCarbonSaved': totalCarbonSaved,
        'totalContributions': totalContributions,
        'uniqueParticipants': uniqueParticipants.length,
        'averageImpactPerParticipant': uniqueParticipants.isNotEmpty 
            ? totalCarbonSaved / uniqueParticipants.length 
            : 0,
        'arbresPlantes': arbresPlantes,
        'litresEauEconomises': litresEauEconomises,
        'dechetsEvites': dechetsEvites,
        'kmVoitureEvites': kmVoitureEvites,
        'monthlyImpact': monthlyImpact,
      };
    } catch (e) {
      print('Error calculating total community impact: $e');
      return {
        'totalCarbonSaved': 0,
        'totalContributions': 0,
        'uniqueParticipants': 0,
        'averageImpactPerParticipant': 0,
        'arbresPlantes': 0,
        'litresEauEconomises': 0,
        'dechetsEvites': 0,
        'kmVoitureEvites': 0,
        'monthlyImpact': [],
      };
    }
  }
  
  // Méthode pour obtenir les données d'évolution mensuelle réelles
  Future<List<Map<String, dynamic>>> getMonthlyImpactData() async {
    try {
      // Obtenir la date actuelle
      final now = DateTime.now();
      final sixMonthsAgo = DateTime(now.year, now.month - 6, now.day);
      
      // Récupérer les contributions des 6 derniers mois
      final snapshot = await _firestore
          .collection('challenge_contributions')
          .where('timestamp', isGreaterThanOrEqualTo: sixMonthsAgo)
          .orderBy('timestamp')
          .get();
      
      // Regrouper les contributions par mois
      Map<String, double> monthlyData = {};
      
      for (var doc in snapshot.docs) {
        final data = doc.data();
        final timestamp = data['timestamp'] as Timestamp;
        final date = timestamp.toDate();
        final monthKey = '${date.year}-${date.month.toString().padLeft(2, '0')}';
        
        final carbonSaved = (data['carbonSaved'] as num).toDouble();
        monthlyData[monthKey] = (monthlyData[monthKey] ?? 0) + carbonSaved;
      }
      
      // Convertir en liste formatée pour l'affichage
      List<Map<String, dynamic>> result = [];
      
      // Liste des noms de mois en français
      final monthNames = [
        'Jan', 'Fév', 'Mar', 'Avr', 'Mai', 'Juin',
        'Juil', 'Août', 'Sep', 'Oct', 'Nov', 'Déc'
      ];
      
      // Ajouter les données pour chaque mois des 6 derniers mois
      for (int i = 0; i < 6; i++) {
        final month = now.month - i;
        final year = now.year - (month <= 0 ? 1 : 0);
        final adjustedMonth = month <= 0 ? month + 12 : month;
        
        final monthKey = '${year}-${adjustedMonth.toString().padLeft(2, '0')}';
        final monthName = monthNames[adjustedMonth - 1];
        
        result.add({
          'month': monthName,
          'carbonSaved': monthlyData[monthKey] ?? 0.0,
        });
      }
      
      // Inverser pour avoir l'ordre chronologique
      return result.reversed.toList();
    } catch (e) {
      print('Error getting monthly impact data: $e');
      return _calculateMonthlyImpact(); // Retourner des données simulées en cas d'erreur
    }
  }
  
  // Méthode pour calculer l'évolution mensuelle de l'impact
  // Dans une application réelle, cette méthode interrogerait la base de données
  // pour obtenir les données réelles par mois
  List<Map<String, dynamic>> _calculateMonthlyImpact() {
    // Données simulées pour l'exemple
    return [
      {'month': 'Jan', 'carbonSaved': 12.5},
      {'month': 'Fév', 'carbonSaved': 18.2},
      {'month': 'Mar', 'carbonSaved': 25.7},
      {'month': 'Avr', 'carbonSaved': 31.2},
      {'month': 'Mai', 'carbonSaved': 42.8},
      {'month': 'Juin', 'carbonSaved': 51.3},
    ];
  }
}