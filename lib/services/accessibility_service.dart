import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

/// Service qui gère les fonctionnalités d'accessibilité de l'application
/// Centralise toutes les options pour les personnes malvoyantes
class AccessibilityService extends ChangeNotifier {
  // Singleton pattern
  static final AccessibilityService _instance = AccessibilityService._internal();
  factory AccessibilityService() => _instance;
  AccessibilityService._internal();

  // Clés pour les préférences partagées
  static const String _kHighContrastKey = 'accessibility_high_contrast';
  static const String _kTextScaleFactorKey = 'accessibility_text_scale_factor';
  static const String _kScreenReaderKey = 'accessibility_screen_reader';
  static const String _kLargeTextKey = 'accessibility_large_text';

  // Valeurs par défaut et limites
  static const double _kDefaultTextScaleFactor = 1.0;
  static const double _kMinTextScaleFactor = 0.8;
  static const double _kMaxTextScaleFactor = 1.5;
  static const double _kTextScaleStep = 0.1;

  // Variables d'état
  bool _isHighContrastEnabled = false;
  bool _isScreenReaderEnabled = false;
  bool _isLargeTextEnabled = false;
  double _textScaleFactor = _kDefaultTextScaleFactor;

  // Getters
  bool get isHighContrastEnabled => _isHighContrastEnabled;
  bool get isScreenReaderEnabled => _isScreenReaderEnabled;
  bool get isLargeTextEnabled => _isLargeTextEnabled;
  double get textScaleFactor => _textScaleFactor;

  /// Initialise le service d'accessibilité
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Charger les paramètres sauvegardés
    _isHighContrastEnabled = prefs.getBool(_kHighContrastKey) ?? false;
    _isScreenReaderEnabled = prefs.getBool(_kScreenReaderKey) ?? false;
    _isLargeTextEnabled = prefs.getBool(_kLargeTextKey) ?? false;
    _textScaleFactor = prefs.getDouble(_kTextScaleFactorKey) ?? _kDefaultTextScaleFactor;
    
    notifyListeners();
  }
  
  /// Active ou désactive le mode contraste élevé
  Future<void> toggleHighContrast() async {
    _isHighContrastEnabled = !_isHighContrastEnabled;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHighContrastKey, _isHighContrastEnabled);
  }
  
  /// Active ou désactive le texte large
  Future<void> toggleLargeText() async {
    _isLargeTextEnabled = !_isLargeTextEnabled;
    
    // Si on active le texte large, définir un facteur d'échelle plus grand
    if (_isLargeTextEnabled) {
      _textScaleFactor = 1.3;
    } else {
      _textScaleFactor = _kDefaultTextScaleFactor;
    }
    
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kLargeTextKey, _isLargeTextEnabled);
    await prefs.setDouble(_kTextScaleFactorKey, _textScaleFactor);
  }
  
  /// Ajuste manuellement le facteur d'échelle du texte
  Future<void> setTextScaleFactor(double factor) async {
    // S'assurer que le facteur d'échelle est dans les limites
    _textScaleFactor = factor.clamp(_kMinTextScaleFactor, _kMaxTextScaleFactor);
    
    // Si le facteur est significativement plus grand que la valeur par défaut,
    // considérer que le texte large est activé
    _isLargeTextEnabled = _textScaleFactor >= 1.2;
    
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_kTextScaleFactorKey, _textScaleFactor);
    await prefs.setBool(_kLargeTextKey, _isLargeTextEnabled);
  }
  
  /// Augmente le facteur d'échelle du texte
  Future<void> increaseTextSize() async {
    await setTextScaleFactor(_textScaleFactor + _kTextScaleStep);
  }
  
  /// Diminue le facteur d'échelle du texte
  Future<void> decreaseTextSize() async {
    await setTextScaleFactor(_textScaleFactor - _kTextScaleStep);
  }
  
  /// Active ou désactive le mode lecteur d'écran
  Future<void> toggleScreenReader() async {
    _isScreenReaderEnabled = !_isScreenReaderEnabled;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kScreenReaderKey, _isScreenReaderEnabled);
  }
  
  /// Réinitialise tous les paramètres d'accessibilité aux valeurs par défaut
  Future<void> resetToDefaults() async {
    _isHighContrastEnabled = false;
    _isScreenReaderEnabled = false;
    _isLargeTextEnabled = false;
    _textScaleFactor = _kDefaultTextScaleFactor;
    notifyListeners();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHighContrastKey, false);
    await prefs.setDouble(_kTextScaleFactorKey, _kDefaultTextScaleFactor);
    await prefs.setBool(_kScreenReaderKey, false);
    await prefs.setBool(_kLargeTextKey, false);
  }
  
  /// Obtient les couleurs adaptées en fonction du mode contraste élevé
  Color getAdaptiveColor(Color normalColor, Color highContrastColor) {
    return _isHighContrastEnabled ? highContrastColor : normalColor;
  }
  
  /// Obtient la taille de texte adaptée
  double getAdaptiveTextSize(double normalSize) {
    return normalSize * _textScaleFactor;
  }
  
  /// Génère un texte descriptif pour les éléments visuels (pour les lecteurs d'écran)
  String getDescriptiveTextForImage(String imageName, {String? altText}) {
    if (altText != null && altText.isNotEmpty) return altText;
    
    // Exemples de descriptions automatiques basées sur le nom de l'image
    if (imageName.contains('product')) {
      return 'Image du produit';
    } else if (imageName.contains('logo')) {
      return 'Logo de GreenApp';
    } else if (imageName.contains('profile')) {
      return 'Photo de profil';
    }
    
    return 'Image';
  }
}