// Ce module simule une base de données pour les événements écologiques
// Dans une application réelle, vous utiliseriez un service comme MongoDB, Firebase ou Supabase

// Fonction utilitaire pour obtenir la date du prochain jour de la semaine spécifié
function getNextDayOfWeek(dayOfWeek) {
  const today = new Date();
  const result = new Date(today);
  result.setDate(today.getDate() + (dayOfWeek + 7 - today.getDay()) % 7);
  
  // Si la date est aujourd'hui, on l'avance d'une semaine
  if (result.getDate() === today.getDate()) {
    result.setDate(result.getDate() + 7);
  }
  
  return result;
}

// Formatage de date en français
function formatDateFR(date) {
  const options = { weekday: 'long', day: 'numeric', month: 'long' };
  // On force la locale en français
  return date.toLocaleDateString('fr-FR', options);
}

// Base de données fictive d'événements écologiques
const ecoEvents = {
  "Paris": [
    {
      title: "Atelier de réparation Repair Café",
      location: "Ground Control (12e arr.)",
      date: getNextDayOfWeek(6), // Samedi
      description: "Apportez vos objets cassés et apprenez à les réparer avec l'aide de bénévoles experts."
    },
    {
      title: "Balade urbaine 'Biodiversité en ville'",
      location: "Parc de Belleville (20e arr.)",
      date: getNextDayOfWeek(0), // Dimanche
      description: "Découvrez la faune et la flore cachées dans nos parcs urbains."
    },
    {
      title: "Conférence 'Agriculture urbaine'",
      location: "La REcyclerie (18e arr.)",
      date: getNextDayOfWeek(2), // Mardi
      description: "Explorez le potentiel de l'agriculture urbaine pour une ville plus résiliente."
    },
    {
      title: "Festival Zéro Déchet",
      location: "Halle des Blancs Manteaux (4e arr.)",
      date: getNextDayOfWeek(6), // Samedi prochain
      description: "Ateliers, conférences et exposants autour du mode de vie zéro déchet."
    }
  ],
  "Lyon": [
    {
      title: "Atelier compostage",
      location: "Jardin partagé des Pentes (1er arr.)",
      date: getNextDayOfWeek(6), // Samedi
      description: "Initiation au compostage urbain et distribution de composteurs individuels."
    },
    {
      title: "Projection-débat 'Demain'",
      location: "MJC Jean Macé (7e arr.)",
      date: getNextDayOfWeek(3), // Mercredi
      description: "Projection du documentaire 'Demain' suivie d'un débat sur les initiatives locales."
    },
    {
      title: "Marché des producteurs locaux",
      location: "Place Carnot (2e arr.)",
      date: getNextDayOfWeek(6), // Samedi prochain
      description: "Rencontrez les producteurs locaux et achetez des produits de saison en circuit court."
    }
  ],
  "Marseille": [
    {
      title: "Nettoyage des plages",
      location: "Plage du Prado",
      date: getNextDayOfWeek(6), // Samedi
      description: "Action collective de nettoyage des plages pour lutter contre la pollution marine."
    },
    {
      title: "Conférence 'Méditerranée en danger'",
      location: "MuCEM",
      date: getNextDayOfWeek(4), // Jeudi
      description: "État des lieux de la biodiversité méditerranéenne et solutions de préservation."
    }
  ]
};

// Fonction pour obtenir les événements d'une ville
export function getEventsForCity(city) {
  const defaultCity = "Paris";
  const cityEvents = ecoEvents[city] || ecoEvents[defaultCity];
  
  if (!cityEvents) {
    return [];
  }
  
  return cityEvents.map(event => ({
    ...event,
    dateFormatted: formatDateFR(event.date)
  }));
}

// Fonction pour formater les événements en texte pour Dialogflow
export function formatEventsText(city) {
  const events = getEventsForCity(city);
  
  if (events.length === 0) {
    return `Je n'ai pas trouvé d'événements écologiques spécifiques pour ${city}. Je vous recommande de consulter le site de votre mairie ou les réseaux sociaux des associations environnementales locales.`;
  }
  
  let result = `Voici les prochains événements écologiques à ${city} :\n`;
  
  events.forEach(event => {
    result += `• ${event.dateFormatted}: ${event.title} à ${event.location}\n`;
  });
  
  return result;
} 