# Vérifier l'exécution d'Ollama et la configuration du chatbot

Ce guide explique comment vérifier qu'Ollama est en cours d'exécution avec le modèle Gemma installé, puis comment configurer l'URL de l'API dans les paramètres du chatbot GreenMinds.

## 1. Vérifier qu'Ollama est en cours d'exécution

### Sur Windows

1. **Vérifier dans la barre des tâches**
   - Regardez dans la barre des tâches Windows (en bas à droite)
   - Vous devriez voir l'icône d'Ollama (un cercle avec un O)
   - Si vous ne voyez pas l'icône, Ollama n'est probablement pas en cours d'exécution

2. **Lancer Ollama s'il n'est pas en cours d'exécution**
   - Recherchez "Ollama" dans le menu Démarrer de Windows
   - Cliquez sur l'application pour la lancer
   - Attendez quelques secondes que le service démarre
   - L'icône devrait apparaître dans la barre des tâches

## 2. Vérifier que le modèle Gemma est installé

1. **Ouvrir l'invite de commande Windows**
   - Appuyez sur `Win + R` pour ouvrir la boîte de dialogue Exécuter
   - Tapez `cmd` et appuyez sur Entrée

2. **Vérifier les modèles installés**
   - Dans l'invite de commande, tapez la commande suivante :
   ```
   ollama list
   ```
   - Vous devriez voir une liste des modèles installés
   - Vérifiez que "gemma" apparaît dans cette liste

3. **Si Gemma n'est pas installé**
   - Exécutez la commande suivante pour l'installer :
   ```
   ollama pull gemma
   ```
   - Attendez que le téléchargement et l'installation soient terminés
   - Cela peut prendre plusieurs minutes selon votre connexion Internet

## 3. Configurer l'URL de l'API dans l'application GreenMinds

1. **Ouvrir l'application GreenMinds**
   - Lancez l'application sur votre appareil

2. **Accéder aux paramètres du chatbot**
   - Naviguez vers l'écran du chatbot
   - Appuyez sur l'icône d'engrenage ⚙️ dans le coin supérieur droit
   - Cela vous amènera à l'écran des paramètres du modèle

3. **Vérifier/configurer l'URL de l'API**
   - Dans le champ "URL de l'API Ollama", vérifiez que l'URL est :
   ```
   http://localhost:11434/api/generate
   ```
   - Cette adresse est l'URL par défaut d'Ollama

4. **Tester la connexion**
   - Appuyez sur le bouton "Tester la connexion"
   - Si tout est correctement configuré, vous devriez voir un message de succès
   - Si vous obtenez une erreur, vérifiez qu'Ollama est bien en cours d'exécution

5. **Sauvegarder les paramètres**
   - Appuyez sur le bouton "Sauvegarder"
   - Un message de confirmation devrait s'afficher

## 4. Utiliser le chatbot

1. **Retourner à l'écran du chatbot**
   - Appuyez sur la flèche de retour pour revenir à l'écran du chatbot

2. **Vérifier la connexion**
   - Si la connexion est établie, vous devriez pouvoir utiliser le chatbot
   - Essayez de poser une question liée à l'écologie, par exemple :
   ```
   Comment puis-je réduire mon empreinte carbone au quotidien ?
   ```
   - Le chatbot devrait répondre en utilisant le modèle Gemma local

## Résolution de problèmes

- **Ollama ne démarre pas** : Redémarrez votre ordinateur et essayez à nouveau
- **Erreur lors du test de connexion** : Vérifiez que l'URL est correcte et qu'Ollama est en cours d'exécution
- **Gemma n'apparaît pas dans la liste** : Exécutez `ollama pull gemma` pour télécharger le modèle
- **Réponses lentes** : C'est normal, les modèles LLM locaux peuvent être lents selon votre matériel 