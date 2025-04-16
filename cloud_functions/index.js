const functions = require('@google-cloud/functions-framework');

// Point d'entrée pour la fonction Cloud
functions.http('ecoWebhook', (req, res) => {
  console.log('Requête webhook reçue:', JSON.stringify(req.body));
  
  try {
    // Extraction des informations importantes de la requête Dialogflow
    const intent = req.body.queryResult.intent.displayName;
    const parameters = req.body.queryResult.parameters;
    const session = req.body.session;
    
    console.log(`Intent détecté: ${intent}`);
    console.log(`Paramètres: ${JSON.stringify(parameters)}`);
    
    // Traiter la requête en fonction de l'intent détecté
    let fulfillmentText;
    
    switch (intent) {
      case 'calcul_empreinte_carbone':
        fulfillmentText = handleCarbonFootprintCalculation(parameters);
        break;
        
      case 'eco_conseil_personnalise':
        fulfillmentText = generateEcoAdvice(parameters);
        break;
        
      case 'info_recyclage':
        fulfillmentText = getRecyclingInfo(parameters);
        break;
        
      case 'evenements_eco':
        fulfillmentText = getEcoEvents(parameters);
        break;
        
      case 'alternative_eco':
        fulfillmentText = getSustainableAlternative(parameters);
        break;
        
      default:
        fulfillmentText = "Je ne suis pas en mesure de traiter cette demande spécifique.";
        break;
    }
    
    // Envoyer la réponse à Dialogflow
    res.json({
      fulfillmentText: fulfillmentText,
      fulfillmentMessages: [{
        text: {
          text: [fulfillmentText]
        }
      }]
    });
    
  } catch (error) {
    console.error('Erreur lors du traitement de la requête:', error);
    
    res.json({
      fulfillmentText: "Désolé, une erreur s'est produite lors du traitement de votre demande."
    });
  }
});

// Fonctions de traitement des intents

function handleCarbonFootprintCalculation(parameters) {
  const activity = parameters.activity || 'transport';
  const duration = parameters.duration || 0;
  
  let result = '';
  let carbonFootprint = 0;
  
  if (activity === 'transport') {
    const transportType = parameters.transport_type || 'voiture';
    
    // Calcul simplifié de l'empreinte
    switch (transportType) {
      case 'voiture':
        carbonFootprint = 120 * (duration / 60); // g CO2/km
        break;
      case 'bus':
        carbonFootprint = 68 * (duration / 60);
        break;
      case 'train':
        carbonFootprint = 14 * (duration / 60);
        break;
      case 'avion':
        carbonFootprint = 285 * (duration / 60);
        break;
      default:
        carbonFootprint = 0;
    }
    
    result = `Pour votre trajet en ${transportType} de ${Math.round(duration)} minutes, `
        + `l'empreinte carbone estimée est de ${carbonFootprint.toFixed(2)} kg de CO2. `;
    
    // Ajouter des conseils
    if (transportType === 'voiture') {
      result += "Saviez-vous qu'en prenant le train pour ce même trajet, "
          + "vous réduiriez votre empreinte carbone de près de 90% ?";
    }
  } else if (activity === 'alimentation') {
    const foodType = parameters.food_type || 'viande';
    
    switch (foodType) {
      case 'viande':
        carbonFootprint = 13.3;
        break;
      case 'poisson':
        carbonFootprint = 3.9;
        break;
      case 'vegetarien':
        carbonFootprint = 1.7;
        break;
      case 'vegan':
        carbonFootprint = 1.1;
        break;
      default:
        carbonFootprint = 0;
    }
    
    result = `Un repas à base de ${foodType} génère environ ${carbonFootprint.toFixed(1)} kg de CO2. `
        + `Sur une semaine, cela représente ${(carbonFootprint * 7).toFixed(1)} kg de CO2.`;
  }
  
  return result;
}

