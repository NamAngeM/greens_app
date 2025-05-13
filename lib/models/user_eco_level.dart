/// Classe représentant un niveau écologique de l'utilisateur avec ses caractéristiques
class UserEcoLevel {
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
  
  UserEcoLevel({
    required this.level,
    required this.title,
    required this.description,
    required this.pointsRequired,
    required this.badgeUrl,
  });
  
  /// Convertit une instance de UserEcoLevel en Map (pour stockage/Firebase)
  Map<String, dynamic> toMap() {
    return {
      'level': level,
      'title': title,
      'description': description,
      'pointsRequired': pointsRequired,
      'badgeUrl': badgeUrl,
    };
  }
  
  /// Crée une instance de UserEcoLevel à partir d'une Map (depuis stockage/Firebase)
  factory UserEcoLevel.fromMap(Map<String, dynamic> map) {
    return UserEcoLevel(
      level: map['level'] ?? 1,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      pointsRequired: map['pointsRequired'] ?? 0,
      badgeUrl: map['badgeUrl'] ?? '',
    );
  }
} 