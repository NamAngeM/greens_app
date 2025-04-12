# Configuration de Gemma avec Ollama pour GreenMinds

Ce guide explique comment configurer et utiliser le modèle de langage Gemma de Google via Ollama pour le chatbot écologique de l'application GreenMinds.

## Prérequis

- Windows 10 ou 11 (64 bits)
- 8 Go de RAM minimum (16 Go recommandés)
- 5 Go d'espace disque disponible
- Processeur 64 bits avec au moins 4 cœurs

## Installation d'Ollama

1. **Télécharger Ollama**
   - Visitez le site officiel d'Ollama : [https://ollama.ai](https://ollama.ai)
   - Cliquez sur "Download" et sélectionnez la version Windows
   - Exécutez le fichier d'installation téléchargé
   - Suivez les instructions d'installation

2. **Vérifier l'installation**
   - Une fois l'installation terminée, Ollama devrait démarrer automatiquement
   - Vous devriez voir l'icône d'Ollama dans la barre des tâches

## Installation du modèle Gemma

1. **Ouvrir l'invite de commande Windows**
   - Appuyez sur `Win + R`, tapez `cmd` et appuyez sur Entrée
   - Ou recherchez "Command Prompt" dans le menu Démarrer

2. **Télécharger et installer le modèle Gemma**
   - Exécutez la commande suivante :
   ```cmd
   ollama pull gemma
   ```
   - Le téléchargement et l'installation peuvent prendre plusieurs minutes, selon votre connexion Internet
   - Une barre de progression s'affichera pendant le téléchargement

3. **Vérifier l'installation du modèle**
   - Une fois l'installation terminée, vous devriez voir un message de confirmation
   - Pour vérifier que Gemma est correctement installé, exécutez :
   ```cmd
   ollama list
   ```
   - Vous devriez voir "gemma" dans la liste des modèles disponibles

## Configuration dans l'application GreenMinds

1. **Ouvrir l'application GreenMinds**

2. **Accéder aux paramètres du chatbot**
   - Allez à l'écran du chatbot GreenBot
   - Appuyez sur l'icône ⚙️ dans le coin supérieur droit

3. **Configurer l'URL API d'Ollama**
   - Dans le champ "URL de l'API Ollama", assurez-vous que l'URL est bien :
   ```
   http://localhost:11434/api/generate
   ```
   - Appuyez sur "Tester la connexion" pour vérifier que tout fonctionne
   - Si la connexion est réussie, vous verrez un message de confirmation
   - Appuyez sur "Sauvegarder" pour enregistrer vos paramètres

## Utilisation du chatbot

1. **Retournez à l'écran du chatbot**
   - Vous devriez maintenant voir que le statut est "connecté"
   - Le chatbot est prêt à répondre à vos questions sur l'écologie

2. **Posez des questions sur l'écologie**
   - Le chatbot est spécialisé dans les sujets liés à l'écologie
   - Il filtrera automatiquement les questions qui ne sont pas liées à l'environnement
   - Exemples de questions :
     - "Comment réduire mon empreinte carbone ?"
     - "Qu'est-ce que le développement durable ?"
     - "Quels sont les meilleurs produits éco-responsables ?"

## Résolution des problèmes

### Ollama ne démarre pas

- Vérifiez que votre ordinateur répond aux exigences minimales
- Redémarrez votre ordinateur et essayez de lancer Ollama à nouveau
- Réinstallez Ollama si le problème persiste

### Le modèle Gemma n'est pas visible

- Exécutez `ollama list` pour voir si le modèle est installé
- Si Gemma n'apparaît pas, exécutez à nouveau `ollama pull gemma`
- Vérifiez que vous avez suffisamment d'espace disque disponible

### Erreur de connexion dans l'application

- Assurez-vous qu'Ollama est en cours d'exécution (vérifiez l'icône dans la barre des tâches)
- Vérifiez que l'URL de l'API est correctement entrée
- Essayez de redémarrer Ollama : clic droit sur l'icône dans la barre des tâches et sélectionnez "Restart"

### Performances lentes

- Fermez les applications qui consomment beaucoup de ressources
- Utilisez un modèle plus léger si disponible (comme gemma:2b au lieu de gemma:7b)
- Redémarrez Ollama pour libérer de la mémoire

## Commandes Ollama utiles

- `ollama list` : Affiche la liste des modèles installés
- `ollama pull gemma:2b` : Télécharge la version plus légère de Gemma (2 milliards de paramètres)
- `ollama rm gemma` : Supprime le modèle Gemma
- `ollama serve` : Démarre le serveur Ollama manuellement 