function generateEcoAdvice(parameters) {
  const domain = parameters.eco_domain || 'général';
  const level = parameters.expertise_level || 'débutant';
  
  switch (domain) {
    case 'énergie':
      if (level === 'débutant') {
        return "Pour réduire votre consommation d'énergie, commencez par remplacer vos ampoules par des LED, "
            + "qui consomment jusqu'à 90% d'électricité en moins que les ampoules incandescentes et durent 15 fois plus longtemps. "
            + "Éteignez également les appareils en veille, qui peuvent représenter jusqu'à 10% de votre facture d'électricité.";
      } else {
        return "Pour optimiser votre consommation énergétique, envisagez d'installer des panneaux solaires "
            + "qui pourraient couvrir 30 à 50% de vos besoins. Complétez avec un système de domotique pour gérer intelligemment "
            + "le chauffage et l'éclairage, réduisant ainsi votre consommation totale de 15 à 30%. "
            + "Vous pourriez également rejoindre une coopérative d'énergie citoyenne locale.";
      }
      
    // Ajoutez d'autres cas comme dans le fichier webhook_functions.dart
      
    default:
      return "Pour commencer votre démarche écologique, concentrez-vous sur un aspect qui vous tient à cœur : "
          + "alimentation, transport, énergie, déchets... Fixez-vous des objectifs réalistes et progressifs. "
          + "Souvenez-vous que chaque petit geste compte et que l'impact collectif de nos actions individuelles est significatif.";
  }
}

function getRecyclingInfo(parameters) {
  const material = parameters.material || 'plastique';
  
  switch (material) {
    case 'plastique':
      return "Le plastique se recycle différemment selon son type. Recherchez le numéro dans le triangle ♻️ sous l'objet : "
          + "Les types 1 (PET) et 2 (HDPE) sont les plus facilement recyclables et vont dans la poubelle jaune. "
          + "Les types 3 (PVC) et 6 (PS) sont rarement recyclés. "
          + "Important : les bouteilles doivent être vidées mais pas écrasées, et les bouchons vissés dessus.";
    
    // Ajoutez d'autres cas comme dans le fichier webhook_functions.dart
      
    default:
      return "Pour savoir comment recycler correctement ce matériau, consultez le guide local de tri de votre commune "
          + "ou utilisez l'application mobile Guide du Tri de CITEO qui vous donnera les consignes spécifiques pour votre localité.";
  }
}

function getEcoEvents(parameters) {
  const location = parameters.location || 'Paris';
  
  // Dans une vraie implémentation, vous feriez une requête à une base de données
  // Ici, nous retournons des événements fictifs
  
  if (location.includes('Paris')) {
    return "Voici les prochains événements écologiques à Paris :\n"
        + "• Ce samedi: Atelier de réparation Repair Café au Ground Control (12e arr.)\n"
        + "• Ce dimanche: Balade urbaine 'Biodiversité en ville' au Parc de Belleville (20e arr.)\n"
        + "• Mardi prochain: Conférence 'Agriculture urbaine' à La REcyclerie (18e arr.)\n"
        + "• Le week-end prochain: Festival Zéro Déchet à la Halle des Blancs Manteaux (4e arr.)";
  } else {
    return "Je n'ai pas trouvé d'événements écologiques spécifiques pour " + location + ". "
        + "Je vous recommande de consulter le site de votre mairie ou les réseaux sociaux des associations "
        + "environnementales locales.";
  }
}

function getSustainableAlternative(parameters) {
  const product = parameters.product || 'bouteille plastique';
  
  switch (product) {
    case 'bouteille plastique':
      return "Pour remplacer les bouteilles en plastique, optez pour une gourde réutilisable en inox. "
          + "Durable et sans BPA, elle conservera votre eau fraîche plus longtemps. "
          + "Une gourde de qualité coûte entre 15€ et 30€, mais s'amortit en quelques mois : "
          + "une famille de 4 personnes économise environ 800€ par an en arrêtant l'eau en bouteille.";
    
    // Ajoutez d'autres cas comme dans le fichier webhook_functions.dart
      
    default:
      return "Pour trouver une alternative écologique à ce produit, demandez conseil dans une boutique "
          + "zéro déchet près de chez vous. Ces commerces proposent généralement des solutions durables "
          + "et vous aideront à choisir le produit adapté à vos besoins.";
  }
} 