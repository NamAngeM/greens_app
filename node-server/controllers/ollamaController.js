const axios = require('axios');
const config = require('../config/config');

// URL de base pour l'API Ollama
const ollamaBaseUrl = config.ollamaUrl || 'http://localhost:11434';

// Vérifier la disponibilité d'Ollama
exports.checkStatus = async (req, res, next) => {
  console.log(`Vérification de la connexion à Ollama (${ollamaBaseUrl})`);
  
  try {
    // Utiliser /api/tags au lieu de /api/health car c'est plus fiable
    const response = await axios.get(`${ollamaBaseUrl}/api/tags`);
    console.log('Connexion à Ollama réussie');
    res.status(200).json({ 
      status: 'OK', 
      connected: true,
      message: 'Connexion à Ollama établie' 
    });
  } catch (error) {
    console.error('Erreur lors de la vérification du statut d\'Ollama:', error.message);
    // Essayer une approche alternative
    try {
      const baseResponse = await axios.get(ollamaBaseUrl);
      // Même un 404 sur l'URL de base signifie que le serveur est en cours d'exécution
      console.log('Serveur Ollama détecté via fallback');
      res.status(200).json({ 
        status: 'OK', 
        connected: true,
        message: 'Connexion à Ollama établie via fallback' 
      });
    } catch (fallbackError) {
      res.status(500).json({ 
        status: 'ERROR', 
        connected: false, 
        message: 'Impossible de se connecter au serveur Ollama',
        error: error.message
      });
    }
  }
};

// Récupérer la liste des modèles disponibles
exports.getModels = async (req, res, next) => {
  try {
    const response = await axios.get(`${ollamaBaseUrl}/api/tags`);
    const models = response.data.models || [];
    res.status(200).json({ 
      status: 'OK', 
      models: models.map(model => model.name) 
    });
  } catch (error) {
    console.error('Erreur lors de la récupération des modèles:', error.message);
    res.status(500).json({ 
      status: 'ERROR', 
      message: 'Erreur lors de la récupération des modèles disponibles',
      error: error.message
    });
  }
};

// Générer une réponse à partir du modèle
exports.generateResponse = async (req, res, next) => {
  try {
    const { text, model = 'llama3', temperature = 0.5, topP = 0.8 } = req.body;

    if (!text) {
      return res.status(400).json({ 
        status: 'ERROR', 
        message: 'Le paramètre "text" est requis' 
      });
    }

    console.log(`Génération de réponse pour: "${text.substring(0, 50)}..."`);
    console.log(`Modèle: ${model}, température: ${temperature}, topP: ${topP}`);

    // Définir le message système pour le contexte écologique, mais plus court pour accélérer la génération
    const systemPrompt = `
Tu es GreenBot, un assistant spécialisé en écologie et développement durable. Fournis des informations précises et concises.
Expertise: changement climatique, biodiversité, énergies renouvelables, gestion des déchets, agriculture durable.
Réponds de manière claire, factuelle et directe. Évite les réponses trop longues.
`;

    // Préparer la requête pour Ollama
    const payload = {
      model: model,
      messages: [
        {
          role: 'system',
          content: systemPrompt
        },
        {
          role: 'user',
          content: text
        }
      ],
      stream: false,
      temperature: temperature,
      top_p: topP,
      // Paramètres pour limiter la longueur de la réponse et accélérer le traitement
      num_predict: 500  // Limiter le nombre de tokens générés
    };

    console.log(`Envoi de la requête à Ollama (${ollamaBaseUrl}/api/chat)`);
    console.time('Temps de génération');

    // Envoyer la requête à Ollama avec un timeout plus long
    const response = await axios.post(`${ollamaBaseUrl}/api/chat`, payload, {
      timeout: 120000 // 120 secondes (2 minutes) au lieu de 60 secondes
    });
    
    console.timeEnd('Temps de génération');
    
    // Extraire la réponse
    const content = response.data.message?.content || 'Pas de réponse';
    console.log(`Réponse reçue (${content.length} caractères)`);

    res.status(200).json({ 
      status: 'OK', 
      response: content 
    });
  } catch (error) {
    console.error('Erreur lors de la génération de la réponse:', error.message);
    console.error('Détails de l\'erreur:', error);

    // Envoyer une réponse alternative en cas de timeout
    if (error.code === 'ECONNABORTED' || error.message.includes('timeout')) {
      return res.status(200).json({
        status: 'TIMEOUT',
        response: "Désolé, la génération de la réponse prend trop de temps. Veuillez essayer une question plus courte ou utiliser la connexion directe à Ollama dans l'application."
      });
    }

    res.status(500).json({ 
      status: 'ERROR', 
      message: `Erreur lors de la génération de la réponse: ${error.message}` 
    });
  }
};

// Tester des paramètres spécifiques pour le modèle
exports.testParameters = async (req, res, next) => {
  try {
    const { text, model = 'llama3', temperature, topP } = req.body;

    if (!text) {
      return res.status(400).json({ 
        status: 'ERROR', 
        message: 'Le paramètre "text" est requis' 
      });
    }

    // Préparer la requête pour Ollama avec les paramètres fournis
    const payload = {
      model: model,
      prompt: text,
      stream: false,
      num_predict: 300  // Limiter le nombre de tokens générés
    };

    // Ajouter les paramètres optionnels s'ils sont définis
    if (temperature !== undefined) payload.temperature = temperature;
    if (topP !== undefined) payload.top_p = topP;

    // Envoyer la requête à Ollama
    const response = await axios.post(`${ollamaBaseUrl}/api/generate`, payload, {
      timeout: 120000  // 120 secondes de timeout
    });
    
    // Extraire la réponse
    const content = response.data.response || 'Pas de réponse';

    res.status(200).json({ 
      status: 'OK', 
      response: content,
      parameters: {
        model,
        temperature: temperature !== undefined ? temperature : 'default',
        topP: topP !== undefined ? topP : 'default'
      }
    });
  } catch (error) {
    console.error('Erreur lors du test des paramètres:', error.message);
    res.status(500).json({ 
      status: 'ERROR', 
      message: `Erreur lors du test des paramètres: ${error.message}` 
    });
  }
}; 