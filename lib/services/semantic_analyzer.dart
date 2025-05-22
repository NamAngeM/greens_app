 // lib/services/semantic_analyzer.dart
import 'dart:math';

/// Service d'analyse sémantique pour améliorer la compréhension des questions
/// et la pertinence des réponses du chatbot écologique.
class SemanticAnalyzer {
  // Singleton
  static final SemanticAnalyzer instance = SemanticAnalyzer._internal();
  SemanticAnalyzer._internal();

  // Dictionnaire de synonymes pour les termes écologiques
  final Map<String, List<String>> _synonyms = {
    // Catégories principales
    'écologie': ['écologique', 'environnement', 'nature', 'écosystème', 'planète', 'terre', 'durable', 'vert', 'bio'],
    'déchets': ['ordures', 'poubelle', 'recyclage', 'tri', 'plastique', 'compost', 'déchet', 'détritus', 'rebut'],
    'eau': ['hydrique', 'océan', 'mer', 'rivière', 'potable', 'consommation d\'eau', 'ressource hydrique', 'aquatique'],
    'énergie': ['électricité', 'renouvelable', 'solaire', 'éolienne', 'consommation énergétique', 'fossile', 'nucléaire'],
    'transport': ['voiture', 'vélo', 'mobilité', 'déplacement', 'carburant', 'essence', 'diesel', 'électrique', 'hybride'],
    'alimentation': ['nourriture', 'manger', 'repas', 'bio', 'végétarien', 'local', 'agriculture', 'biologique', 'végétalien'],
    'consommation': ['acheter', 'achat', 'produit', 'magasin', 'responsable', 'éthique', 'durable', 'commerce', 'équitable'],
    'mode': ['vêtement', 'textile', 'habit', 'seconde main', 'fast fashion', 'éthique', 'durable', 'coton', 'synthétique'],
    'numérique': ['digital', 'internet', 'informatique', 'ordinateur', 'smartphone', 'email', 'données', 'serveur', 'cloud'],
    
    // Concepts écologiques spécifiques
    'biodiversité': ['espèces', 'faune', 'flore', 'extinction', 'habitat', 'écosystème', 'conservation', 'protection'],
    'climat': ['réchauffement', 'changement climatique', 'effet de serre', 'CO2', 'carbone', 'gaz', 'température'],
    'pollution': ['contamination', 'émission', 'smog', 'particule', 'toxique', 'déchet', 'rejet', 'filtre'],
    'recyclage': ['réutilisation', 'valorisation', 'tri', 'économie circulaire', 'compostage', 'zéro déchet'],
    'empreinte carbone': ['impact carbone', 'bilan carbone', 'neutralité carbone', 'compensation', 'émission de CO2'],
    'développement durable': ['soutenable', 'durable', 'responsable', 'éthique', 'équitable', 'viable', 'pérenne'],
  };

  // Mots d'arrêt (stop words) en français
  final Set<String> _stopWords = {
    'le', 'la', 'les', 'un', 'une', 'des', 'du', 'de', 'ce', 'cette', 'ces',
    'mon', 'ma', 'mes', 'ton', 'ta', 'tes', 'son', 'sa', 'ses', 'notre', 'nos',
    'votre', 'vos', 'leur', 'leurs', 'et', 'ou', 'mais', 'donc', 'car', 'ni',
    'que', 'qui', 'quoi', 'dont', 'où', 'comment', 'pourquoi', 'quand', 'est',
    'sont', 'être', 'avoir', 'faire', 'dire', 'voir', 'aller', 'venir', 'pouvoir',
    'vouloir', 'devoir', 'falloir', 'savoir', 'croire', 'penser', 'je', 'tu', 'il',
    'elle', 'on', 'nous', 'vous', 'ils', 'elles', 'me', 'te', 'se', 'pour', 'par',
    'en', 'dans', 'sur', 'sous', 'avec', 'sans', 'à', 'au', 'aux', 'chez', 'vers',
  };

  // Patterns de questions directes
  final List<RegExp> _directQuestionPatterns = [
    RegExp(r"^qu[e'].*\?", caseSensitive: false),
    RegExp(r"^qu[i'].*\?", caseSensitive: false),
    RegExp(r"^comment.*\?", caseSensitive: false),
    RegExp(r"^pourquoi.*\?", caseSensitive: false),
    RegExp(r"^quand.*\?", caseSensitive: false),
    RegExp(r"^où.*\?", caseSensitive: false),
    RegExp(r"^est-ce que.*\?", caseSensitive: false),
    RegExp(r"^peux-tu.*\?", caseSensitive: false),
    RegExp(r"^pouvez-vous.*\?", caseSensitive: false),
    RegExp(r"^c'est quoi.*", caseSensitive: false),
    RegExp(r"^qu'est-ce que.*", caseSensitive: false),
    RegExp(r"^explique.*", caseSensitive: false),
    RegExp(r"^expliques?.*", caseSensitive: false),
    RegExp(r"^parle.*de.*", caseSensitive: false),
    RegExp(r"^dis-moi.*", caseSensitive: false),
  ];

