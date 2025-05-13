import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/eco_challenge_model.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/services/eco_content_integration_service.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service pour gérer les notifications contextuelles et encourager
/// l'engagement des utilisateurs de manière personnalisée
class EcoEngagementService {
  final FlutterLocalNotificationsPlugin _notificationsPlugin;
  final FirebaseFirestore _firestore;
  final EcoContentIntegrationService _contentService;
  
  // Clés pour SharedPreferences
  static const String _lastInteractionKey = 'last_interaction_timestamp';
  static const String _activeChallengesKey = 'active_challenges_count';
  static const String _activeGoalsKey = 'active_goals_count';
  static const String _streakKey = 'app_usage_streak';
  
  // Seuils pour déclencher des notifications
  static const int _inactivityThresholdHours = 48; // 2 jours
  static const int _challengeReminderHours = 24; // 1 jour
  static const int _weeklyRecapDays = 7; // 1 semaine
  
  // ID des notifications pour gérer leur annulation/mise à jour
  static const int _inactivityNotificationId = 1;
  static const int _challengeReminderNotificationId = 2;
  static const int _goalReminderNotificationId = 3;
  static const int _newContentNotificationId = 4;
  static const int _weeklyRecapNotificationId = 5;
  
  // Singleton
  static final EcoEngagementService _instance = EcoEngagementService._internal(
    FlutterLocalNotificationsPlugin(),
    FirebaseFirestore.instance,
    EcoContentIntegrationService(),
  );
  
  factory EcoEngagementService() {
    return _instance;
  }
  
  EcoEngagementService._internal(
    this._notificationsPlugin,
    this._firestore,
    this._contentService,
  );
  
  /// Initialiser le service de notifications
  Future<void> initialize() async {
    tz.initializeTimeZones();
    
    const androidSettings = AndroidInitializationSettings('app_icon');
    const iosSettings = IOSInitializationSettings();
    
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    
    await _notificationsPlugin.initialize(
      initSettings,
      onSelectNotification: _handleNotificationTap,
    );
  }
  
  /// Gérer le tap sur une notification
  Future<void> _handleNotificationTap(String? payload) async {
    if (payload == null) return;
    
    // Payload contient des informations sur l'action à effectuer
    final payloadParts = payload.split(':');
    if (payloadParts.length < 2) return;
    
    final action = payloadParts[0];
    final id = payloadParts[1];
    
    // Stocker ces informations pour être utilisées au prochain démarrage de l'app
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_notification_action', action);
    await prefs.setString('last_notification_id', id);
  }
  
  /// Enregistrer une interaction utilisateur pour suivre l'engagement
  Future<void> recordUserInteraction(String userId, String interactionType) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final timestamp = now.millisecondsSinceEpoch;
    
    // Mettre à jour le timestamp de dernière interaction
    await prefs.setInt(_lastInteractionKey, timestamp);
    
    // Vérifier et mettre à jour le streak de l'utilisateur
    await _updateUserStreak(userId);
    
    // Enregistrer l'interaction dans Firestore pour l'analyser
    await _firestore
        .collection('user_interactions')
        .add({
          'userId': userId,
          'type': interactionType,
          'timestamp': FieldValue.serverTimestamp(),
        });
    
    // Annuler les notifications d'inactivité existantes puisque l'utilisateur est actif
    await _notificationsPlugin.cancel(_inactivityNotificationId);
    
