# Scanner de Produits avec Empreinte Carbone

Ce module améliore la fonctionnalité de scanner de code-barres de l'application en y ajoutant une analyse détaillée de l'empreinte carbone des produits.

## Fonctionnalités Principales

1. **Scanner Amélioré**
   - Interface utilisateur moderne et responsive
   - Animation de scan pour une meilleure expérience utilisateur
   - Mode de scan continu (plusieurs scans consécutifs)
   - Historique des scans récents

2. **Calcul d'Empreinte Carbone Avancé**
   - Analyse basée sur les données Agribalyse
   - Décomposition détaillée de l'empreinte carbone (production, transport, emballage, transformation)
   - Conversion en équivalents concrets (km en voiture, charges de smartphone, etc.)
   - Score écologique sur une échelle de 0 à 10 avec notation de A à E

3. **Visualisation de l'Impact**
   - Graphiques pour visualiser la répartition de l'empreinte carbone
   - Indicateurs visuels avec code couleur
   - Affichage de l'empreinte eau

4. **Conseils Personnalisés**
   - Recommandations adaptées au type de produit scanné
   - Suggestions d'alternatives plus écologiques
   - Conseils pour réduire l'impact environnemental

## Architecture du Module

- **Models**: Modèles de données pour les produits et leur impact environnemental
- **Services**: 
  - `AgribalyseService`: Gestion des données Agribalyse et recherche de produits
  - `CarbonFootprintCalculator`: Calcul détaillé de l'empreinte carbone
- **Screens**: 
  - `EnhancedScannerScreen`: Interface principale du scanner
  - `ProductCarbonDetailScreen`: Affichage détaillé de l'empreinte carbone d'un produit
- **Widgets**: Composants réutilisables pour l'interface utilisateur

## Utilisation des Données

Le module utilise les fichiers CSV dans le répertoire `data_raw` :
- `agribalyse_products_raw.csv`: Informations sur les produits
- `agribalyse_carbon_raw.csv`: Données d'empreinte carbone
- `agribalyse_water_raw.csv`: Données d'empreinte eau

## Intégration

Le scanner est accessible depuis :
- La page d'accueil via un widget d'accès rapide
- Le menu principal
- La section "Outils" de l'application

## Futures Améliorations

- Intégration d'une base de données de produits plus étendue
- Fonctionnalité de scan offline
- Comparaison directe entre plusieurs produits
- Intégration avec la progression et les défis de l'utilisateur 