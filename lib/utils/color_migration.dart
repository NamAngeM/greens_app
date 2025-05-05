// lib/utils/color_migration.dart
// Ce fichier est temporaire et destiné à faciliter la migration des couleurs
// Il sera supprimé une fois que toutes les références à LegacyAppColors auront été mises à jour

import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';

/// Cette classe fournit un mappage entre les anciennes couleurs (LegacyAppColors)
/// et les nouvelles couleurs (AppColors).
/// 
/// À utiliser uniquement pour faciliter la migration.
/// Il est recommandé de mettre à jour directement les références vers AppColors.
class ColorMigration {
  /// Obtient la couleur équivalente dans la nouvelle palette (AppColors)
  /// à partir d'une couleur de l'ancienne palette (LegacyAppColors)
  static Color mapLegacyColor(Color legacyColor) {
    // Valeurs hexadécimales des anciennes couleurs
    const int legacyPrimaryColorValue = 0xFF4CC771;
    const int legacySecondaryColorValue = 0xFF2B4458;
    const int legacyErrorColorValue = 0xFFC74D4C;
    const int legacySuccessColorValue = 0xFF558764;
    const int legacyDark1Value = 0xFF0A2533;
    const int legacyDark2Value = 0xFF2B4458;
    const int legacyDark3Value = 0xFF97A2B0;
    const int legacyLight1Value = 0xFFFFFFFF;
    const int legacyLight2Value = 0xFFB6B6B6;

    // Mappage des couleurs
    switch (legacyColor.value) {
      case legacyPrimaryColorValue:
        return AppColors.primaryColor;
      case legacySecondaryColorValue:
        return AppColors.secondaryColor;
      case legacyErrorColorValue:
        return AppColors.errorColor;
      case legacySuccessColorValue:
        return AppColors.successColor;
      case legacyDark1Value:
        return AppColors.dark1;
      case legacyDark2Value:
        return AppColors.dark2;
      case legacyDark3Value:
        return AppColors.dark3;
      case legacyLight1Value:
        return AppColors.light1;
      case legacyLight2Value:
        return AppColors.light2;
      default:
        // Si la couleur n'est pas reconnue, retourner la couleur originale
        return legacyColor;
    }
  }

  /// Guide pour remplacer les couleurs LegacyAppColors par AppColors
  static const Map<String, String> migrationGuide = {
    'LegacyAppColors.primaryColor': 'AppColors.primaryColor',
    'LegacyAppColors.secondaryColor': 'AppColors.secondaryColor',
    'LegacyAppColors.errorColor': 'AppColors.errorColor',
    'LegacyAppColors.successColor': 'AppColors.successColor',
    'LegacyAppColors.dark1': 'AppColors.dark1',
    'LegacyAppColors.dark2': 'AppColors.dark2',
    'LegacyAppColors.dark3': 'AppColors.dark3',
    'LegacyAppColors.light1': 'AppColors.light1',
    'LegacyAppColors.light2': 'AppColors.light2',
  };
  
  /// Mappages supplémentaires pour les propriétés couramment utilisées
  static const Map<String, String> additionalMappings = {
    'textColor': 'AppColors.textColor',
    'textLightColor': 'AppColors.textLightColor',
    'secondaryTextColor': 'AppColors.secondaryTextColor',
    'backgroundColor': 'AppColors.backgroundColor',
    'cardColor': 'AppColors.cardColor',
    'accentColor': 'AppColors.accentColor',
    'successGreen': 'AppColors.successGreen',
  };
  
  /// Vérifie si une propriété a un équivalent dans le nouveau système de couleurs
  static bool hasMapping(String propertyName) {
    return migrationGuide.containsKey(propertyName) || 
           additionalMappings.containsKey(propertyName);
  }
  
  /// Obtient l'équivalent de la propriété dans le nouveau système de couleurs
  static String getMapping(String propertyName) {
    if (migrationGuide.containsKey(propertyName)) {
      return migrationGuide[propertyName]!;
    } else if (additionalMappings.containsKey(propertyName)) {
      return additionalMappings[propertyName]!;
    } else {
      return 'AppColors.primaryColor'; // Valeur par défaut si aucun mappage n'est trouvé
    }
  }
} 