    // Programmer de nouvelles notifications basées sur cette interaction
    await _scheduleContextualNotifications(userId);
  }
  
  /// Mettre à jour le streak d'utilisation de l'application
  Future<void> _updateUserStreak(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // Récupérer la dernière date d'utilisation
    final lastInteractionTimestamp = prefs.getInt(_lastInteractionKey) ?? 0;
    final lastInteractionDate = DateTime.fromMillisecondsSinceEpoch(lastInteractionTimestamp);
    final lastDate = DateTime(lastInteractionDate.year, lastInteractionDate.month, lastInteractionDate.day);
    
    // Obtenir le streak actuel
    final currentStreak = prefs.getInt(_streakKey) ?? 0;
    
    // Calculer la différence en jours
    final difference = today.difference(lastDate).inDays;
    
    int newStreak = currentStreak;
    
    // Si c'est le jour suivant, augmenter le streak
    if (difference == 1) {
      newStreak++;
      await prefs.setInt(_streakKey, newStreak);
      
      // Si le streak atteint un multiple de 5, envoyer une notification de félicitations
      if (newStreak % 5 == 0) {
        await _showStreakMilestoneNotification(userId, newStreak);
      }
    } 
    // Si plus d'un jour s'est écoulé, réinitialiser le streak (mais pas si c'est la première utilisation)
    else if (difference > 1 && lastInteractionTimestamp > 0) {
      newStreak = 1;
      await prefs.setInt(_streakKey, newStreak);
    } 
    // Si c'est le même jour, ne rien faire
    else if (difference == 0) {
      // Ne rien faire, garder le même streak
    } 
    // Si c'est la première utilisation
    else if (lastInteractionTimestamp == 0) {
      newStreak = 1;
      await prefs.setInt(_streakKey, newStreak);
    }
    
    // Mettre à jour le streak dans Firestore
    await _firestore
        .collection('user_profiles')
        .doc(userId)
        .update({
          'app_usage_streak': newStreak,
          'last_activity_date': FieldValue.serverTimestamp(),
        });
  }
  
  /// Programmer des notifications contextuelles basées sur l'activité utilisateur
  Future<void> _scheduleContextualNotifications(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now();
    
    // Récupérer le nombre de défis et objectifs actifs
    final activeChallengesCount = prefs.getInt(_activeChallengesKey) ?? 0;
    final activeGoalsCount = prefs.getInt(_activeGoalsKey) ?? 0;
    
    // 1. Notification d'inactivité si l'utilisateur ne revient pas après un certain temps
    final inactivitySchedule = tz.TZDateTime.from(
      now.add(const Duration(hours: _inactivityThresholdHours)),
      tz.local,
    );
    
    await _notificationsPlugin.zonedSchedule(
      _inactivityNotificationId,
      'Vous nous manquez !',
      'Revenez pour voir vos progrès écologiques et de nouveaux défis.',
      inactivitySchedule,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'eco_engagement_channel',
          'Rappels écologiques',
          channelDescription: 'Notifications pour encourager l\'engagement écologique',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF4CAF50),
        ),
        iOS: IOSNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uriAndroidAllowWhileIdle: true,
      payload: 'home:default',
      matchDateTimeComponents: DateTimeComponents.time,
    );
    
    // 2. Rappel de défis en cours si l'utilisateur en a
    if (activeChallengesCount > 0) {
      final challengeSchedule = tz.TZDateTime.from(
        now.add(const Duration(hours: _challengeReminderHours)),
        tz.local,
      );
      
      // Récupérer un défi actif pour personnaliser la notification
      final challenges = await _getActiveChallenges(userId);
      final challengeTitle = challenges.isNotEmpty ? challenges.first.title : 'vos défis écologiques';
      
      await _notificationsPlugin.zonedSchedule(
        _challengeReminderNotificationId,
        'Défi écologique en cours',
        'N\'oubliez pas de continuer "$challengeTitle" aujourd\'hui !',
        challengeSchedule,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'eco_challenges_channel',
            'Défis écologiques',
            channelDescription: 'Rappels pour les défis écologiques en cours',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFF4CAF50),
          ),
          iOS: IOSNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uriAndroidAllowWhileIdle: true,
        payload: 'challenges:active',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
    
    // 3. Rappel d'objectifs en cours si l'utilisateur en a
    if (activeGoalsCount > 0) {
      final goalSchedule = tz.TZDateTime.from(
        now.add(const Duration(hours: _challengeReminderHours + 12)), // Décalé pour ne pas avoir toutes les notifs en même temps
        tz.local,
      );
      
      // Récupérer un objectif actif pour personnaliser la notification
      final goals = await _getActiveGoals(userId);
      final goalTitle = goals.isNotEmpty ? goals.first.title : 'vos objectifs écologiques';
      
      await _notificationsPlugin.zonedSchedule(
        _goalReminderNotificationId,
        'Objectif écologique',
        'Progressez vers votre objectif "$goalTitle" dès maintenant !',
        goalSchedule,
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'eco_goals_channel',
            'Objectifs écologiques',
            channelDescription: 'Rappels pour les objectifs écologiques en cours',
            importance: Importance.high,
            priority: Priority.high,
            color: Color(0xFF4CAF50),
          ),
          iOS: IOSNotificationDetails(),
        ),
        androidAllowWhileIdle: true,
        uriAndroidAllowWhileIdle: true,
        payload: 'goals:active',
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
    
    // 4. Récapitulatif hebdomadaire
    final weeklyRecapSchedule = tz.TZDateTime.from(
      now.add(const Duration(days: _weeklyRecapDays)),
      tz.local,
    );
    
    await _notificationsPlugin.zonedSchedule(
      _weeklyRecapNotificationId,
      'Votre bilan écologique de la semaine',
      'Découvrez l\'impact positif de vos actions cette semaine !',
      weeklyRecapSchedule,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'eco_recap_channel',
          'Récapitulatifs écologiques',
          channelDescription: 'Récapitulatifs hebdomadaires de votre impact écologique',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF4CAF50),
        ),
        iOS: IOSNotificationDetails(),
      ),
      androidAllowWhileIdle: true,
      uriAndroidAllowWhileIdle: true,
      payload: 'recap:weekly',
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }
  
  /// Notification pour célébrer un streak milestone
  Future<void> _showStreakMilestoneNotification(String userId, int streak) async {
    await _notificationsPlugin.show(
      100 + streak, // ID unique basé sur le streak
      'Félicitations ! 🎉',
      'Vous utilisez l\'app depuis $streak jours consécutifs. Continuez comme ça !',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'eco_streak_channel',
          'Jalons écologiques',
          channelDescription: 'Célébrations de vos accomplissements écologiques',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF4CAF50),
        ),
        iOS: IOSNotificationDetails(),
      ),
      payload: 'profile:streak',
    );
  }
  
  /// Notification pour un nouveau contenu pertinent
  Future<void> showNewContentNotification(String userId, String contentType, String contentId, String title) async {
    await _notificationsPlugin.show(
      _newContentNotificationId,
      'Nouveau contenu pour vous',
      'Découvrez "$title" dans l\'application !',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'eco_content_channel',
          'Nouveau contenu',
          channelDescription: 'Notifications pour le nouveau contenu personnalisé',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF4CAF50),
        ),
        iOS: IOSNotificationDetails(),
      ),
      payload: '$contentType:$contentId',
    );
  }
  
  /// Notification contextuelle basée sur la localisation
  Future<void> showLocationBasedNotification(String title, String body, String actionType) async {
    await _notificationsPlugin.show(
      50, // ID fixe pour notification de localisation
      title,
      body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'eco_location_channel',
          'Notifications de localisation',
          channelDescription: 'Notifications contextuelles basées sur votre localisation',
          importance: Importance.high,
          priority: Priority.high,
          color: Color(0xFF4CAF50),
        ),
        iOS: IOSNotificationDetails(),
      ),
      payload: '$actionType:location',
    );
  }
  
  /// Mettre à jour le nombre de défis actifs
  Future<void> updateActiveChallengesCount(String userId, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_activeChallengesKey, count);
    
    // Mettre à jour dans Firestore
    await _firestore
        .collection('user_profiles')
        .doc(userId)
        .update({
          'active_challenges_count': count,
        });
  }
  
  /// Mettre à jour le nombre d'objectifs actifs
  Future<void> updateActiveGoalsCount(String userId, int count) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_activeGoalsKey, count);
    
    // Mettre à jour dans Firestore
    await _firestore
        .collection('user_profiles')
        .doc(userId)
        .update({
          'active_goals_count': count,
        });
  }
  
  /// Récupérer les défis actifs de l'utilisateur
  Future<List<EcoChallenge>> _getActiveChallenges(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_challenges')
          .where('userId', isEqualTo: userId)
          .where('status', isEqualTo: 'active')
          .get();
      
      if (snapshot.docs.isEmpty) {
        return [];
      }
      
      // Récupérer les IDs des défis
      final challengeIds = snapshot.docs.map((doc) => doc['challengeId'] as String).toList();
      
      // Récupérer les détails des défis
      final challengesSnapshot = await _firestore
          .collection('eco_challenges')
          .where(FieldPath.documentId, whereIn: challengeIds)
          .get();
      
      return challengesSnapshot.docs.map((doc) {
        return EcoChallenge.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des défis actifs: $e');
      return [];
    }
  }
  
  /// Récupérer les objectifs actifs de l'utilisateur
  Future<List<EcoGoal>> _getActiveGoals(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('user_goals')
          .where('userId', isEqualTo: userId)
          .where('completed', isEqualTo: false)
          .get();
      
      return snapshot.docs.map((doc) {
        return EcoGoal.fromMap({...doc.data(), 'id': doc.id});
      }).toList();
    } catch (e) {
      print('Erreur lors de la récupération des objectifs actifs: $e');
      return [];
    }
  }
  
  /// Annuler toutes les notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
} 