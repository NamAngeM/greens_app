# Tableau de Bord Administratif Green Minds

Ce tableau de bord administratif est conçu pour gérer l'application Green Minds de manière efficace. Il est optimisé pour une utilisation sur le web.

## Fonctionnalités

Le tableau de bord administratif offre plusieurs fonctionnalités de gestion :

1. **Vue d'ensemble** - Statistiques et métriques clés sur l'utilisation de l'application
2. **Gestion des utilisateurs** - Visualisation et gestion des comptes utilisateurs
3. **Gestion des challenges** - Création, modification et suppression des défis écologiques
4. **Gestion des produits** - Ajout, mise à jour et suppression des produits écologiques
5. **Gestion des articles** - Publication et édition du contenu éditorial
6. **Statistiques avancées** - Analyse approfondie des données d'utilisation

## Accès au tableau de bord

Le tableau de bord administratif est accessible de deux façons :

1. **Via l'application** - Dans l'application mobile, accédez aux paramètres puis cliquez sur "Admin Dashboard"
2. **Via le web** - Accédez directement à l'URL : `https://votredomaine.com/#/admin_dashboard`

## Prérequis techniques

Pour que le tableau de bord fonctionne correctement, assurez-vous d'installer les dépendances suivantes :

```bash
flutter pub add data_table_2
flutter pub add fl_chart
```

## Mode de déploiement web

Pour déployer votre application en mode web avec le tableau de bord administratif :

1. Vérifiez que Flutter web est activé :
   ```bash
   flutter config --enable-web
   ```

2. Construisez la version web :
   ```bash
   flutter build web
   ```

3. Déployez les fichiers générés dans le dossier `build/web` sur votre serveur web

## Sécurité

Par défaut, le tableau de bord administratif est accessible à tous les utilisateurs de l'application. Pour restreindre l'accès, il est recommandé d'implémenter une vérification des rôles utilisateur.

Exemple de code à ajouter dans `admin_dashboard_view.dart` :

```dart
// Vérification si l'utilisateur est administrateur
final authController = Provider.of<AuthController>(context, listen: false);
if (!authController.isUserAdmin()) {
  return const Scaffold(
    body: Center(
      child: Text(
        "Accès refusé. Vous n'avez pas les droits d'administration nécessaires.",
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18),
      ),
    ),
  );
}
```

## Personnalisation

Le tableau de bord peut être personnalisé en fonction de vos besoins spécifiques. Les principales zones à modifier sont :

- **Modèles de données** - Ajoutez vos propres modèles dans le dossier `lib/models/`
- **Controllers** - Étendez les contrôleurs existants ou créez-en de nouveaux dans `lib/controllers/`
- **Widgets** - Créez des widgets personnalisés pour l'affichage des données

## Support technique

Pour toute question ou assistance concernant le tableau de bord administratif, veuillez contacter l'équipe technique à l'adresse support@greensapp.com. 