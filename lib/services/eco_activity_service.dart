import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/eco_activity.dart';

class EcoActivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addActivity(EcoActivity activity) async {
    try {
      await _firestore
          .collection('users')
          .doc(activity.userId)
          .collection('activities')
          .add(activity.toMap());
    } catch (e) {
      print('Erreur lors de l\'ajout de l\'activité: $e');
      throw e;
    }
  }

  Future<List<EcoActivity>> getUserActivities(String userId, {ActivityType? type}) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('activities');

      if (type != null) {
        query = query.where('type', isEqualTo: type.toString().split('.').last);
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs.map((doc) => EcoActivity.fromFirestore(doc)).toList();
    } catch (e) {
      print('Erreur lors de la récupération des activités: $e');
      return [];
    }
  }

  Future<double> calculateTotalCarbonImpact(String userId, {DateTime? startDate, DateTime? endDate}) async {
    try {
      Query query = _firestore
          .collection('users')
          .doc(userId)
          .collection('activities');

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }
      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: Timestamp.fromDate(endDate));
      }

      final QuerySnapshot snapshot = await query.get();
      double totalImpact = 0.0;

      for (var doc in snapshot.docs) {
        final activity = EcoActivity.fromFirestore(doc);
        totalImpact += activity.carbonImpact;
      }

      return totalImpact;
    } catch (e) {
      print('Erreur lors du calcul de l\'impact carbone: $e');
      return 0.0;
    }
  }

  Future<Map<ActivityType, double>> getCarbonImpactByType(String userId) async {
    try {
      final activities = await getUserActivities(userId);
      Map<ActivityType, double> impactByType = {};

      for (var activity in activities) {
        impactByType[activity.type] = (impactByType[activity.type] ?? 0.0) + activity.carbonImpact;
      }

      return impactByType;
    } catch (e) {
      print('Erreur lors du calcul de l\'impact par type: $e');
      return {};
    }
  }

  Future<void> verifyActivity(String userId, String activityId) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('activities')
          .doc(activityId)
          .update({'isVerified': true});
    } catch (e) {
      print('Erreur lors de la vérification de l\'activité: $e');
      throw e;
    }
  }
} 