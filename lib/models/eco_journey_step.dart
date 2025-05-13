/// Représente une étape du parcours écologique de l'utilisateur
class EcoJourneyStep {
  /// Identifiant unique de l'étape
  final String id;
  
  /// Titre affiché à l'utilisateur
  final String title;
  
  /// Description détaillée de l'étape
  final String description;
  
  /// Route à laquelle cette étape est associée
  final String route;
  
  /// Liste des tâches à accomplir pour cette étape
  final List<String> tasks;
  
  /// Indicateur si l'étape a été complétée
  bool isCompleted;
  
  EcoJourneyStep({
    required this.id,
    required this.title,
    required this.description,
    this.route = '',
    this.tasks = const [],
    this.isCompleted = false,
  });
} 