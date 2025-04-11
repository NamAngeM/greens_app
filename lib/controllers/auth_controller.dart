import 'package:flutter/material.dart';
import 'package:greens_app/models/user_model.dart';
import 'package:greens_app/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthController extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get currentUser => _currentUser;

  bool get isLoading => _isLoading;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;

  // Initialiser le contrôleur
  Future<void> initialize() async {
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await _authService.getCurrentUser();
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'initialisation: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // S'inscrire avec email et mot de passe
  Future<bool> signUp({
    required String email,
    required String password,
    required String firstName,
    required String lastName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signUpWithEmailAndPassword(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
      );

      _currentUser = await _authService.getCurrentUser();
      
      // Marquer comme nouvel utilisateur qui doit compléter les questions
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_new_user', true);
      await prefs.setBool('has_completed_questions', false);
      
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'inscription: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Se connecter avec email et mot de passe
  Future<bool> signIn({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _currentUser = await _authService.getCurrentUser();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la connexion: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // S'inscrire ou se connecter avec Google
  Future<bool> signInWithGoogle() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Configuration spécifique pour Google Sign-In
      final GoogleSignIn googleSignIn = GoogleSignIn(
        // Ajout de scopes nécessaires
        scopes: [
          'email',
          'profile',
        ],
      );
      
      // Déconnexion préalable pour éviter les problèmes d'état
      try {
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.disconnect();
          await googleSignIn.signOut();
        }
      } catch (e) {
        print('Erreur lors de la déconnexion Google préalable: $e');
      }
      
      // Lancer la connexion Google avec gestion explicite des erreurs
      final GoogleSignInAccount? googleUser;
      try {
        googleUser = await googleSignIn.signIn();
      } catch (error) {
        print('Erreur lors de la tentative de connexion Google: $error');
        _errorMessage = 'Erreur de connexion Google: $error';
        return false;
      }
      
      // Si l'utilisateur a annulé la connexion
      if (googleUser == null) {
        _errorMessage = 'Connexion Google annulée par l\'utilisateur';
        return false;
      }
      
      print('Google Sign-In réussi pour: ${googleUser.email}');
      
      // Obtenir les détails d'authentification
      final GoogleSignInAuthentication googleAuth;
      try {
        googleAuth = await googleUser.authentication;
      } catch (error) {
        print('Erreur lors de l\'authentification Google: $error');
        _errorMessage = 'Erreur d\'authentification Google: $error';
        return false;
      }
      
      if (googleAuth.accessToken == null || googleAuth.idToken == null) {
        _errorMessage = 'Impossible d\'obtenir les tokens d\'authentification Google';
        return false;
      }
      
      // Créer les credentials pour Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken!,
        idToken: googleAuth.idToken!,
      );
      
      // Connexion à Firebase avec gestion explicite des erreurs
      final UserCredential userCredential;
      try {
        userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      } catch (error) {
        print('Erreur lors de la connexion Firebase avec Google: $error');
        _errorMessage = 'Erreur de connexion Firebase: $error';
        return false;
      }
      
      // Vérifier si c'est un nouvel utilisateur
      final bool isNewUser = userCredential.additionalUserInfo?.isNewUser ?? false;
      print('Est un nouvel utilisateur: $isNewUser');
      
      // Marquer les préférences utilisateur
      final prefs = await SharedPreferences.getInstance();
      
      if (isNewUser) {
        print('Création du profil utilisateur pour: ${userCredential.user!.email}');
        // Créer le document utilisateur pour un nouvel utilisateur
        try {
          await _authService.createUserFromSocial(
            uid: userCredential.user!.uid,
            email: userCredential.user!.email ?? '',
            firstName: userCredential.user!.displayName?.split(' ').first ?? '',
            lastName: userCredential.user!.displayName?.split(' ').last ?? '',
            photoUrl: userCredential.user!.photoURL,
          );
        } catch (error) {
          print('Erreur lors de la création du profil utilisateur: $error');
          // On continue même si cette étape échoue
        }
        
        // Marquer comme nouvel utilisateur pour le questionnaire
        await prefs.setBool('is_new_user', true);
        await prefs.setBool('has_completed_questions', false);
      }
      
      // Récupérer les informations utilisateur
      try {
        _currentUser = await _authService.getCurrentUser();
      } catch (error) {
        print('Erreur lors de la récupération des données utilisateur: $error');
        // On continue même si cette étape échoue
      }
      
      return true;
    } catch (e) {
      print('Erreur globale lors de la connexion avec Google: $e');
      _errorMessage = 'Erreur lors de la connexion avec Google: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Se déconnecter
  Future<void> signOut() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Déconnexion de Google si connecté
      try {
        final GoogleSignIn googleSignIn = GoogleSignIn();
        if (await googleSignIn.isSignedIn()) {
          await googleSignIn.signOut();
        }
      } catch (e) {
        // Ignorer les erreurs de déconnexion Google
        print('Erreur lors de la déconnexion Google: $e');
      }
      
      await _authService.signOut();
      _currentUser = null;
    } catch (e) {
      _errorMessage = 'Erreur lors de la déconnexion: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour les intérêts de l'utilisateur
  Future<bool> updateUserInterests(List<String> interests) async {
    if (_currentUser == null) {
      _errorMessage = 'Utilisateur non connecté';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateUserInterests(_currentUser!.uid, interests);
      _currentUser = await _authService.getCurrentUser();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour des intérêts: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour les points carbone de l'utilisateur
  Future<bool> updateCarbonPoints(int points) async {
    if (_currentUser == null) {
      _errorMessage = 'Utilisateur non connecté';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.updateCarbonPoints(_currentUser!.uid, points);
      _currentUser = await _authService.getCurrentUser();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour des points carbone: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Mettre à jour le profil de l'utilisateur (prénom et nom)
  Future<bool> updateUserProfile({
    required String firstName,
    String? lastName,
  }) async {
    if (_currentUser == null) {
      _errorMessage = 'Utilisateur non connecté';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Créer un nouvel utilisateur avec les informations mises à jour
      final updatedUser = _currentUser!.copyWith(
        firstName: firstName,
        lastName: lastName,
      );
      
      // Mettre à jour l'utilisateur dans Firestore
      await _authService.updateUserData(updatedUser);
      
      // Récupérer l'utilisateur mis à jour
      _currentUser = await _authService.getCurrentUser();
      return true;
    } catch (e) {
      _errorMessage = 'Erreur lors de la mise à jour du profil: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
