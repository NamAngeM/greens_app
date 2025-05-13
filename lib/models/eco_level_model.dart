/// Enumération des différents niveaux d'expertise écologique
enum EcoLevelType {
  beginner,    // Débutant, moins de 100 points
  aware,       // Sensibilisé, entre 100 et 299 points
  engaged,     // Engagé, entre 300 et 699 points
  ambassador,  // Ambassadeur, entre 700 et 1499 points
  expert       // Expert, 1500 points et plus
}

/// Classe représentant un niveau écologique avec ses caractéristiques
class EcoLevel {
  /// Numéro du niveau
  final int level;
  
  /// Titre du niveau
  final String title;
  
  /// Description du niveau
  final String description;
  
  /// Points requis pour atteindre ce niveau
  final int pointsRequired;
  
  /// URL de l'image du badge associé au niveau
  final String badgeUrl;
  
  EcoLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.badgeUrl,
  });
  
  /// Convertit une instance de EcoLevel en Map (pour stockage/Firebase)
  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'title': title,
      'description': description,
      'pointsRequired': pointsRequired,
      'badgeUrl': badgeUrl,
    };
  }
  
  /// Crée une instance de EcoLevel à partir d'une Map (depuis stockage/Firebase)
  factory EcoLevel.fromMap(Map<String, dynamic> map) {
    return EcoLevel(
      level: map['level'] ?? 1,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      pointsRequired: map['pointsRequired'] ?? 0,
      badgeUrl: map['badgeUrl'] ?? '',
    );
  }
}

/// Système de gestion des niveaux écologiques
class EcoLevelSystem {
  /// Détermine le niveau écologique en fonction du nombre de points
  static EcoLevelType getLevelFromPoints(int points) {
    if (points < 100) return EcoLevelType.beginner;
    if (points < 300) return EcoLevelType.aware;
    if (points < 700) return EcoLevelType.engaged;
    if (points < 1500) return EcoLevelType.ambassador;
    return EcoLevelType.expert;
  }
  
  /// Retourne le titre du niveau écologique
  static String getLevelTitle(EcoLevelType level) {
    switch (level) {
      case EcoLevelType.beginner: 
        return "Éco-débutant";
      case EcoLevelType.aware: 
        return "Éco-sensibilisé";
      case EcoLevelType.engaged: 
        return "Éco-engagé";
      case EcoLevelType.ambassador: 
        return "Ambassadeur vert";
      case EcoLevelType.expert: 
        return "Expert écologique";
    }
  }
  
  /// Retourne le nombre de points nécessaires pour atteindre le niveau suivant
  static int getPointsToNextLevel(int currentPoints) {
    final currentLevel = getLevelFromPoints(currentPoints);
    
    switch (currentLevel) {
      case EcoLevelType.beginner:
        return 100 - currentPoints;
      case EcoLevelType.aware:
        return 300 - currentPoints;
      case EcoLevelType.engaged:
        return 700 - currentPoints;
      case EcoLevelType.ambassador:
        return 1500 - currentPoints;
      case EcoLevelType.expert:
        return 0; // Niveau maximum atteint
    }
  }
  
  /// Retourne le niveau suivant
  static EcoLevelType? getNextLevel(EcoLevelType currentLevel) {
    switch (currentLevel) {
      case EcoLevelType.beginner:
        return EcoLevelType.aware;
      case EcoLevelType.aware:
        return EcoLevelType.engaged;
      case EcoLevelType.engaged:
        return EcoLevelType.ambassador;
      case EcoLevelType.ambassador:
        return EcoLevelType.expert;
      case EcoLevelType.expert:
        return null; // Pas de niveau supérieur
    }
  }
  
  /// Retourne le pourcentage de progression vers le niveau suivant
  static double getProgressToNextLevel(int points) {
    final currentLevel = getLevelFromPoints(points);
    
    switch (currentLevel) {
      case EcoLevelType.beginner:
        return points / 100;
      case EcoLevelType.aware:
        return (points - 100) / 200;
      case EcoLevelType.engaged:
        return (points - 300) / 400;
      case EcoLevelType.ambassador:
        return (points - 700) / 800;
      case EcoLevelType.expert:
        return 1.0; // 100% (niveau maximum)
    }
  }
  
  /// Retourne une description du niveau actuel
  static String getLevelDescription(EcoLevelType level) {
    switch (level) {
      case EcoLevelType.beginner:
        return "Vous commencez votre parcours écologique. Continuez à apprendre et à agir pour progresser !";
      case EcoLevelType.aware:
        return "Vous êtes sensibilisé aux enjeux environnementaux et commencez à adopter des gestes écologiques.";
      case EcoLevelType.engaged:
        return "Vous adoptez de nombreux gestes écologiques au quotidien et inspirez votre entourage.";
      case EcoLevelType.ambassador:
        return "Vous êtes un exemple en matière d'écologie et partagez activement vos connaissances avec les autres.";
      case EcoLevelType.expert:
        return "Vous avez atteint le plus haut niveau d'expertise écologique. Bravo pour votre engagement exemplaire !";
    }
  }
  
  /// Retourne les avantages liés au niveau
  static List<String> getLevelBenefits(EcoLevelType level) {
    switch (level) {
      case EcoLevelType.beginner:
        return [
          "Accès aux défis écologiques de base",
          "Suivi de votre empreinte carbone"
        ];
      case EcoLevelType.aware:
        return [
          "Déblocage des défis intermédiaires",
          "Accès aux offres partenaires (5% de réduction)",
          "Badge 'Éco-sensibilisé' sur votre profil"
        ];
      case EcoLevelType.engaged:
        return [
          "Déblocage des défis avancés",
          "Accès aux offres partenaires (10% de réduction)",
          "Possibilité de créer des défis personnalisés",
          "Badge 'Éco-engagé' sur votre profil"
        ];
      case EcoLevelType.ambassador:
        return [
          "Déblocage de tous les défis",
          "Accès aux offres partenaires (15% de réduction)",
          "Statut d'ambassadeur dans la communauté",
          "Possibilité de lancer des défis communautaires",
          "Badge 'Ambassadeur vert' sur votre profil"
        ];
      case EcoLevelType.expert:
        return [
          "Statut d'expert dans la communauté",
          "Accès aux offres partenaires (20% de réduction)",
          "Fonctionnalités premium débloquées",
          "Participation aux événements exclusifs",
          "Badge 'Expert écologique' sur votre profil"
        ];
    }
  }
  
  /// Retourne une couleur associée au niveau (en format hexadécimal)
  static String getLevelColor(EcoLevelType level) {
    switch (level) {
      case EcoLevelType.beginner:
        return "#4CAF50"; // Vert clair
      case EcoLevelType.aware:
        return "#009688"; // Teal
      case EcoLevelType.engaged:
        return "#00796B"; // Teal foncé
      case EcoLevelType.ambassador:
        return "#2E7D32"; // Vert foncé
      case EcoLevelType.expert:
        return "#1B5E20"; // Vert très foncé
    }
  }
  
  /// Retourne une icône associée au niveau (nom de l'icône Flutter)
  static String getLevelIcon(EcoLevelType level) {
    switch (level) {
      case EcoLevelType.beginner:
        return "sprout";
      case EcoLevelType.aware:
        return "spa";
      case EcoLevelType.engaged:
        return "eco";
      case EcoLevelType.ambassador:
        return "park";
      case EcoLevelType.expert:
        return "forest";
    }
  }
} 