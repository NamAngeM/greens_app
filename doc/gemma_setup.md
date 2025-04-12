# Configuration de Gemma LLaMA pour GreenMinds

Ce document explique comment configurer et utiliser le modèle de langage Gemma de Google via LLaMA.cpp pour le chatbot écologique de l'application GreenMinds.

## Prérequis

- Python 3.10 ou supérieur
- Git
- CMake
- Compilateur C++ (gcc/clang)
- GPU compatible CUDA (recommandé mais non obligatoire)
- 8+ Go de RAM
- 5+ Go d'espace disque

## Installation du modèle local

### 1. Cloner le dépôt llama.cpp

```bash
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
```

### 2. Compiler le projet

```bash
# Sur Linux/macOS
cmake -B build
cmake --build build --config Release

# Sur Windows avec MSVC
cmake -B build
cmake --build build --config Release
```

### 3. Télécharger le modèle Gemma

1. Créez un compte sur [Hugging Face](https://huggingface.co/) si vous n'en avez pas déjà un
2. Visitez [google/gemma-2b-it](https://huggingface.co/google/gemma-2b-it) et acceptez les conditions d'utilisation
3. Téléchargez le fichier `gemma-2b-it-q4_0.gguf` (version quantifiée pour une meilleure performance)

### 4. Lancer le serveur

```bash
# Sur Linux/macOS
./build/bin/server -m /chemin/vers/gemma-2b-it-q4_0.gguf --host 127.0.0.1 --port 8000 -c 2048

# Sur Windows
.\build\bin\Release\server.exe -m C:\chemin\vers\gemma-2b-it-q4_0.gguf --host 127.0.0.1 --port 8000 -c 2048
```

## Configuration dans l'application GreenMinds

1. Ouvrez l'application GreenMinds sur votre appareil
2. Accédez à l'écran du chatbot GreenBot
3. Appuyez sur l'icône de paramètres ⚙️ dans le coin supérieur droit
4. Dans le champ "URL de l'API", entrez : `http://localhost:8000/api/v1/generate` (ou modifiez l'adresse IP si le serveur est sur un autre appareil)
5. Appuyez sur "Tester la connexion" pour vérifier que tout fonctionne
6. Sauvegardez les paramètres

## Utilisation

Une fois le serveur Gemma en cours d'exécution et l'application configurée :

1. Retournez à l'écran du chatbot
2. Vous devriez voir le statut du modèle passer à "connecté" 
3. Posez des questions sur l'écologie, le développement durable, ou tout autre sujet environnemental

## Résolution des problèmes

### Le modèle ne se connecte pas

- Vérifiez que le serveur est bien en cours d'exécution
- Assurez-vous que l'URL de l'API est correcte et accessible depuis votre appareil
- Vérifiez qu'aucun pare-feu ne bloque la connexion

### Performances lentes

- Si vous avez un GPU, assurez-vous que llama.cpp est compilé avec le support CUDA
- Utilisez la version quantifiée du modèle (`q4_0.gguf`)
- Réduisez le paramètre `-c` (taille du contexte) si nécessaire

### Erreurs mémoire

- Réduisez la taille du contexte avec l'option `-c`
- Utilisez une version plus légère du modèle (comme `gemma-2b` au lieu de versions plus grandes)
- Fermez les applications gourmandes en mémoire

## Avantages de l'utilisation locale

- Confidentialité : vos questions et données restent sur votre appareil
- Aucune connexion Internet requise
- Pas de frais d'API
- Personnalisation possible du modèle 