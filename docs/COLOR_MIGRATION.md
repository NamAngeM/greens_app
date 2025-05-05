# Guide de Migration des Couleurs

Ce document explique comment migrer de l'ancien système de couleurs (`LegacyAppColors`) vers le nouveau système (`AppColors`).

## Pourquoi migrer ?

- Homogénéité des couleurs dans toute l'application
- Nouvelles couleurs adaptées à la charte graphique actuelle
- Meilleures descriptions et organisation des couleurs
- Support amélioré pour l'accessibilité et les thèmes

## Changements principaux

### Couleurs principales

| Ancienne couleur | Valeur | Nouvelle couleur | Valeur | Commentaire |
|------------------|--------|-----------------|--------|-------------|
| `LegacyAppColors.primaryColor` | `0xFF4CC771` | `AppColors.primaryColor` | `0xFF1E3A8A` | Changement vers un bleu foncé |
| `LegacyAppColors.secondaryColor` | `0xFF2B4458` | `AppColors.secondaryColor` | `0xFF34D399` | Nouvelle teinte de vert |

### Couleurs conservées

Les couleurs suivantes ont été conservées :
- `dark1`, `dark2`, `dark3`
- `light1`, `light2`
- `errorColor`, `successColor`

### Nouvelles couleurs et alias

De nombreuses nouvelles couleurs ont été ajoutées, notamment :
- Couleurs de fond : `background`, `cardBackground`, `disabledBackground`
- Couleurs de texte : `textPrimary`, `textSecondary`, `textLight`, `textDisabled`
- Couleurs d'état : `warningColor`, `infoColor` (en plus des existantes)
- Couleurs pour l'empreinte carbone : `lowCarbonColor`, `mediumCarbonColor`, `highCarbonColor`
- Couleurs spécifiques pour certaines vues
- Couleurs fonctionnelles : `dividerColor`, `shadowColor`, `overlayColor`

Des alias ont également été créés pour faciliter la migration :
- `textColor` → alias pour `textPrimary`
- `textLightColor` → alias pour `textSecondary`
- `secondaryTextColor` → alias pour `textSecondary`
- `backgroundColor` → alias pour `background`
- `cardColor` → alias pour `cardBackground`
- `accentColor` → couleur d'accent verte
- `successGreen` → alias pour `successColor`

## Comment migrer ?

### Étape 1 : Importer le bon fichier

Remplacez :
```dart
import 'package:greens_app/utils/colors.dart';
```

Par :
```dart
import 'package:greens_app/utils/app_colors.dart';
```

### Étape 2 : Mettre à jour les références

Remplacez toutes les références à `LegacyAppColors` par `AppColors`.

Par exemple :
```dart
// Avant
color: LegacyAppColors.primaryColor,

// Après
color: AppColors.primaryColor,
```

### Étape 3 : Vérifier les couleurs spécifiques

Pour certaines couleurs, il peut être préférable d'utiliser des couleurs plus spécifiques du nouveau système.

Par exemple, au lieu de simplement remplacer `LegacyAppColors.light1` par `AppColors.light1`, considérez si `AppColors.background` ou `AppColors.cardBackground` serait plus approprié selon le contexte.

### Outil d'aide à la migration

Un outil utilitaire a été créé pour faciliter la migration :

```dart
import 'package:greens_app/utils/color_migration.dart';

// Pour convertir une couleur LegacyAppColors en couleur AppColors
Color newColor = ColorMigration.mapLegacyColor(legacyColor);

// Pour consulter le guide de mappage
print(ColorMigration.migrationGuide['LegacyAppColors.primaryColor']);
// Affiche : "AppColors.primaryColor"
```

### Script de vérification

Exécutez le script suivant pour identifier les fichiers qui utilisent encore l'ancien système de couleurs :

```bash
dart scripts/color_migration_check.dart
```

## Questions fréquentes

**Q: Que faire si j'ai besoin de l'ancienne couleur primaire verte ?**  
R: Utilisez `AppColors.accentGreen`, `AppColors.primaryGreen` ou `AppColors.accentColor` selon le cas d'usage.

**Q: Les couleurs dark2 et secondaryColor étaient identiques dans l'ancien système. Qu'en est-il maintenant ?**  
R: Dans le nouveau système, elles sont distinctes. `AppColors.dark2` conserve la même valeur que l'ancienne `LegacyAppColors.dark2`, mais `AppColors.secondaryColor` a désormais une nouvelle valeur.

**Q: Que faire si j'ai besoin d'assistance pour migrer mon code ?**  
R: Consultez la documentation ou demandez de l'aide à l'équipe de développement. 