import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/eco_activity.dart' as eco_activity_model;
import 'package:greens_app/services/eco_activity_service.dart';
import 'package:greens_app/services/auth_service.dart';
import 'package:intl/intl.dart';

enum ActivityType { transport, energy, food, waste, water, other }

class QuickAction {
  final String id;
  final String title;
  final String description;
  final double carbonImpact;
  final ActivityType type;
  final IconData icon;

  QuickAction({
    required this.id,
    required this.title,
    required this.description,
    required this.carbonImpact,
    required this.type,
    required this.icon,
  });
}

class EcoActionController extends GetxController {
  final EcoActivityService _ecoActivityService = Get.find<EcoActivityService>();
  final AuthService _authService = Get.find<AuthService>();
  
  final RxBool isLoading = true.obs;
  final RxList<eco_activity_model.EcoActivity> userActivities = <eco_activity_model.EcoActivity>[].obs;
  final RxList<QuickAction> quickActions = <QuickAction>[].obs;
  
  @override
  void onInit() {
    super.onInit();
    loadQuickActions();
    loadUserActivities();
  }
  
  Future<void> loadUserActivities() async {
    isLoading.value = true;
    try {
      final userId = _authService.currentUser?.uid;
      if (userId != null) {
        final activities = await _ecoActivityService.getUserActivities(userId);
        userActivities.value = activities;
      }
    } catch (e) {
      print('Erreur lors du chargement des activités: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> loadQuickActions() async {
    isLoading.value = true;
    try {
      // Dans une version future, ces actions pourraient être récupérées depuis Firestore
      quickActions.value = [
        QuickAction(
          id: 'transport-bike',
          title: 'Vélo au lieu de la voiture',
          description: 'Utiliser le vélo au lieu de la voiture pour un trajet court (<5km)',
          type: ActivityType.transport,
          carbonImpact: 2.5,
          icon: Icons.directions_bike,
        ),
        QuickAction(
          id: 'transport-public',
          title: 'Transport en commun',
          description: 'Prendre les transports en commun au lieu de la voiture',
          type: ActivityType.transport,
          carbonImpact: 1.8,
          icon: Icons.directions_bus,
        ),
        QuickAction(
          id: 'energy-lights',
          title: 'Éteindre les lumières',
          description: 'Éteindre les lumières inutilisées pendant une journée',
          type: ActivityType.energy,
          carbonImpact: 0.3,
          icon: Icons.lightbulb_outline,
        ),
        QuickAction(
          id: 'energy-standby',
          title: 'Éviter le mode veille',
          description: 'Éteindre complètement les appareils au lieu de les laisser en veille',
          type: ActivityType.energy,
          carbonImpact: 0.5,
          icon: Icons.power_settings_new,
        ),
        QuickAction(
          id: 'food-local',
          title: 'Repas local',
          description: 'Préparer un repas avec des ingrédients locaux et de saison',
          type: ActivityType.food,
          carbonImpact: 1.2,
          icon: Icons.restaurant,
        ),
        QuickAction(
          id: 'food-veggie',
          title: 'Repas végétarien',
          description: 'Remplacer un repas à base de viande par un repas végétarien',
          type: ActivityType.food,
          carbonImpact: 2.0,
          icon: Icons.spa,
        ),
        QuickAction(
          id: 'waste-recycle',
          title: 'Recycler correctement',
          description: 'Trier ses déchets selon les consignes locales',
          type: ActivityType.waste,
          carbonImpact: 0.7,
          icon: Icons.recycling,
        ),
        QuickAction(
          id: 'waste-compost',
          title: 'Composter',
          description: 'Composter les déchets organiques au lieu de les jeter',
          type: ActivityType.waste,
          carbonImpact: 0.8,
          icon: Icons.compost,
        ),
        QuickAction(
          id: 'water-shower',
          title: 'Douche courte',
          description: 'Prendre une douche courte (moins de 5 minutes)',
          type: ActivityType.water,
          carbonImpact: 0.4,
          icon: Icons.shower,
        ),
        QuickAction(
          id: 'water-faucet',
          title: 'Robinet fermé',
          description: 'Fermer le robinet pendant le brossage des dents',
          type: ActivityType.water,
          carbonImpact: 0.1,
          icon: Icons.water_drop,
        ),
      ];
    } catch (e) {
      print('Erreur lors du chargement des actions rapides: $e');
    } finally {
      isLoading.value = false;
    }
  }
  
  Future<void> recordAction(QuickAction action) async {
    try {
      final userId = _authService.currentUser?.uid;
      if (userId == null) {
        return;
      }

      final now = DateTime.now();
      
      // Conversion du type d'activité
      eco_activity_model.ActivityType ecoActivityType;
      switch (action.type) {
        case ActivityType.transport:
          ecoActivityType = eco_activity_model.ActivityType.transport;
          break;
        case ActivityType.energy:
          ecoActivityType = eco_activity_model.ActivityType.energy;
          break;
        case ActivityType.food:
          ecoActivityType = eco_activity_model.ActivityType.food;
          break;
        case ActivityType.waste:
          ecoActivityType = eco_activity_model.ActivityType.waste;
          break;
        case ActivityType.water:
          ecoActivityType = eco_activity_model.ActivityType.water;
          break;
        case ActivityType.other:
        default:
          ecoActivityType = eco_activity_model.ActivityType.recycling;
          break;
      }
      
      final activity = eco_activity_model.EcoActivity(
        id: '',  // Sera généré par Firestore
        userId: userId,
        type: ecoActivityType,
        title: action.title,
        description: action.description,
        carbonImpact: action.carbonImpact,
        timestamp: now,
        additionalData: {},
      );

      await _ecoActivityService.addActivity(activity);
      await loadUserActivities();  // Recharger les activités
    } catch (e) {
      print('Erreur lors de l\'enregistrement de l\'action: $e');
      Get.snackbar(
        'Erreur',
        'Impossible d\'enregistrer cette action. Veuillez réessayer.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
  
  double calculateDailyImpact(DateTime date) {
    final dateString = DateFormat('yyyy-MM-dd').format(date);
    return userActivities
        .where((activity) => 
            DateFormat('yyyy-MM-dd').format(activity.timestamp) == dateString)
        .fold(0.0, (sum, activity) => sum + activity.carbonImpact);
  }
  
  int getTodayActivityCount() {
    final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    return userActivities
        .where((activity) => 
            DateFormat('yyyy-MM-dd').format(activity.timestamp) == today)
        .length;
  }
  
  double getWeeklyImpact() {
    double totalImpact = 0.0;
    final now = DateTime.now();
    
    for (int i = 0; i < 7; i++) {
      final date = now.subtract(Duration(days: i));
      totalImpact += calculateDailyImpact(date);
    }
    
    return totalImpact;
  }
} 