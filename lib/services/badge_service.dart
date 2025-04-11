import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/badge.dart';

class BadgeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Badge>> getUserBadges(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .get();

      return snapshot.docs.map((doc) => Badge.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des badges: $e');
      return [];
    }
  }

  Future<void> unlockBadge(String userId, Badge badge) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('badges')
          .doc(badge.id)
          .set({
        ...badge.toMap(),
        'isUnlocked': true,
        'unlockedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Erreur lors du déblocage du badge: $e');
      throw e;
    }
  }

  Future<List<Badge>> getAvailableBadges() async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('badges')
          .get();

      return snapshot.docs.map((doc) => Badge.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des badges disponibles: $e');
      return [];
    }
  }

  Future<void> checkAndAwardBadges(String userId, Map<String, dynamic> userStats) async {
    try {
      final List<Badge> availableBadges = await getAvailableBadges();
      final List<Badge> userBadges = await getUserBadges(userId);
      final Set<String> unlockedBadgeIds = userBadges
          .where((badge) => badge.isUnlocked)
          .map((badge) => badge.id)
          .toSet();

      for (var badge in availableBadges) {
        if (!unlockedBadgeIds.contains(badge.id)) {
          bool shouldUnlock = true;
          for (var requirement in badge.requirements) {
            if (!userStats.containsKey(requirement) ||
                userStats[requirement] < badge.requirements[requirement]) {
              shouldUnlock = false;
              break;
            }
          }

          if (shouldUnlock) {
            await unlockBadge(userId, badge);
          }
        }
      }
    } catch (e) {
      print('Erreur lors de la vérification des badges: $e');
      throw e;
    }
  }
} 