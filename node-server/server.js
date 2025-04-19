const express = require('express');
const cors = require('cors');
const llmRoutes = require('./routes/llm');
const errorHandler = require('./middleware/errorHandler');
const config = require('./config/config');

// Initialisation de l'application Express
const app = express();

// Middleware
app.use(cors());
app.use(express.json());

// Routes
app.use('/api/llm', llmRoutes);

// Route de test pour vérifier que l'API fonctionne
app.get('/api/health', (req, res) => {
  res.status(200).json({ status: 'OK', message: 'API fonctionnelle' });
});

// Middleware de gestion des erreurs
app.use(errorHandler);

// Démarrage du serveur
const HOST = '0.0.0.0'; // Écouter sur toutes les interfaces, pas seulement localhost
const PORT = config.port || 3000;
app.listen(PORT, HOST, () => {
  console.log(`Serveur en cours d'exécution sur http://${HOST}:${PORT}`);
  console.log(`Pour accéder depuis l'émulateur Android, utilisez http://10.0.2.2:${PORT}`);
}); 