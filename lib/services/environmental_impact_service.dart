import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greens_app/models/environmental_impact_model.dart';
import 'package:intl/intl.dart';

class EnvironmentalImpactService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  EnvironmentalImpactModel _userImpact = EnvironmentalImpactModel.initial();
  EnvironmentalImpactModel get userImpact => _userImpact;
  
  // Récupère l'impact environnemental d'un utilisateur
  Future<void> getUserImpact(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final carbonDoc = await _firestore.collection('carbon_footprints').doc(userId).get();
      
      if (!userDoc.exists || !carbonDoc.exists) {
        _userImpact = EnvironmentalImpactModel.initial();
        notifyListeners();
        return;
      }
      
      // Récupérer les données de carbone
      final carbonSaved = carbonDoc.data()?['carbonSaved'] ?? 0.0;
      
      // Récupérer l'historique mensuel
      final Map<String, double> monthlyImpact = {};
      final historicData = await _firestore.collection('carbon_history')
          .where('userId', isEqualTo: userId)
          .orderBy('date', descending: true)
          .limit(12)
          .get();
          
      for (var doc in historicData.docs) {
        final date = (doc.data()['date'] as Timestamp).toDate();
        final month = DateFormat('yyyy-MM').format(date);
        final impact = doc.data()['carbonSaved'] ?? 0.0;
        
        monthlyImpact[month] = (monthlyImpact[month] ?? 0.0) + (impact as double);
      }
      
      // Récupérer les données communautaires
      final communityStats = await _firestore.collection('community_stats').doc('global').get();
      final communityCarbonSaved = communityStats.data()?['totalCarbonSaved'] ?? 0.0;
      final communityParticipants = communityStats.data()?['activeUsers'] ?? 0;
      
      // Créer le modèle d'impact
      _userImpact = EnvironmentalImpactModel.fromCarbonSaved(
        carbonSaved: carbonSaved.toDouble(),
        communityCarbonSaved: communityCarbonSaved.toDouble(),
        communityParticipants: communityParticipants,
        monthlyImpact: monthlyImpact,
      );
      
      notifyListeners();
      
    } catch (e) {
      print('Erreur lors de la récupération de l\'impact environnemental: $e');
      _userImpact = EnvironmentalImpactModel.initial();
      notifyListeners();
    }
  }
  
  // Ajoute un impact environnemental après une action écologique
  Future<void> addEnvironmentalImpact(
    String userId, 
    double carbonSaved, 
    String actionType
  ) async {
    try {
      // Récupérer l'impact actuel
      final currentDoc = await _firestore.collection('carbon_footprints').doc(userId).get();
      final currentImpact = currentDoc.exists 
          ? (currentDoc.data()?['carbonSaved'] ?? 0.0) 
          : 0.0;
      
      // Mettre à jour l'impact total
      final newImpact = currentImpact + carbonSaved;
      await _firestore.collection('carbon_footprints').doc(userId).set({
        'carbonSaved': newImpact,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      // Ajouter à l'historique
      await _firestore.collection('carbon_history').add({
        'userId': userId,
        'date': FieldValue.serverTimestamp(),
        'carbonSaved': carbonSaved,
        'actionType': actionType,
      });
      
      // Mettre à jour les statistiques communautaires
      await _firestore.collection('community_stats').doc('global').set({
        'totalCarbonSaved': FieldValue.increment(carbonSaved),
        'actionCount': FieldValue.increment(1),
      }, SetOptions(merge: true));
      
      // Mettre à jour le modèle local
      await getUserImpact(userId);
      
    } catch (e) {
      print('Erreur lors de l\'ajout d\'un impact environnemental: $e');
    }
  }
  
  // Génère un message d'impact environnemental
  String generateImpactMessage() {
    final impact = _userImpact;
    
    if (impact.carbonSaved <= 0) {
      return "Commencez à réaliser des actions écologiques pour voir votre impact sur l'environnement !";
    }
    
    // Sélectionner aléatoirement un type d'impact à mettre en avant
    final random = DateTime.now().millisecondsSinceEpoch % 4;
    
    switch (random) {
      case 0:
        return "Vos actions ont permis de sauver l'équivalent de ${impact.treeEquivalent.toStringAsFixed(1)} arbres !";
      case 1:
        return "Vous avez économisé ${impact.waterSaved.toStringAsFixed(0)} litres d'eau grâce à vos actions écologiques !";
      case 2:
        return "Vos efforts ont évité l'utilisation de ${impact.plasticsAvoided.toStringAsFixed(1)} kg de plastique !";
      default:
        return "Grâce à vous, ${impact.energySaved.toStringAsFixed(0)} kWh d'énergie ont été économisés !";
    }
  }
  
  // Génère un message d'impact communautaire
  String generateCommunityImpactMessage() {
    final impact = _userImpact;
    
    if (impact.communityCarbonSaved <= 0) {
      return "Rejoignez notre communauté écologique et participez à l'effort collectif !";
    }
    
    return "Ensemble, notre communauté de ${impact.communityParticipants} personnes a économisé "
           "${impact.communityCarbonSaved.toStringAsFixed(0)} kg de CO₂, soit "
           "${EnvironmentalImpactModel.calculateTreeEquivalent(impact.communityCarbonSaved).toStringAsFixed(0)} arbres !";
  }
  
  // Calcule l'impact environnemental pour un type d'action spécifique
  double calculateImpactForAction(String actionType) {
    switch (actionType) {
      case 'transport_public':
        return 2.5; // kg CO2 économisés en moyenne
      case 'vegetarian_meal':
        return 1.5;
      case 'reusable_bag':
        return 0.25;
      case 'recycle':
        return 0.5;
      case 'energy_saving':
        return 1.0;
      case 'water_saving':
        return 0.3;
      default:
        return 0.2;
    }
  }
} 