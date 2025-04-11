import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:greens_app/models/user_model.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream pour surveiller l'état d'authentification
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Méthode pour s'inscrire avec email et mot de passe
  Future<UserCredential?> signUpWithEmailAndPassword({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    try {
      // Créer l'utilisateur dans Firebase Auth
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Créer le document utilisateur dans Firestore
      if (userCredential.user != null) {
        await _createUserDocument(
          uid: userCredential.user!.uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
        );
      }

      return userCredential;
    } catch (e) {
      debugPrint('Erreur lors de l\'inscription: $e');
      rethrow;
    }
  }

  // Méthode pour se connecter avec email et mot de passe
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      return await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      debugPrint('Erreur lors de la connexion: $e');
      rethrow;
    }
  }

  // Méthode pour se déconnecter
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      debugPrint('Erreur lors de la déconnexion: $e');
      rethrow;
    }
  }

  // Méthode pour créer le document utilisateur dans Firestore
  Future<void> _createUserDocument({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    String? photoUrl,
  }) async {
    try {
      final userModel = UserModel(
        uid: uid,
        email: email,
        firstName: firstName,
        lastName: lastName,
        photoUrl: photoUrl,
        carbonPoints: 0,
        interests: [],
      );

      await _firestore.collection('users').doc(uid).set(userModel.toJson());
    } catch (e) {
      debugPrint('Erreur lors de la création du document utilisateur: $e');
      rethrow;
    }
  }

  // Méthode pour créer un utilisateur à partir d'une connexion sociale
  Future<void> createUserFromSocial({
    required String uid,
    required String email,
    required String firstName,
    required String lastName,
    String? photoUrl,
  }) async {
    try {
      // Vérifier si l'utilisateur existe déjà
      final docSnapshot = await _firestore.collection('users').doc(uid).get();
      
      if (!docSnapshot.exists) {
        // Créer un nouveau document utilisateur s'il n'existe pas
        await _createUserDocument(
          uid: uid,
          email: email,
          firstName: firstName,
          lastName: lastName,
          photoUrl: photoUrl,
        );
      }
    } catch (e) {
      debugPrint('Erreur lors de la création de l\'utilisateur social: $e');
      rethrow;
    }
  }

  // Méthode pour récupérer les données de l'utilisateur actuel
  Future<UserModel?> getCurrentUser() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore.collection('users').doc(user.uid).get();
        if (doc.exists) {
          return UserModel.fromJson(doc.data() as Map<String, dynamic>);
        }
      }
      return null;
    } catch (e) {
      debugPrint('Erreur lors de la récupération de l\'utilisateur: $e');
      return null;
    }
  }

  // Méthode pour mettre à jour les intérêts de l'utilisateur
  Future<void> updateUserInterests(String uid, List<String> interests) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'interests': interests,
      });
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des intérêts: $e');
      rethrow;
    }
  }

  // Méthode pour mettre à jour les habitudes quotidiennes de l'utilisateur
  Future<void> updateUserDailyHabits(String uid, Map<String, dynamic> dailyHabits) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'dailyHabits': dailyHabits,
      });
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des habitudes: $e');
      rethrow;
    }
  }

  // Méthode pour mettre à jour les points carbone de l'utilisateur
  Future<void> updateCarbonPoints(String uid, int points) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'carbonPoints': points,
      });
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des points carbone: $e');
      rethrow;
    }
  }

  // Méthode pour mettre à jour les données de l'utilisateur
  Future<void> updateUserData(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toJson());
    } catch (e) {
      debugPrint('Erreur lors de la mise à jour des données utilisateur: $e');
      rethrow;
    }
  }
}
