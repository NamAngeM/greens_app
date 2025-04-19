const express = require('express');
const ollamaController = require('../controllers/ollamaController');

const router = express.Router();

// Route pour vérifier la disponibilité d'Ollama
router.get('/status', ollamaController.checkStatus);

// Route pour obtenir la liste des modèles disponibles
router.get('/models', ollamaController.getModels);

// Route pour envoyer une requête au modèle
router.post('/chat', ollamaController.generateResponse);

// Route pour tester des paramètres spécifiques
router.post('/test-parameters', ollamaController.testParameters);

module.exports = router; 