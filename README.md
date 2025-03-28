# Greens App

Une application Flutter dédiée à promouvoir un mode de vie écologique et durable.

## Corrections effectuées

### 1. Problèmes d'importation
- Correction de la double importation pour la vue de calcul d'empreinte carbone dans `app_router.dart`
- Mise à jour des chemins d'importation pour pointer vers les fichiers existants

### 2. Dépendances
- Mise à jour des versions des packages Firebase pour utiliser des versions compatibles et existantes:
  - firebase_core: ^2.15.1
  - firebase_auth: ^4.7.3
  - cloud_firestore: ^4.8.5
  - provider: ^6.0.5

### 3. Ressources d'images
- Correction des références aux images pour utiliser les chemins corrects
- Utilisation de l'image `logo.png` depuis le sous-dossier `logo`
- Utilisation d'une image de fond existante pour la bannière

### 4. Navigation
- Ajout des routes manquantes dans `app_router.dart` pour toutes les fonctionnalités mentionnées dans les TODOs
- Mise à jour des navigations dans `home_view.dart` pour utiliser les routes nommées
- Implémentation de la navigation via la barre inférieure avec les routes nommées

### 5. Configuration Firebase
- Restructuration de la configuration Firebase avec la classe `DefaultFirebaseOptions`
- Mise à jour du fichier `main.dart` pour utiliser la classe `FirebaseConfig`

## Problèmes restants à résoudre

### 1. Implémentation des vues
- Les vues temporaires ont été ajoutées pour les routes, mais elles doivent être implémentées complètement:
  - Vue des produits
  - Vue des récompenses
  - Vue du profil
  - Vue des articles
  - Vue des paramètres
  - Vue d'aide
  - Vue du chatbot

### 2. Ressources manquantes
- Certaines images référencées dans le code sont toujours manquantes et doivent être ajoutées:
  - `banner.png` (temporairement remplacée par une image existante)

### 3. Incohérence architecturale
- Résoudre l'incohérence entre les mémoires qui mentionnent "FlexiBook" et le code actuel pour "Greens App"
- Clarifier si l'application doit être axée sur les réservations (FlexiBook) ou sur l'écologie (Greens App)

## Comment exécuter l'application

1. Assurez-vous d'avoir Flutter installé (version 3.3.0 ou supérieure)
2. Clonez ce dépôt
3. Exécutez `flutter pub get` pour installer les dépendances
4. Exécutez `flutter run` pour lancer l'application

## Structure du projet

- `lib/controllers/` - Contrôleurs pour la gestion de l'état
- `lib/firebase/` - Configuration Firebase
- `lib/models/` - Modèles de données
- `lib/services/` - Services pour l'accès aux données
- `lib/utils/` - Utilitaires (couleurs, routes, etc.)
- `lib/views/` - Écrans de l'application
- `lib/widgets/` - Widgets réutilisables
- `assets/images/` - Ressources d'images pour le design de l'application
