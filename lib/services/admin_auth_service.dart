import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdminAuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  bool _isInitialized = false;
  bool _isAdmin = false;
  String _adminRole = '';
  
  bool get isInitialized => _isInitialized;
  bool get isAdmin => _isAdmin;
  String get adminRole => _adminRole;
  User? get currentUser => _auth.currentUser;
  String get currentUserId => _auth.currentUser?.uid ?? '';
  
  // Singleton pour assurer une seule instance du service
  AdminAuthService._internal() {
    _initializeAdminStatus();
  }
  
  static final AdminAuthService _instance = AdminAuthService._internal();
  
  factory AdminAuthService() {
    return _instance;
  }
  
  Future<void> _initializeAdminStatus() async {
    _isInitialized = false;
    notifyListeners();
    
    try {
      // Vérifier si l'utilisateur est connecté
      final user = _auth.currentUser;
      if (user != null) {
        await _checkAdminRoleAndSave(user.uid);
      } else {
        _isAdmin = false;
        _adminRole = '';
      }
    } catch (e) {
      print('Erreur d\'initialisation du statut admin: $e');
      _isAdmin = false;
      _adminRole = '';
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _checkAdminRoleAndSave(String userId) async {
    try {
      // Vérifier le statut d'admin dans Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();
      
      if (userDoc.exists) {
        final userData = userDoc.data() ?? {};
        final role = userData['role']?.toString().toLowerCase() ?? '';
        
        // Vérifier si le rôle est un rôle administratif
        _isAdmin = (role == 'admin' || role == 'moderateur');
        _adminRole = role;
        
        // Sauvegarder le statut dans les préférences locales pour un accès rapide
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('is_admin', _isAdmin);
        await prefs.setString('admin_role', _adminRole);
      } else {
        _isAdmin = false;
        _adminRole = '';
      }
      
      notifyListeners();
    } catch (e) {
      print('Erreur de vérification du rôle admin: $e');
      _isAdmin = false;
      _adminRole = '';
      notifyListeners();
    }
  }
  
  Future<bool> loginAdmin(String email, String password) async {
    try {
      // Se connecter avec Firebase Auth
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      final user = credential.user;
      if (user != null) {
        // Vérifier si l'utilisateur a un rôle d'administrateur
        await _checkAdminRoleAndSave(user.uid);
        
        // Mettre à jour la dernière connexion
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': FieldValue.serverTimestamp(),
        });
        
        return _isAdmin;
      }
      
      return false;
    } catch (e) {
      print('Erreur de connexion admin: $e');
      return false;
    }
  }
  
  Future<void> logoutAdmin() async {
    try {
      await _auth.signOut();
      
      _isAdmin = false;
      _adminRole = '';
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('is_admin', false);
      await prefs.setString('admin_role', '');
      
      notifyListeners();
    } catch (e) {
      print('Erreur de déconnexion admin: $e');
    }
  }
  
  Future<bool> refreshAdminStatus() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _checkAdminRoleAndSave(user.uid);
        return _isAdmin;
      }
      return false;
    } catch (e) {
      print('Erreur de rafraîchissement du statut admin: $e');
      return false;
    }
  }
  
  // Vérifier si l'utilisateur a les permissions pour une fonctionnalité spécifique
  bool hasPermission(String permission) {
    // Si l'utilisateur est admin, il a toutes les permissions
    if (_adminRole == 'admin') return true;
    
    // Pour les modérateurs, définir les permissions spécifiques
    if (_adminRole == 'moderateur') {
      switch (permission) {
        case 'read_users':
        case 'read_challenges':
        case 'edit_challenges':
        case 'read_articles':
        case 'edit_articles':
          return true;
        case 'delete_users':
        case 'delete_challenges':
        case 'delete_articles':
        case 'edit_system_settings':
          return false;
        default:
          return false;
      }
    }
    
    return false;
  }
} 