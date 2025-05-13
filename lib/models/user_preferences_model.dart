// Modèle pour stocker les préférences et intérêts de l'utilisateur
class UserPreferencesModel {
  // Préférences générales
  final bool isDarkMode; // Préférence de thème
  final String preferredLanguage; // Langue préférée
  final bool enableNotifications; // Activer les notifications
  
  // Intérêts écologiques spécifiques
  final List<String> ecoInterests; // Ex: ["recyclage", "alimentation_durable", "énergie_verte"]
  
  // Habitudes et préférences de vie
  final Map<String, dynamic> lifestylePreferences; // Ex: {"transport": "velo", "alimentation": "flexitarien"} 
  
  // Préférences de contenu
  final List<String> preferredContentTypes; // Ex: ["articles", "défis", "astuces_rapides"]
  final List<String> favoriteCategories; // Ex: ["climat", "biodiversité", "énergie", "déchets"]
  
  // Objectifs prioritaires
  final List<String> priorityGoals; // Ex: ["réduire_déchets", "économiser_énergie"]
  
  // Niveau de difficulté préféré pour les défis
  final String challengeDifficulty; // "débutant", "intermédiaire", "avancé"
  
  // Localisation (pour contenus et actions localisés)
  final String region;
  final bool useLocation;
  
  // Préférences sociales
  final bool shareOnSocialMedia;
  final List<String> connectedSocialNetworks;
  
  UserPreferencesModel({
    this.isDarkMode = false,
    this.preferredLanguage = 'fr',
    this.enableNotifications = true,
    this.ecoInterests = const [],
    this.lifestylePreferences = const {},
    this.preferredContentTypes = const ["articles", "défis"],
    this.favoriteCategories = const ["climat"],
    this.priorityGoals = const [],
    this.challengeDifficulty = 'débutant',
    this.region = 'France',
    this.useLocation = false,
    this.shareOnSocialMedia = false,
    this.connectedSocialNetworks = const [],
  });
  
  // Constructeur depuis JSON
  factory UserPreferencesModel.fromJson(Map<String, dynamic> json) {
    return UserPreferencesModel(
      isDarkMode: json['isDarkMode'] ?? false,
      preferredLanguage: json['preferredLanguage'] ?? 'fr',
      enableNotifications: json['enableNotifications'] ?? true,
      ecoInterests: List<String>.from(json['ecoInterests'] ?? []),
      lifestylePreferences: json['lifestylePreferences'] ?? {},
      preferredContentTypes: List<String>.from(json['preferredContentTypes'] ?? ["articles", "défis"]),
      favoriteCategories: List<String>.from(json['favoriteCategories'] ?? ["climat"]),
      priorityGoals: List<String>.from(json['priorityGoals'] ?? []),
      challengeDifficulty: json['challengeDifficulty'] ?? 'débutant',
      region: json['region'] ?? 'France',
      useLocation: json['useLocation'] ?? false,
      shareOnSocialMedia: json['shareOnSocialMedia'] ?? false,
      connectedSocialNetworks: List<String>.from(json['connectedSocialNetworks'] ?? []),
    );
  }
  
  // Conversion en JSON
  Map<String, dynamic> toJson() {
    return {
      'isDarkMode': isDarkMode,
      'preferredLanguage': preferredLanguage,
      'enableNotifications': enableNotifications,
      'ecoInterests': ecoInterests,
      'lifestylePreferences': lifestylePreferences,
      'preferredContentTypes': preferredContentTypes,
      'favoriteCategories': favoriteCategories,
      'priorityGoals': priorityGoals,
      'challengeDifficulty': challengeDifficulty,
      'region': region,
      'useLocation': useLocation,
      'shareOnSocialMedia': shareOnSocialMedia,
      'connectedSocialNetworks': connectedSocialNetworks,
    };
  }
  
  // Copie avec modification
  UserPreferencesModel copyWith({
    bool? isDarkMode,
    String? preferredLanguage,
    bool? enableNotifications,
    List<String>? ecoInterests,
    Map<String, dynamic>? lifestylePreferences,
    List<String>? preferredContentTypes,
    List<String>? favoriteCategories,
    List<String>? priorityGoals,
    String? challengeDifficulty,
    String? region,
    bool? useLocation,
    bool? shareOnSocialMedia,
    List<String>? connectedSocialNetworks,
  }) {
    return UserPreferencesModel(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      enableNotifications: enableNotifications ?? this.enableNotifications,
      ecoInterests: ecoInterests ?? this.ecoInterests,
      lifestylePreferences: lifestylePreferences ?? this.lifestylePreferences,
      preferredContentTypes: preferredContentTypes ?? this.preferredContentTypes,
      favoriteCategories: favoriteCategories ?? this.favoriteCategories,
      priorityGoals: priorityGoals ?? this.priorityGoals,
      challengeDifficulty: challengeDifficulty ?? this.challengeDifficulty,
      region: region ?? this.region,
      useLocation: useLocation ?? this.useLocation,
      shareOnSocialMedia: shareOnSocialMedia ?? this.shareOnSocialMedia,
      connectedSocialNetworks: connectedSocialNetworks ?? this.connectedSocialNetworks,
    );
  }
  
  // Méthode pour obtenir tous les intérêts disponibles
  static List<Map<String, dynamic>> getAllEcoInterests() {
    return [
      {'id': 'recyclage', 'name': 'Recyclage et réduction des déchets'},
      {'id': 'alimentation_durable', 'name': 'Alimentation durable'},
      {'id': 'énergie_verte', 'name': 'Énergies renouvelables'},
      {'id': 'transport_eco', 'name': 'Transport écologique'},
      {'id': 'biodiversité', 'name': 'Protection de la biodiversité'},
      {'id': 'eau', 'name': 'Économie d\'eau'},
      {'id': 'mode_durable', 'name': 'Mode éthique et durable'},
      {'id': 'zéro_déchet', 'name': 'Zéro déchet'},
      {'id': 'permaculture', 'name': 'Jardinage et permaculture'},
      {'id': 'bâtiment_durable', 'name': 'Habitat et construction écologique'},
      {'id': 'digital_sobre', 'name': 'Numérique responsable'},
      {'id': 'climate_activism', 'name': 'Activisme climatique'},
    ];
  }
  
  // Méthode pour obtenir toutes les catégories de contenu disponibles
  static List<Map<String, dynamic>> getAllCategories() {
    return [
      {'id': 'climat', 'name': 'Climat et réchauffement global'},
      {'id': 'biodiversité', 'name': 'Protection de la biodiversité'},
      {'id': 'énergie', 'name': 'Transition énergétique'},
      {'id': 'déchets', 'name': 'Gestion des déchets'},
      {'id': 'eau', 'name': 'Préservation de l\'eau'},
      {'id': 'alimentation', 'name': 'Alimentation durable'},
      {'id': 'transport', 'name': 'Mobilité verte'},
      {'id': 'consommation', 'name': 'Consommation responsable'},
      {'id': 'pollution', 'name': 'Lutte contre la pollution'},
      {'id': 'santé', 'name': 'Santé environnementale'},
    ];
  }
} 