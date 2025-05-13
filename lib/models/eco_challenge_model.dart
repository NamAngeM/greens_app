enum ChallengeCategory {
  transport,
  energy,
  food,
  waste,
  water,
  digital,
  community,
  general
}

enum ChallengeFrequency {
  daily,
  weekly,
  monthly,
  once
}

enum ChallengeLevel {
  beginner,
  intermediate,
  advanced,
  expert
}

/// Représente un défi écologique que l'utilisateur peut accomplir
class EcoChallenge {
  /// Identifiant unique du défi
  final String id;
  
  /// Titre du défi
  final String title;
  
  /// Description détaillée du défi
  final String description;
  
  /// Points obtenus en complétant le défi
  final int pointsValue;
  
  /// Durée estimée pour réaliser le défi
  final Duration duration;
  
  /// Catégorie thématique du défi
  final ChallengeCategory category;
  
  /// Fréquence à laquelle le défi devrait être effectué
  final ChallengeFrequency frequency;
  
  /// Niveau de difficulté du défi
  final ChallengeLevel level;
  
  /// Impact environnemental estimé (en kg CO2 économisés)
  final double estimatedImpact;
  
  /// Conseils pour réussir le défi
  final List<String> tips;
  
  /// Date de début du défi (si accepté par l'utilisateur)
  DateTime? startDate;
  
  /// Date de fin du défi (si complété)
  DateTime? completionDate;
  
  /// État de progression du défi (pourcentage)
  double progressPercentage;
  
  /// Indique si le défi a été complété
  bool isCompleted;
  
  /// URL de l'image illustrative (optionnelle)
  final String? imageUrl;
  
  EcoChallenge({
    required this.id,
    required this.title,
    required this.description,
    required this.pointsValue,
    required this.duration,
    required this.category,
    required this.frequency,
    required this.level,
    required this.estimatedImpact,
    this.tips = const [],
    this.startDate,
    this.completionDate,
    this.progressPercentage = 0.0,
    this.isCompleted = false,
    this.imageUrl,
  });
  
  /// Convertit une instance de EcoChallenge en Map (pour stockage/Firebase)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'pointsValue': pointsValue,
      'durationInMinutes': duration.inMinutes,
      'category': category.toString().split('.').last,
      'frequency': frequency.toString().split('.').last,
      'level': level.toString().split('.').last,
      'estimatedImpact': estimatedImpact,
      'tips': tips,
      'startDate': startDate?.millisecondsSinceEpoch,
      'completionDate': completionDate?.millisecondsSinceEpoch,
      'progressPercentage': progressPercentage,
      'isCompleted': isCompleted,
      'imageUrl': imageUrl,
    };
  }
  
  /// Crée une instance de EcoChallenge à partir d'une Map (depuis stockage/Firebase)
  factory EcoChallenge.fromMap(Map<String, dynamic> map) {
    return EcoChallenge(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      pointsValue: map['pointsValue'] ?? 0,
      duration: Duration(minutes: map['durationInMinutes'] ?? 0),
      category: _categoryFromString(map['category'] ?? 'general'),
      frequency: _frequencyFromString(map['frequency'] ?? 'daily'),
      level: _levelFromString(map['level'] ?? 'beginner'),
      estimatedImpact: map['estimatedImpact']?.toDouble() ?? 0.0,
      tips: List<String>.from(map['tips'] ?? []),
      startDate: map['startDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['startDate'])
          : null,
      completionDate: map['completionDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['completionDate'])
          : null,
      progressPercentage: map['progressPercentage']?.toDouble() ?? 0.0,
      isCompleted: map['isCompleted'] ?? false,
      imageUrl: map['imageUrl'],
    );
  }
  
  /// Crée une copie de l'instance avec les modifications spécifiées
  EcoChallenge copyWith({
    String? id,
    String? title,
    String? description,
    int? pointsValue,
    Duration? duration,
    ChallengeCategory? category,
    ChallengeFrequency? frequency,
    ChallengeLevel? level,
    double? estimatedImpact,
    List<String>? tips,
    DateTime? startDate,
    DateTime? completionDate,
    double? progressPercentage,
    bool? isCompleted,
    String? imageUrl,
  }) {
    return EcoChallenge(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      pointsValue: pointsValue ?? this.pointsValue,
      duration: duration ?? this.duration,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      level: level ?? this.level,
      estimatedImpact: estimatedImpact ?? this.estimatedImpact,
      tips: tips ?? this.tips,
      startDate: startDate ?? this.startDate,
      completionDate: completionDate ?? this.completionDate,
      progressPercentage: progressPercentage ?? this.progressPercentage,
      isCompleted: isCompleted ?? this.isCompleted,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
  
  /// Met à jour la progression du défi
  void updateProgress(double progress) {
    progressPercentage = progress;
    if (progress >= 100) {
      isCompleted = true;
      completionDate = DateTime.now();
    }
  }
  
  /// Démarre le défi
  void start() {
    startDate = DateTime.now();
  }
  
  /// Marque le défi comme complété
  void complete() {
    isCompleted = true;
    progressPercentage = 100;
    completionDate = DateTime.now();
  }
  
  // Méthodes privées d'aide à la conversion
  static ChallengeCategory _categoryFromString(String value) {
    return ChallengeCategory.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => ChallengeCategory.general,
    );
  }
  
  static ChallengeFrequency _frequencyFromString(String value) {
    return ChallengeFrequency.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => ChallengeFrequency.daily,
    );
  }
  
  static ChallengeLevel _levelFromString(String value) {
    return ChallengeLevel.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => ChallengeLevel.beginner,
    );
  }
} 