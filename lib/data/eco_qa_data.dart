import '../models/qa_model.dart';

List<QAModel> getInitialEcoQA() {
  return [
    // Climat et réchauffement climatique
    QAModel(
      question: "Qu'est-ce que le réchauffement climatique ?",
      answer: "Le réchauffement climatique est l'augmentation de la température moyenne de la Terre causée par l'accumulation de gaz à effet de serre dans l'atmosphère.",
      keywords: ["réchauffement", "climat", "température", "effet de serre"],
    ),
    QAModel(
      question: "Quels sont les principaux gaz à effet de serre ?",
      answer: "Les principaux gaz à effet de serre sont : le dioxyde de carbone (CO2), le méthane (CH4), le protoxyde d'azote (N2O) et les gaz fluorés. Le CO2 est le plus abondant et contribue le plus au réchauffement climatique.",
      keywords: ["gaz", "effet de serre", "CO2", "méthane", "pollution"],
    ),
    QAModel(
      question: "Quelles sont les conséquences du réchauffement climatique ?",
      answer: "Les conséquences incluent : la fonte des glaces, l'élévation du niveau des mers, l'augmentation des événements météorologiques extrêmes, la modification des écosystèmes, et l'impact sur l'agriculture et la santé humaine.",
      keywords: ["conséquences", "climat", "impact", "environnement"],
    ),
    QAModel(
      question: "Comment réduire son empreinte carbone ?",
      answer: "Vous pouvez réduire votre empreinte carbone en : 1) Utilisant les transports en commun, 2) Mangeant local et de saison, 3) Réduisant votre consommation d'énergie, 4) Recyclant vos déchets.",
      keywords: ["empreinte carbone", "écologie", "consommation", "énergie"],
    ),
    QAModel(
      question: "Qu'est-ce que l'accord de Paris ?",
      answer: "L'accord de Paris est un traité international sur le climat adopté en 2015, visant à limiter le réchauffement climatique à 2°C, idéalement 1.5°C, par rapport à l'ère préindustrielle.",
      keywords: ["accord", "Paris", "climat", "international"],
    ),

    // Énergie
    QAModel(
      question: "Qu'est-ce que l'énergie renouvelable ?",
      answer: "Les énergies renouvelables sont des sources d'énergie qui se renouvellent naturellement comme le solaire, l'éolien, l'hydraulique, la géothermie et la biomasse.",
      keywords: ["énergie", "renouvelable", "solaire", "éolien", "hydraulique"],
    ),
    QAModel(
      question: "Comment fonctionne l'énergie solaire ?",
      answer: "L'énergie solaire est produite en convertissant la lumière du soleil en électricité grâce à des panneaux photovoltaïques ou en chaleur grâce à des capteurs solaires thermiques.",
      keywords: ["solaire", "énergie", "photovoltaïque", "renouvelable"],
    ),
    QAModel(
      question: "Quels sont les avantages de l'énergie éolienne ?",
      answer: "L'énergie éolienne est renouvelable, ne produit pas de CO2, est inépuisable et peut être installée sur terre ou en mer. Elle contribue à l'indépendance énergétique.",
      keywords: ["éolien", "énergie", "renouvelable", "avantages"],
    ),
    QAModel(
      question: "Comment économiser l'énergie à la maison ?",
      answer: "Pour économiser l'énergie : 1) Isolez votre logement, 2) Utilisez des appareils économes, 3) Éteignez les appareils en veille, 4) Privilégiez les énergies renouvelables, 5) Utilisez un thermostat programmable.",
      keywords: ["énergie", "économie", "maison", "consommation"],
    ),
    QAModel(
      question: "Qu'est-ce que l'autoconsommation énergétique ?",
      answer: "L'autoconsommation énergétique consiste à produire et consommer sa propre électricité, généralement via des panneaux solaires, réduisant ainsi sa dépendance au réseau électrique.",
      keywords: ["énergie", "autoconsommation", "solaire", "indépendance"],
    ),

    // Déchets et recyclage
    QAModel(
      question: "Comment recycler correctement ?",
      answer: "Pour recycler correctement : 1) Séparez vos déchets (plastique, verre, papier, métal), 2) Nettoyez les emballages, 3) Respectez les consignes de tri de votre commune, 4) Utilisez les points de collecte appropriés.",
      keywords: ["recyclage", "déchets", "tri", "emballages"],
    ),
    QAModel(
      question: "Qu'est-ce que le compostage ?",
      answer: "Le compostage est un processus naturel de décomposition des déchets organiques qui produit un engrais naturel riche en nutriments pour les plantes.",
      keywords: ["compost", "déchets", "organique", "jardin"],
    ),
    QAModel(
      question: "Comment réduire ses déchets ?",
      answer: "Pour réduire ses déchets : 1) Achetez en vrac, 2) Utilisez des produits réutilisables, 3) Compostez vos déchets organiques, 4) Évitez le suremballage, 5) Réparez plutôt que jeter.",
      keywords: ["déchets", "réduction", "zéro déchet", "consommation"],
    ),
    QAModel(
      question: "Qu'est-ce que le zéro déchet ?",
      answer: "Le zéro déchet est un mode de vie qui vise à réduire au maximum sa production de déchets en suivant les 5R : Refuser, Réduire, Réutiliser, Recycler, Composter.",
      keywords: ["zéro déchet", "consommation", "déchets", "écologie"],
    ),
    QAModel(
      question: "Comment gérer les déchets électroniques ?",
      answer: "Les déchets électroniques doivent être : 1) Apportés en déchetterie, 2) Donnés à des associations de réparation, 3) Recyclés via des programmes de reprise des fabricants, 4) Jamais jetés avec les ordures ménagères.",
      keywords: ["déchets", "électronique", "recyclage", "DEEE"],
    ),

    // Eau
    QAModel(
      question: "Comment économiser l'eau ?",
      answer: "Pour économiser l'eau : 1) Prenez des douches courtes, 2) Fermez le robinet pendant le brossage des dents, 3) Utilisez des appareils économes en eau, 4) Récupérez l'eau de pluie, 5) Réparez les fuites.",
      keywords: ["eau", "économie", "consommation", "ressources"],
    ),
    QAModel(
      question: "Qu'est-ce que l'eau virtuelle ?",
      answer: "L'eau virtuelle est la quantité d'eau nécessaire pour produire un bien ou un service. Par exemple, il faut environ 15 000 litres d'eau pour produire 1 kg de bœuf.",
      keywords: ["eau", "virtuelle", "consommation", "ressources"],
    ),
    QAModel(
      question: "Comment protéger les ressources en eau ?",
      answer: "Pour protéger l'eau : 1) Évitez les produits polluants, 2) Limitez l'utilisation de pesticides, 3) Ne jetez rien dans les égouts, 4) Utilisez des produits d'entretien écologiques, 5) Économisez l'eau.",
      keywords: ["eau", "protection", "ressources", "pollution"],
    ),
    QAModel(
      question: "Qu'est-ce que l'eau potable ?",
      answer: "L'eau potable est une eau qui peut être bue sans risque pour la santé. Elle doit répondre à des critères stricts de qualité et être traitée pour éliminer les contaminants.",
      keywords: ["eau", "potable", "santé", "qualité"],
    ),
    QAModel(
      question: "Comment fonctionne le cycle de l'eau ?",
      answer: "Le cycle de l'eau comprend : 1) L'évaporation, 2) La condensation, 3) Les précipitations, 4) L'infiltration, 5) Le ruissellement. C'est un processus naturel continu qui maintient l'eau en mouvement sur Terre.",
      keywords: ["eau", "cycle", "nature", "écologie"],
    ),

    // Biodiversité
    QAModel(
      question: "Qu'est-ce que la biodiversité ?",
      answer: "La biodiversité est la variété des formes de vie sur Terre, incluant les espèces animales, végétales et les écosystèmes. Elle est essentielle pour l'équilibre de notre planète.",
      keywords: ["biodiversité", "espèces", "écosystème", "nature"],
    ),
    QAModel(
      question: "Comment protéger la biodiversité ?",
      answer: "Pour protéger la biodiversité : 1) Préservez les habitats naturels, 2) Évitez les pesticides, 3) Plantez des espèces locales, 4) Réduisez votre empreinte écologique, 5) Soutenez les initiatives de conservation.",
      keywords: ["biodiversité", "protection", "nature", "écologie"],
    ),
    QAModel(
      question: "Qu'est-ce qu'une espèce menacée ?",
      answer: "Une espèce menacée est une espèce animale ou végétale dont la survie est en danger à cause de la destruction de son habitat, de la pollution, du changement climatique ou de la surexploitation.",
      keywords: ["espèce", "menacée", "protection", "biodiversité"],
    ),
    QAModel(
      question: "Comment créer un jardin écologique ?",
      answer: "Pour un jardin écologique : 1) Utilisez des plantes locales, 2) Évitez les pesticides, 3) Créez des zones sauvages, 4) Installez des hôtels à insectes, 5) Utilisez le compost, 6) Récupérez l'eau de pluie.",
      keywords: ["jardin", "écologique", "nature", "biodiversité"],
    ),
    QAModel(
      question: "Qu'est-ce que la permaculture ?",
      answer: "La permaculture est une méthode de culture qui imite les écosystèmes naturels pour créer des systèmes agricoles durables et autosuffisants, en harmonie avec la nature.",
      keywords: ["permaculture", "agriculture", "durable", "nature"],
    ),

    // Agriculture et alimentation
    QAModel(
      question: "Qu'est-ce que l'agriculture biologique ?",
      answer: "L'agriculture biologique est une méthode de production qui exclut l'utilisation de produits chimiques de synthèse, d'OGM et privilégie les pratiques respectueuses de l'environnement et du bien-être animal.",
      keywords: ["agriculture", "bio", "écologique", "production"],
    ),
    QAModel(
      question: "Comment manger de manière écologique ?",
      answer: "Pour manger écologique : 1) Privilégiez les produits locaux et de saison, 2) Réduisez la viande, 3) Évitez le gaspillage, 4) Choisissez des produits bio, 5) Limitez les emballages.",
      keywords: ["alimentation", "écologique", "consommation", "bio"],
    ),
    QAModel(
      question: "Qu'est-ce que l'agriculture durable ?",
      answer: "L'agriculture durable vise à produire des aliments tout en préservant l'environnement, en maintenant la fertilité des sols et en respectant les cycles naturels.",
      keywords: ["agriculture", "durable", "environnement", "production"],
    ),
    QAModel(
      question: "Comment réduire le gaspillage alimentaire ?",
      answer: "Pour réduire le gaspillage : 1) Planifiez vos repas, 2) Faites une liste de courses, 3) Vérifiez les dates de péremption, 4) Cuisinez les restes, 5) Congelez les surplus.",
      keywords: ["gaspillage", "alimentation", "consommation", "déchets"],
    ),
    QAModel(
      question: "Qu'est-ce que la pêche durable ?",
      answer: "La pêche durable respecte les écosystèmes marins, évite la surpêche et utilise des méthodes de pêche sélectives pour préserver les stocks de poissons.",
      keywords: ["pêche", "durable", "océan", "ressources"],
    ),

    // Transport et mobilité
    QAModel(
      question: "Qu'est-ce que la mobilité douce ?",
      answer: "La mobilité douce regroupe les modes de transport non motorisés comme la marche, le vélo, la trottinette, qui sont écologiques et bons pour la santé.",
      keywords: ["mobilité", "transport", "écologique", "santé"],
    ),
    QAModel(
      question: "Comment réduire l'impact des transports ?",
      answer: "Pour réduire l'impact : 1) Utilisez les transports en commun, 2) Privilégiez le covoiturage, 3) Marchez ou pédalez pour les courts trajets, 4) Optimisez vos déplacements, 5) Choisissez des véhicules économes.",
      keywords: ["transport", "impact", "écologie", "déplacement"],
    ),
    QAModel(
      question: "Quels sont les avantages des véhicules électriques ?",
      answer: "Les véhicules électriques : 1) Ne produisent pas d'émissions directes, 2) Sont plus silencieux, 3) Ont un coût d'utilisation réduit, 4) Contribuent à l'amélioration de la qualité de l'air.",
      keywords: ["véhicule", "électrique", "transport", "écologie"],
    ),
    QAModel(
      question: "Comment optimiser ses déplacements ?",
      answer: "Pour optimiser : 1) Regroupez vos trajets, 2) Utilisez les applications de covoiturage, 3) Privilégiez les horaires creux, 4) Planifiez votre itinéraire, 5) Utilisez les modes de transport adaptés.",
      keywords: ["déplacement", "optimisation", "transport", "efficacité"],
    ),
    QAModel(
      question: "Qu'est-ce que l'écomobilité ?",
      answer: "L'écomobilité est une approche des déplacements qui privilégie les modes de transport respectueux de l'environnement et la réduction des besoins en déplacement.",
      keywords: ["écomobilité", "transport", "écologie", "déplacement"],
    ),

    // Habitat et construction
    QAModel(
      question: "Qu'est-ce qu'une maison écologique ?",
      answer: "Une maison écologique est conçue pour minimiser son impact environnemental grâce à : 1) Une bonne isolation, 2) Des matériaux naturels, 3) Des énergies renouvelables, 4) Une gestion optimale de l'eau.",
      keywords: ["maison", "écologique", "construction", "habitat"],
    ),
    QAModel(
      question: "Comment isoler sa maison efficacement ?",
      answer: "Pour une bonne isolation : 1) Isolez les murs et la toiture, 2) Choisissez des matériaux performants, 3) Traitez les ponts thermiques, 4) Installez des fenêtres double vitrage, 5) Utilisez des isolants naturels.",
      keywords: ["isolation", "maison", "énergie", "économie"],
    ),
    QAModel(
      question: "Qu'est-ce que la rénovation énergétique ?",
      answer: "La rénovation énergétique vise à améliorer la performance énergétique d'un bâtiment par l'isolation, le remplacement des équipements et l'utilisation d'énergies renouvelables.",
      keywords: ["rénovation", "énergie", "maison", "économie"],
    ),
    QAModel(
      question: "Comment chauffer sa maison écologiquement ?",
      answer: "Pour un chauffage écologique : 1) Isolez bien votre maison, 2) Utilisez une pompe à chaleur, 3) Installez un poêle à bois, 4) Optez pour le solaire thermique, 5) Réglez correctement votre thermostat.",
      keywords: ["chauffage", "écologique", "maison", "énergie"],
    ),
    QAModel(
      question: "Qu'est-ce qu'une maison passive ?",
      answer: "Une maison passive est conçue pour consommer très peu d'énergie grâce à une excellente isolation, une étanchéité à l'air optimale et l'utilisation passive de l'énergie solaire.",
      keywords: ["maison", "passive", "énergie", "construction"],
    ),

    // Consommation responsable
    QAModel(
      question: "Qu'est-ce que la consommation responsable ?",
      answer: "La consommation responsable consiste à faire des choix d'achat qui respectent l'environnement et les droits sociaux, en privilégiant la qualité, la durabilité et l'éthique.",
      keywords: ["consommation", "responsable", "éthique", "durable"],
    ),
    QAModel(
      question: "Comment acheter de manière éthique ?",
      answer: "Pour acheter éthique : 1) Privilégiez le local, 2) Vérifiez les labels, 3) Choisissez des produits durables, 4) Évitez les marques controversées, 5) Soutenez les initiatives éthiques.",
      keywords: ["achat", "éthique", "consommation", "responsable"],
    ),
    QAModel(
      question: "Qu'est-ce que l'obsolescence programmée ?",
      answer: "L'obsolescence programmée est la conception délibérée d'un produit pour qu'il devienne obsolète ou inutilisable après une période déterminée, encourageant ainsi l'achat de nouveaux produits.",
      keywords: ["obsolescence", "consommation", "produit", "durabilité"],
    ),
    QAModel(
      question: "Comment entretenir ses vêtements durablement ?",
      answer: "Pour entretenir durablement : 1) Lavez à basse température, 2) Utilisez des produits écologiques, 3) Réparez plutôt que jeter, 4) Achetez des vêtements de qualité, 5) Donnez une seconde vie.",
      keywords: ["vêtement", "entretien", "durable", "consommation"],
    ),
    QAModel(
      question: "Qu'est-ce que la mode éthique ?",
      answer: "La mode éthique privilégie des conditions de production respectueuses des travailleurs et de l'environnement, avec des matériaux durables et des processus de fabrication responsables.",
      keywords: ["mode", "éthique", "vêtement", "consommation"],
    ),

    // Pollution
    QAModel(
      question: "Qu'est-ce que la pollution de l'air ?",
      answer: "La pollution de l'air est la présence de substances nocives dans l'atmosphère, provenant principalement des transports, de l'industrie et du chauffage, affectant la santé et l'environnement.",
      keywords: ["pollution", "air", "santé", "environnement"],
    ),
    QAModel(
      question: "Comment réduire la pollution plastique ?",
      answer: "Pour réduire la pollution plastique : 1) Évitez les plastiques à usage unique, 2) Utilisez des alternatives réutilisables, 3) Recyclez correctement, 4) Participez au nettoyage, 5) Sensibilisez votre entourage.",
      keywords: ["pollution", "plastique", "déchets", "environnement"],
    ),
    QAModel(
      question: "Qu'est-ce que la pollution lumineuse ?",
      answer: "La pollution lumineuse est l'excès de lumière artificielle qui perturbe les écosystèmes nocturnes, affecte la biodiversité et empêche l'observation des étoiles.",
      keywords: ["pollution", "lumière", "nuit", "biodiversité"],
    ),
    QAModel(
      question: "Comment réduire la pollution sonore ?",
      answer: "Pour réduire le bruit : 1) Isolez acoustiquement votre logement, 2) Utilisez des transports silencieux, 3) Respectez les horaires de calme, 4) Évitez les équipements bruyants, 5) Sensibilisez votre entourage.",
      keywords: ["pollution", "sonore", "bruit", "santé"],
    ),
    QAModel(
      question: "Qu'est-ce que la pollution des sols ?",
      answer: "La pollution des sols est la contamination de la terre par des substances chimiques, des déchets ou des polluants qui affectent sa qualité et peuvent contaminer les cultures et les nappes phréatiques.",
      keywords: ["pollution", "sol", "terre", "environnement"],
    ),

    // Éducation et sensibilisation
    QAModel(
      question: "Comment sensibiliser à l'écologie ?",
      answer: "Pour sensibiliser : 1) Informez-vous et partagez vos connaissances, 2) Montrez l'exemple, 3) Organisez des événements, 4) Utilisez les réseaux sociaux, 5) Impliquez votre entourage dans des actions concrètes.",
      keywords: ["sensibilisation", "écologie", "éducation", "partage"],
    ),
    QAModel(
      question: "Qu'est-ce que l'éducation à l'environnement ?",
      answer: "L'éducation à l'environnement vise à développer la conscience écologique et les compétences nécessaires pour comprendre et agir en faveur de l'environnement.",
      keywords: ["éducation", "environnement", "apprentissage", "écologie"],
    ),
    QAModel(
      question: "Comment impliquer les enfants dans l'écologie ?",
      answer: "Pour impliquer les enfants : 1) Organisez des activités nature, 2) Expliquez simplement les enjeux, 3) Créez un jardin pédagogique, 4) Faites des expériences pratiques, 5) Montrez l'exemple au quotidien.",
      keywords: ["éducation", "enfant", "écologie", "apprentissage"],
    ),
    QAModel(
      question: "Qu'est-ce que la communication environnementale ?",
      answer: "La communication environnementale vise à informer et sensibiliser le public sur les enjeux écologiques et les solutions possibles, en utilisant des messages clairs et accessibles.",
      keywords: ["communication", "environnement", "information", "sensibilisation"],
    ),
    QAModel(
      question: "Comment organiser un événement écologique ?",
      answer: "Pour un événement écologique : 1) Choisissez un lieu accessible, 2) Réduisez les déchets, 3) Utilisez des énergies renouvelables, 4) Privilégiez le local, 5) Sensibilisez les participants.",
      keywords: ["événement", "écologique", "organisation", "durable"],
    ),

    // Technologies vertes
    QAModel(
      question: "Qu'est-ce que les technologies vertes ?",
      answer: "Les technologies vertes sont des innovations qui visent à réduire l'impact environnemental des activités humaines, comme les énergies renouvelables, le stockage d'énergie ou les matériaux écologiques.",
      keywords: ["technologie", "verte", "innovation", "environnement"],
    ),
    QAModel(
      question: "Comment fonctionne le stockage d'énergie ?",
      answer: "Le stockage d'énergie permet de conserver l'électricité produite pour une utilisation ultérieure, notamment via des batteries, des systèmes de pompage-turbinage ou l'hydrogène.",
      keywords: ["énergie", "stockage", "batterie", "renouvelable"],
    ),
    QAModel(
      question: "Qu'est-ce que la domotique écologique ?",
      answer: "La domotique écologique utilise des technologies intelligentes pour optimiser la consommation d'énergie et améliorer le confort tout en réduisant l'impact environnemental.",
      keywords: ["domotique", "écologique", "maison", "énergie"],
    ),
    QAModel(
      question: "Comment utiliser les applications écologiques ?",
      answer: "Les applications écologiques peuvent vous aider à : 1) Suivre votre consommation, 2) Trouver des alternatives durables, 3) Participer à des actions collectives, 4) Apprendre l'écologie, 5) Connecter avec la communauté.",
      keywords: ["application", "écologique", "technologie", "consommation"],
    ),
    QAModel(
      question: "Qu'est-ce que l'Internet des objets écologique ?",
      answer: "L'Internet des objets écologique utilise des capteurs et des objets connectés pour optimiser la consommation d'énergie, réduire les déchets et améliorer la gestion des ressources.",
      keywords: ["IoT", "écologique", "technologie", "connecté"],
    ),

    // Santé et environnement
    QAModel(
      question: "Comment l'environnement affecte-t-il la santé ?",
      answer: "L'environnement affecte la santé par : 1) La qualité de l'air, 2) L'eau potable, 3) Les produits chimiques, 4) Le bruit, 5) Les changements climatiques. Une bonne santé dépend d'un environnement sain.",
      keywords: ["santé", "environnement", "impact", "qualité"],
    ),
    QAModel(
      question: "Qu'est-ce que la santé environnementale ?",
      answer: "La santé environnementale étudie les relations entre l'environnement et la santé humaine, visant à prévenir les risques liés aux facteurs environnementaux.",
      keywords: ["santé", "environnement", "prévention", "risque"],
    ),
    QAModel(
      question: "Comment protéger sa santé face à la pollution ?",
      answer: "Pour se protéger : 1) Surveillez la qualité de l'air, 2) Utilisez des purificateurs d'air, 3) Évitez les heures de pointe, 4) Mangez des aliments détoxifiants, 5) Pratiquez une activité physique dans des zones saines.",
      keywords: ["santé", "pollution", "protection", "prévention"],
    ),
    QAModel(
      question: "Qu'est-ce que le syndrome du bâtiment malsain ?",
      answer: "Le syndrome du bâtiment malsain regroupe les problèmes de santé liés à la qualité de l'air intérieur, causés par des matériaux, des produits chimiques ou une mauvaise ventilation.",
      keywords: ["santé", "bâtiment", "air", "qualité"],
    ),
    QAModel(
      question: "Comment créer un environnement sain ?",
      answer: "Pour un environnement sain : 1) Aérez régulièrement, 2) Utilisez des produits naturels, 3) Évitez les polluants, 4) Maintenez une bonne hygiène, 5) Privilégiez les matériaux sains.",
      keywords: ["environnement", "sain", "santé", "qualité"],
    ),

    // Économie verte
    QAModel(
      question: "Qu'est-ce que l'économie verte ?",
      answer: "L'économie verte vise à améliorer le bien-être humain tout en réduisant les risques environnementaux, en favorisant les activités économiques durables et respectueuses de l'environnement.",
      keywords: ["économie", "verte", "durable", "environnement"],
    ),
    QAModel(
      question: "Comment créer une entreprise écologique ?",
      answer: "Pour une entreprise écologique : 1) Choisissez un modèle durable, 2) Réduisez votre impact, 3) Utilisez des ressources renouvelables, 4) Impliquez vos employés, 5) Communiquez transparentement.",
      keywords: ["entreprise", "écologique", "économie", "durable"],
    ),
    QAModel(
      question: "Qu'est-ce que la finance verte ?",
      answer: "La finance verte oriente les investissements vers des projets respectueux de l'environnement, comme les énergies renouvelables, l'efficacité énergétique ou la protection de la biodiversité.",
      keywords: ["finance", "verte", "investissement", "environnement"],
    ),
    QAModel(
      question: "Comment investir de manière responsable ?",
      answer: "Pour investir responsable : 1) Choisissez des fonds verts, 2) Évitez les secteurs polluants, 3) Privilégiez les entreprises durables, 4) Diversifiez vos investissements, 5) Suivez les labels éthiques.",
      keywords: ["investissement", "responsable", "finance", "éthique"],
    ),
    QAModel(
      question: "Qu'est-ce que l'économie circulaire ?",
      answer: "L'économie circulaire est un modèle économique qui vise à réduire la consommation de ressources et la production de déchets en réutilisant, réparant et recyclant les produits.",
      keywords: ["économie", "circulaire", "recyclage", "durable"],
    ),

    // Politiques environnementales
    QAModel(
      question: "Qu'est-ce que la transition écologique ?",
      answer: "La transition écologique est le passage d'un modèle économique basé sur les énergies fossiles vers un modèle durable utilisant les énergies renouvelables et respectant l'environnement.",
      keywords: ["transition", "écologique", "économie", "durable"],
    ),
    QAModel(
      question: "Comment les politiques peuvent-elles protéger l'environnement ?",
      answer: "Les politiques peuvent protéger l'environnement par : 1) Des lois contraignantes, 2) Des incitations financières, 3) Des normes environnementales, 4) Des programmes d'éducation, 5) Des investissements verts.",
      keywords: ["politique", "environnement", "protection", "loi"],
    ),
    QAModel(
      question: "Qu'est-ce que le développement durable ?",
      answer: "Le développement durable vise à répondre aux besoins actuels sans compromettre les besoins des générations futures, en conciliant croissance économique, protection de l'environnement et équité sociale.",
      keywords: ["développement", "durable", "environnement", "social"],
    ),
    QAModel(
      question: "Comment participer à la démocratie environnementale ?",
      answer: "Pour participer : 1) Informez-vous, 2) Votez pour des candidats écologistes, 3) Participez aux consultations, 4) Rejoignez des associations, 5) Exprimez vos préoccupations.",
      keywords: ["démocratie", "environnement", "participation", "citoyen"],
    ),
    QAModel(
      question: "Qu'est-ce que la justice climatique ?",
      answer: "La justice climatique reconnaît que les impacts du changement climatique affectent différemment les populations et vise à assurer une transition équitable vers une société bas carbone.",
      keywords: ["justice", "climat", "équité", "transition"],
    ),
  ];
} 