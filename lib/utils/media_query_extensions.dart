import 'package:flutter/material.dart';

/// Extensions pour MediaQueryData
extension MediaQueryExtensions on MediaQueryData {
  /// Récupère la valeur de boldTextOverride ou fournit une valeur par défaut (false)
  bool get boldTextOverride {
    // Dans les versions récentes de Flutter, cette propriété n'existe pas toujours,
    // donc on fournit une valeur par défaut
    try {
      final data = this as dynamic;
      return data.boldTextOverride ?? false;
    } catch (e) {
      return false;
    }
  }
  
  /// Récupère la hauteur disponible en tenant compte de la taille du clavier
  double get availableHeight {
    return size.height - viewInsets.bottom - viewPadding.top - viewPadding.bottom;
  }
  
  /// Récupère la largeur de l'écran selon son orientation
  double get adaptiveWidth {
    return orientation == Orientation.portrait ? size.width : size.height;
  }
  
  /// Récupère la hauteur de l'écran selon son orientation
  double get adaptiveHeight {
    return orientation == Orientation.portrait ? size.height : size.width;
  }
  
  /// Vérifie si l'appareil est un téléphone (écran plus petit)
  bool get isPhone {
    final width = size.shortestSide;
    return width < 600;
  }
  
  /// Vérifie si l'appareil est une tablette (écran plus grand)
  bool get isTablet {
    final width = size.shortestSide;
    return width >= 600;
  }
  
  /// Vérifie si le mode sombre est activé
  bool get isDarkMode {
    return platformBrightness == Brightness.dark;
  }
}

/// Extensions pour BuildContext pour faciliter l'accès à MediaQuery
extension MediaQueryExtensionsContext on BuildContext {
  MediaQueryData get mediaQuery => MediaQuery.of(this);
  
  Size get screenSize => mediaQuery.size;
  
  double get screenWidth => screenSize.width;
  
  double get screenHeight => screenSize.height;
  
  bool get boldTextOverride => mediaQuery.boldTextOverride;
  
  bool get isDarkMode => mediaQuery.isDarkMode;
  
  bool get isPhone => mediaQuery.isPhone;
  
  bool get isTablet => mediaQuery.isTablet;
} 