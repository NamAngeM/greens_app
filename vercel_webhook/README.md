# Webhook Dialogflow pour GreenBot

Ce webhook sert de backend pour l'agent Dialogflow de votre chatbot écologique. Il est conçu pour fonctionner avec Vercel, une plateforme serverless qui permet un déploiement facile et gratuit.

## Fonctionnalités implémentées

- Calcul d'empreinte carbone
- Conseils écologiques personnalisés
- Informations sur le recyclage
- Événements écologiques par ville
- Alternatives durables à des produits courants

## Prérequis

- Un compte [Vercel](https://vercel.com)
- Node.js 14+ installé localement
- Un agent Dialogflow configuré

## Installation et développement local

1. Clonez ce dépôt
2. Installez les dépendances:
   ```
   npm install
   ```
3. Pour tester localement:
   ```
   npm run dev
   ```

## Déploiement sur Vercel

### Première méthode: CLI Vercel

1. Installer la CLI Vercel globalement:
   ```
   npm install -g vercel
   ```

2. Se connecter à Vercel:
   ```
   vercel login
   ```

3. Déployer:
   ```
   npm run deploy
   ```

### Deuxième méthode: Depuis GitHub

1. Poussez ce code sur un dépôt GitHub
2. Connectez-vous à votre compte Vercel
3. Créez un nouveau projet et importez votre dépôt GitHub
4. Configurez les variables d'environnement si nécessaire
5. Déployez

## Configuration de Dialogflow

1. Dans la console Dialogflow, allez dans la section "Fulfillment"
2. Activez le webhook
3. Dans l'URL, entrez: `https://votre-projet.vercel.app/api/dialogflow`
4. Sauvegardez

## Architecture de Vercel

- `/api/dialogflow.js`: Point d'entrée du webhook (API serverless)
- `vercel.json`: Configuration pour Vercel
- `package.json`: Dépendances et scripts

## Extensibilité

Pour ajouter de nouvelles fonctionnalités:

1. Identifiez l'intent dans Dialogflow
2. Ajoutez un nouveau cas dans le switch du fichier `api/dialogflow.js`
3. Implémentez la fonction de traitement correspondante
4. Redéployez

## Monitoring

Vous pouvez surveiller les requêtes et les erreurs depuis le tableau de bord Vercel, dans la section "Logs". 