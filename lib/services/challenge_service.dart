import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/challenge.dart';

class ChallengeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Challenge>> getUserChallenges(String userId) async {
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .get();

      return snapshot.docs.map((doc) => Challenge.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des défis: $e');
      return [];
    }
  }

  Future<List<Challenge>> getAvailableChallenges({ChallengeType? type}) async {
    try {
      Query query = _firestore.collection('challenges');

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) => Challenge.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des défis disponibles: $e');
      return [];
    }
  }

  Future<void> joinChallenge(String userId, Challenge challenge) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .doc(challenge.id)
          .set({
        ...challenge.toMap(),
        'status': ChallengeStatus.inProgress.toString().split('.').last,
        'participants': FieldValue.arrayUnion([userId]),
      });
    } catch (e) {
      print('Erreur lors de l\'inscription au défi: $e');
      throw e;
    }
  }

  Future<void> updateChallengeProgress(String userId, String challengeId, int newValue) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('challenges')
          .doc(challengeId)
          .update({
        'currentValue': newValue,
        'status': newValue >= (await _firestore
                .collection('users')
                .doc(userId)
                .collection('challenges')
                .doc(challengeId)
                .get())
            .data()?['targetValue']
            ? ChallengeStatus.completed.toString().split('.').last
            : ChallengeStatus.inProgress.toString().split('.').last,
      });
    } catch (e) {
      print('Erreur lors de la mise à jour de la progression: $e');
      throw e;
    }
  }

  Future<List<Challenge>> getRecommendedChallenges(String userId) async {
    try {
      final userStats = await _firestore
          .collection('users')
          .doc(userId)
          .get();
      
      final allChallenges = await getAvailableChallenges();
      final userChallenges = await getUserChallenges(userId);
      final completedChallengeIds = userChallenges
          .where((c) => c.status == ChallengeStatus.completed)
          .map((c) => c.id)
          .toSet();

      return allChallenges
          .where((challenge) => !completedChallengeIds.contains(challenge.id))
          .where((challenge) {
            // Logique de recommandation basée sur les statistiques de l'utilisateur
            return true; // À personnaliser selon les besoins
          })
          .take(5)
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des défis recommandés: $e');
      return [];
    }
  }
} 