  /// Détecte si le message est une question directe
  bool isDirectQuestion(String message) {
    final normalizedMessage = message.toLowerCase().trim();
    
    // Vérifier si le message correspond à un pattern de question directe
    for (final pattern in _directQuestionPatterns) {
      if (pattern.hasMatch(normalizedMessage)) {
        return true;
      }
    }
    
    // Vérifier si le message se termine par un point d'interrogation
    if (normalizedMessage.endsWith('?')) {
      return true;
    }
    
    return false;
  }

  /// Extrait les mots-clés significatifs d'un texte
  List<String> extractKeywords(String text) {
    // Normaliser le texte
    final normalizedText = text.toLowerCase()
      .replaceAll(RegExp(r"[^\w\s']"), ' ') // Remplacer les caractères spéciaux par des espaces
      .replaceAll(RegExp(r'\s+'), ' ')       // Remplacer les espaces multiples par un seul
      .trim();
    
    // Diviser en mots
    final words = normalizedText.split(' ');
    
    // Filtrer les mots d'arrêt et les mots courts
    return words
      .where((word) => word.length > 2 && !_stopWords.contains(word))
      .toList();
  }

  /// Étend les mots-clés avec leurs synonymes
  List<String> expandWithSynonyms(List<String> keywords) {
    final expandedKeywords = <String>[];
    
    // Ajouter les mots-clés originaux
    expandedKeywords.addAll(keywords);
    
    // Ajouter les synonymes
    for (final keyword in keywords) {
      // Vérifier si le mot-clé est un synonyme connu
      for (final entry in _synonyms.entries) {
        if (entry.value.contains(keyword)) {
          // Ajouter le terme principal
          expandedKeywords.add(entry.key);
          // Ajouter d'autres synonymes
          expandedKeywords.addAll(entry.value.where((syn) => syn != keyword));
          break;
        }
      }
      
      // Vérifier si le mot-clé est un terme principal
      if (_synonyms.containsKey(keyword)) {
        // Ajouter tous ses synonymes
        expandedKeywords.addAll(_synonyms[keyword]!);
      }
    }
    
    // Éliminer les doublons
    return expandedKeywords.toSet().toList();
  }

  /// Calcule la distance de Levenshtein entre deux chaînes
  int levenshteinDistance(String s, String t) {
    if (s.isEmpty) return t.length;
    if (t.isEmpty) return s.length;

    final matrix = List.generate(
      s.length + 1,
      (i) => List.generate(t.length + 1, (j) => 0),
    );

    for (var i = 0; i <= s.length; i++) matrix[i][0] = i;
    for (var j = 0; j <= t.length; j++) matrix[0][j] = j;

    for (var i = 1; i <= s.length; i++) {
      for (var j = 1; j <= t.length; j++) {
        final cost = s[i - 1] == t[j - 1] ? 0 : 1;
        matrix[i][j] = [
          matrix[i - 1][j] + 1,      // deletion
          matrix[i][j - 1] + 1,      // insertion
          matrix[i - 1][j - 1] + cost, // substitution
        ].reduce(min);
      }
    }

    return matrix[s.length][t.length];
  }

  /// Calcule le score de similarité entre deux chaînes (0 à 1)
  double similarityScore(String s1, String s2) {
    if (s1.isEmpty && s2.isEmpty) return 1.0;
    if (s1.isEmpty || s2.isEmpty) return 0.0;
    
    final distance = levenshteinDistance(s1.toLowerCase(), s2.toLowerCase());
    final maxLength = max(s1.length, s2.length);
    
    return 1.0 - (distance / maxLength);
  }

  /// Détermine la catégorie la plus probable d'une question
  String? determineCategoryFromText(String text) {
    final keywords = extractKeywords(text);
    final expandedKeywords = expandWithSynonyms(keywords);
    
    // Compter les occurrences de mots-clés par catégorie
    final categoryScores = <String, double>{};
    
    for (final keyword in expandedKeywords) {
      for (final category in _synonyms.keys) {
        // Si le mot-clé est le nom de la catégorie
        if (keyword == category) {
          categoryScores[category] = (categoryScores[category] ?? 0) + 2.0;
        }
        // Si le mot-clé est un synonyme de la catégorie
        else if (_synonyms[category]!.contains(keyword)) {
          categoryScores[category] = (categoryScores[category] ?? 0) + 1.0;
        }
      }
    }
    
    // Trouver la catégorie avec le score le plus élevé
    String? bestCategory;
    double bestScore = 0;
    
    for (final entry in categoryScores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestCategory = entry.key;
      }
    }
    
    // Retourner la catégorie seulement si le score est significatif
    return bestScore >= 1.0 ? bestCategory : null;
  }
}