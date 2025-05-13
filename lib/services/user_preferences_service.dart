import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:greens_app/models/user_preferences_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserPreferencesService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  UserPreferencesModel _preferences = UserPreferencesModel();
  UserPreferencesModel get preferences => _preferences;
  
  // Charge les préférences de l'utilisateur
  Future<void> loadUserPreferences(String userId) async {
    try {
      // Essayer d'abord de charger depuis Firebase
      final userDoc = await _firestore.collection('users').doc(userId).get();
      final preferencesDoc = await _firestore.collection('user_preferences').doc(userId).get();
      
      if (preferencesDoc.exists) {
        _preferences = UserPreferencesModel.fromJson(preferencesDoc.data() ?? {});
        notifyListeners();
        return;
      }
      
      // Si pas de préférences en ligne, créer des préférences par défaut basées sur
      // les informations de base de l'utilisateur
      if (userDoc.exists) {
        final userData = userDoc.data() ?? {};
        final List<String> interests = userData['interests'] != null 
            ? List<String>.from(userData['interests']) 
            : [];
            
        _preferences = UserPreferencesModel(
          ecoInterests: interests,
          // Autres valeurs par défaut
        );
        
        // Sauvegarder ces préférences en ligne
        await saveUserPreferences(userId);
      }
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des préférences utilisateur: $e');
    }
  }
  
  // Sauvegarde les préférences de l'utilisateur
  Future<void> saveUserPreferences(String userId) async {
    try {
      await _firestore.collection('user_preferences').doc(userId).set(
        _preferences.toJson(),
        SetOptions(merge: true),
      );
      
      // Sauvegarder aussi les préférences locales
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isDarkMode', _preferences.isDarkMode);
      await prefs.setString('preferredLanguage', _preferences.preferredLanguage);
      await prefs.setBool('enableNotifications', _preferences.enableNotifications);
      
    } catch (e) {
      print('Erreur lors de la sauvegarde des préférences utilisateur: $e');
    }
  }
  
  // Met à jour les préférences de thème
  Future<void> updateThemePreference(bool isDarkMode) async {
    _preferences = _preferences.copyWith(isDarkMode: isDarkMode);
    notifyListeners();
    
    // Sauvegarder localement
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode);
  }
  
  // Met à jour les intérêts écologiques
  Future<void> updateEcoInterests(List<String> interests, String userId) async {
    _preferences = _preferences.copyWith(ecoInterests: interests);
    notifyListeners();
    
    // Sauvegarder en ligne
    await saveUserPreferences(userId);
  }
  
  // Met à jour les préférences de notification
  Future<void> updateNotificationPreference(bool enableNotifications, String userId) async {
    _preferences = _preferences.copyWith(enableNotifications: enableNotifications);
    notifyListeners();
    
    // Sauvegarder localement et en ligne
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('enableNotifications', enableNotifications);
    await saveUserPreferences(userId);
  }
  
  // Met à jour les préférences sociales
  Future<void> updateSocialPreferences(bool shareOnSocialMedia, List<String> networks, String userId) async {
    _preferences = _preferences.copyWith(
      shareOnSocialMedia: shareOnSocialMedia,
      connectedSocialNetworks: networks,
    );
    notifyListeners();
    
    // Sauvegarder en ligne
    await saveUserPreferences(userId);
  }
  
  // Filtre les contenus en fonction des préférences utilisateur
  List<T> filterContentByPreferences<T>(List<T> items, Function(T) categoryExtractor) {
    if (_preferences.favoriteCategories.isEmpty) {
      return items;
    }
    
    // D'abord on affiche le contenu correspondant aux catégories favorites
    final preferredItems = items.where((item) {
      final categories = categoryExtractor(item);
      for (var category in categories) {
        if (_preferences.favoriteCategories.contains(category)) {
          return true;
        }
      }
      return false;
    }).toList();
    
    // Puis on affiche le reste
    final otherItems = items.where((item) => !preferredItems.contains(item)).toList();
    
    return [...preferredItems, ...otherItems];
  }
  
  // Recommande des défis en fonction des intérêts
  List<T> recommendChallengesByInterests<T>(List<T> challenges, Function(T) categoryExtractor) {
    if (_preferences.ecoInterests.isEmpty) {
      return challenges;
    }
    
    final recommended = challenges.where((challenge) {
      final categories = categoryExtractor(challenge);
      for (var interest in _preferences.ecoInterests) {
        if (categories.contains(interest)) {
          return true;
        }
      }
      return false;
    }).toList();
    
    final others = challenges.where((challenge) => !recommended.contains(challenge)).toList();
    
    return [...recommended, ...others];
  }
  
  // Vérifie si un contenu correspond aux préférences
  bool isContentRelevantForUser<T>(T content, Function(T) categoryExtractor) {
    if (_preferences.favoriteCategories.isEmpty && 
        _preferences.ecoInterests.isEmpty) {
      return true;
    }
    
    final categories = categoryExtractor(content);
    
    // Vérifier si le contenu correspond aux catégories favorites
    for (var category in categories) {
      if (_preferences.favoriteCategories.contains(category)) {
        return true;
      }
    }
    
    // Vérifier si le contenu correspond aux intérêts
    for (var interest in categories) {
      if (_preferences.ecoInterests.contains(interest)) {
        return true;
      }
    }
    
    return false;
  }
  
  // Charge les préférences locales au démarrage de l'application
  Future<void> loadLocalPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      final isDarkMode = prefs.getBool('isDarkMode') ?? false;
      final language = prefs.getString('preferredLanguage') ?? 'fr';
      final enableNotifications = prefs.getBool('enableNotifications') ?? true;
      
      _preferences = _preferences.copyWith(
        isDarkMode: isDarkMode,
        preferredLanguage: language,
        enableNotifications: enableNotifications,
      );
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des préférences locales: $e');
    }
  }
} 