# Guide d'implémentation des améliorations

Ce guide détaille les étapes à suivre pour implémenter les améliorations proposées pour l'application GreenApp afin de résoudre les problèmes de cohésion et de redondance.

## 1. Unification des modèles de données

### Objectif
Remplacer les classes `Product` et `ProductModel` par le nouveau modèle unifié `UnifiedProduct` pour simplifier la gestion des données.

### Étapes
1. Ajouter le nouveau fichier `lib/models/product_unified.dart`
2. Modifier progressivement les références aux anciens modèles:
   - Commencer par les contrôleurs
   - Puis les services
   - Enfin les vues

### Migration des données
```dart
// Conversion d'un ancien Product vers UnifiedProduct
UnifiedProduct fromLegacyProduct(Product product) {
  return UnifiedProduct(
    id: product.id,
    name: product.name,
    description: product.description,
    price: product.price,
    imageUrl: product.imageAsset ?? product.imageUrl,
    categories: [product.category],
    isEcoFriendly: product.isEcoFriendly,
    brand: product.brand,
    ecoRating: product.ecoRating,
    certifications: product.certifications,
    ecoCriteria: product.ecoCriteria,
    // ... autres champs
  );
}

// Conversion d'un ancien ProductModel vers UnifiedProduct
UnifiedProduct fromLegacyProductModel(ProductModel model) {
  return UnifiedProduct(
    id: model.id,
    name: model.name,
    description: model.description ?? "",
    price: model.price,
    imageUrl: model.imageUrl,
    categories: model.categories,
    isEcoFriendly: model.isEcoFriendly,
    brand: model.brand,
    merchantUrl: model.merchantUrl,
    ecoRating: 0.0, // Valeur par défaut
    certifications: [],
    ecoCriteria: {},
  );
}
```

## 2. Service de données de test centralisé

### Objectif
Centraliser toutes les données de test dans un seul service pour éviter la duplication et faciliter les mises à jour.

### Étapes
1. Ajouter le nouveau fichier `lib/services/mock_data_service.dart`
2. Remplacer les données de test codées en dur dans chaque vue/contrôleur par des appels à ce service:

```dart
// Avant
List<Product> productsToShow = [
  Product(...),
  Product(...),
];

// Après
final mockDataService = MockDataService();
List<UnifiedProduct> productsToShow = mockDataService.getEcoFriendlyProducts();
```

3. Pour la transition, créer des méthodes qui renvoient les anciens types de données jusqu'à ce que la migration soit complète:

```dart
// Dans MockDataService
List<Product> getLegacyProducts() {
  return getEcoFriendlyProducts().map((product) => 
    Product(
      id: product.id,
      name: product.name,
      // ...
    )
  ).toList();
}
```

## 3. Correction du problème d'overflow

### Objectif
Résoudre le problème d'overflow de 29 pixels dans la carte de produit.

### Étapes
1. Appliquer les modifications à la méthode `_buildProductCard` dans `home_view.dart`
2. Vérifier que les contraintes d'espace sont bien gérées avec des `Expanded` pour les textes extensibles
3. Tester l'interface avec différentes tailles de texte et d'écran

## 4. Amélioration de la gestion d'état et d'erreurs

### Objectif
Centraliser la gestion des erreurs et améliorer la gestion d'état de l'application.

### Étapes
1. Ajouter le nouveau fichier `lib/services/app_error_handler.dart`
2. Implémenter le nouveau contrôleur `ProductControllerUpdated`
3. Modifier les vues pour utiliser cette gestion d'erreurs:

```dart
// Exemple d'utilisation dans une vue
try {
  await productController.getEcoFriendlyProducts();
} catch (e) {
  final errorHandler = AppErrorHandler();
  errorHandler.showErrorSnackBar(
    context, 
    'Erreur lors du chargement des produits écologiques',
    allowRetry: true,
    onRetry: () => productController.getEcoFriendlyProducts(),
  );
}
```

4. Ajouter une logique de retry pour les requêtes réseau:

```dart
// Utilisation de la fonction handleFutureWithRetry
try {
  final result = await AppErrorHandler().handleFutureWithRetry(
    () => apiService.fetchData(),
    maxRetries: 3,
    retryDelay: const Duration(seconds: 2),
  );
  // Utiliser le résultat
} catch (e) {
  // Gérer l'erreur après tous les retries
}
```

## 5. Transition et déploiement

Pour une transition en douceur, implémentez ces changements progressivement:

1. Commencez par ajouter les nouveaux fichiers sans supprimer les anciens
2. Implémentez la conversion entre anciens et nouveaux modèles
3. Remplacez progressivement l'utilisation des anciens services par les nouveaux
4. Une fois que tout fonctionne avec les nouveaux services, supprimez les anciens

## Recommandations
- Faites des tests approfondis à chaque étape
- Utilisez des feature flags pour activer/désactiver les nouvelles fonctionnalités
- Documentez les changements dans le code pour faciliter la maintenance
- Mettez à jour les tests unitaires pour couvrir les nouveaux services

# Guide d'Implémentation

## Tests à effectuer

### Tests Unitaires
- Services : OllamaService, CacheService, DialogflowService
- Gestionnaire d'erreurs : AppErrorHandler
- Modèles de données

### Tests d'Intégration
- Flux complet de conversation
- Gestion du cache
- Reconnexion automatique

### Tests de Performance
- Temps de réponse < 2s
- Utilisation mémoire < 100MB
- Taille du cache

## Métriques de Performance
- Taux de réussite des requêtes
- Temps moyen de réponse
- Utilisation du cache
- Taux d'erreurs

## Critères de Validation
- Couverture de tests > 80%
- Pas d'erreurs non gérées
- Documentation complète
- Code lint sans erreurs