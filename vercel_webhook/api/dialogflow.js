// Webhook Vercel pour Dialogflow
// Endpoint: /api/dialogflow
import { formatEventsText } from './utils/database.js';

export default async function handler(req, res) {
  // Vercel utilise req.method pour déterminer le type de requête
  if (req.method !== 'POST') {
    return res.status(405).json({ error: 'Méthode non autorisée' });
  }

  try {
    // Extraction des informations de la requête Dialogflow
    const body = req.body;
    const intentName = body.queryResult.intent.displayName;
    const parameters = body.queryResult.parameters;
    const sessionId = body.session.split('/').pop();

    console.log(`Intent reçu: ${intentName}`);
    console.log(`Paramètres: ${JSON.stringify(parameters)}`);
    console.log(`Session ID: ${sessionId}`);

    // Traitement selon l'intent
    let responseText;
    
    switch (intentName) {
      case 'calcul_empreinte_carbone':
        responseText = handleCarbonFootprint(parameters);
        break;
        
      case 'eco_conseil_personnalise':
        responseText = getEcoAdvice(parameters);
        break;
        
      case 'info_recyclage':
        responseText = getRecyclingInfo(parameters);
        break;
        
      case 'evenements_eco':
        responseText = getEcoEvents(parameters);
        break;
        
      case 'alternative_eco':
        responseText = getSustainableAlternative(parameters);
        break;
        
      default:
        responseText = "Désolé, je n'ai pas encore de réponse spécifique pour cet intent.";
    }

    // Retourner la réponse au format attendu par Dialogflow
    return res.status(200).json({
      fulfillmentText: responseText,
      fulfillmentMessages: [
        {
          text: {
            text: [responseText]
          }
        }
      ]
    });
  } catch (error) {
    console.error('Erreur lors du traitement de la requête:', error);
    return res.status(500).json({
      fulfillmentText: "Désolé, une erreur s'est produite lors du traitement de votre demande."
    });
  }
}

// Fonctions de traitement des intents

function handleCarbonFootprint(parameters) {
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

function getEcoAdvice(parameters) {
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
      
    case 'déchets':
      if (level === 'débutant') {
        return "Pour réduire vos déchets, adoptez les 3R : Réduire, Réutiliser, Recycler. "
            + "Commencez par utiliser un sac réutilisable pour vos courses, évitez les produits à usage unique, "
            + "et assurez-vous de bien trier vos déchets recyclables. Ces gestes simples peuvent réduire vos déchets de 30%.";
      } else {
        return "Pour une démarche zéro déchet avancée, créez votre compost (même en appartement avec un lombricomposteur), "
            + "achetez en vrac avec vos propres contenants, fabriquez vos produits ménagers et d'hygiène. "
            + "Vous pouvez également pratiquer l'upcycling pour transformer vos déchets en objets utiles ou décoratifs. "
            + "Ces pratiques peuvent réduire vos déchets de plus de 80%.";
      }
      
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
      
    case 'verre':
      return "Le verre est recyclable à 100% et indéfiniment sans perdre ses propriétés ! "
          + "Déposez bouteilles, pots et bocaux en verre dans les conteneurs à verre, sans les bouchons ni couvercles. "
          + "Attention : la vaisselle, les miroirs et les ampoules ne sont pas recyclables avec le verre d'emballage "
          + "car ils ont une composition différente.";
      
    default:
      return "Pour savoir comment recycler correctement ce matériau, consultez le guide local de tri de votre commune "
          + "ou utilisez l'application mobile Guide du Tri de CITEO qui vous donnera les consignes spécifiques pour votre localité.";
  }
}

function getEcoEvents(parameters) {
  const location = parameters.location || 'Paris';
  
  // Utilisation du module de base de données pour obtenir les événements
  return formatEventsText(location);
}

function getSustainableAlternative(parameters) {
  const product = parameters.product || 'bouteille plastique';
  
  switch (product) {
    case 'bouteille plastique':
      return "Pour remplacer les bouteilles en plastique, optez pour une gourde réutilisable en inox. "
          + "Durable et sans BPA, elle conservera votre eau fraîche plus longtemps. "
          + "Une gourde de qualité coûte entre 15€ et 30€, mais s'amortit en quelques mois : "
          + "une famille de 4 personnes économise environ 800€ par an en arrêtant l'eau en bouteille.";
      
    case 'sac plastique':
      return "Pour remplacer les sacs plastiques, utilisez des sacs en tissu réutilisables. "
          + "Les modèles pliables tiennent facilement dans une poche ou un sac à main. "
          + "Pour vos fruits et légumes, privilégiez les sacs à vrac lavables en coton bio. "
          + "Un Français utilise en moyenne 80 sacs plastiques par an, alors que votre sac en tissu "
          + "peut durer plus de 10 ans !";
      
    default:
      return "Pour trouver une alternative écologique à ce produit, demandez conseil dans une boutique "
          + "zéro déchet près de chez vous. Ces commerces proposent généralement des solutions durables "
          + "et vous aideront à choisir le produit adapté à vos besoins.";
  }
} 