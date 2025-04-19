# API GreenMinds pour LLM

Cette API sert d'intermédiaire entre l'application GreenMinds et le modèle Llama3 exécuté localement via Ollama.

## Configuration spéciale pour Android

Cette API est configurée pour être accessible depuis un émulateur Android, en écoutant sur toutes les interfaces réseau (`0.0.0.0`).

### Adresse spéciale pour l'émulateur Android

Sur un émulateur Android, pour accéder à la machine hôte, il faut utiliser l'adresse IP spéciale `10.0.2.2` au lieu de `localhost` :
- L'adresse `10.0.2.2` dans l'émulateur est redirigée vers `127.0.0.1` (localhost) de votre machine.

## Prérequis

- Node.js (v14 ou supérieur)
- Ollama installé et fonctionnel
- Le modèle Llama3 chargé dans Ollama (`ollama pull llama3`)

## Installation

1. Clonez ou créez ce dossier avec tous les fichiers
2. Installez les dépendances :
```
npm install
```
3. Démarrez le serveur :
```
npm start
```

## Configuration du pare-feu

Si vous utilisez un pare-feu sur votre machine, assurez-vous que les ports 3000 (API) et 11434 (Ollama) sont autorisés à recevoir des connexions.

## Utilisation avec l'émulateur Android

1. Lancez d'abord le serveur API : `npm start`
2. Vérifiez que Ollama est en cours d'exécution : `ollama serve`
3. Dans l'application Flutter, utilisez l'adresse `10.0.2.2` pour se connecter à l'API

## Tester l'API

Pour vérifier que l'API fonctionne correctement, vous pouvez utiliser ces endpoints :

- `GET http://localhost:3000/api/health` - Vérifier que l'API est en cours d'exécution
- `GET http://localhost:3000/api/llm/status` - Vérifier la connexion à Ollama
- `GET http://localhost:3000/api/llm/models` - Obtenir la liste des modèles disponibles

## Endpoints

- `GET /api/health` - Vérifier que l'API fonctionne
- `GET /api/llm/status` - Vérifier la connexion à Ollama
- `GET /api/llm/models` - Obtenir la liste des modèles disponibles
- `POST /api/llm/chat` - Générer une réponse (requiert `text` dans le corps)
- `POST /api/llm/test-parameters` - Tester des paramètres spécifiques

## Dépannage

### Le serveur se lance mais l'application ne peut pas s'y connecter

- Assurez-vous que votre pare-feu ne bloque pas les connexions entrantes
- Vérifiez que le serveur écoute bien sur toutes les interfaces (`0.0.0.0`)
- Essayez de vous connecter directement à Ollama depuis l'application

### Ollama n'est pas détecté

- Vérifiez qu'Ollama est en cours d'exécution avec `ollama serve`
- Assurez-vous que le modèle llama3 est installé avec `ollama list`
- Si nécessaire, installez le modèle avec `ollama pull llama3` 