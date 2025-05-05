import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore;

  FirestoreService({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<bool> saveUserData({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).set(data);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }
}