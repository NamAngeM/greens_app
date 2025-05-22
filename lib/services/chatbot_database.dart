// lib/services/chatbot_database.dart
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class ChatbotDatabase {
  static final ChatbotDatabase instance = ChatbotDatabase._init();
  static Database? _database;

  ChatbotDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('chatbot.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
    CREATE TABLE questions(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      question TEXT NOT NULL,
      categorie TEXT NOT NULL,
      difficulte TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE reponses(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      question_id INTEGER,
      texte TEXT NOT NULL,
      explication TEXT NOT NULL,
      points INTEGER NOT NULL,
      est_bonne_reponse INTEGER NOT NULL,
      FOREIGN KEY (question_id) REFERENCES questions (id)
    )
    ''');

    await db.execute('''
    CREATE TABLE conversations(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      message TEXT NOT NULL,
      is_user INTEGER NOT NULL,
      timestamp TEXT NOT NULL
    )
    ''');

    await db.execute('''
    CREATE TABLE categories(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      nom TEXT NOT NULL,
      couleur TEXT NOT NULL
    )
    ''');

    // Créer un index pour la recherche rapide
    await db.execute(
      'CREATE INDEX idx_question_text ON questions(question)',
    );
  }

  // Charger les données initiales depuis le fichier JSON
  Future<void> loadInitialData() async {
    final db = await database;
    
    // Vérifier si la base de données est déjà remplie
    final questionCount = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM questions'));
    
    if (questionCount != null && questionCount > 0) {
      print('La base de données contient déjà $questionCount questions.');
      return;
    }

    try {
      // Charger le fichier JSON
      final String jsonString = await rootBundle.loadString('assets/data/ecologie.json');
      final data = json.decode(jsonString);
      
      // Insérer les catégories
      for (var categorie in data['metadata']['categories']) {
        await db.insert('categories', {
          'nom': categorie,
          'couleur': _getCategoryColor(categorie),
        });
      }
      
      // Insérer les questions et réponses
      for (var questionData in data['questions']) {
        final questionId = await db.insert('questions', {
          'question': questionData['question'],
          'categorie': questionData['categorie'],
          'difficulte': questionData['difficulte'],
        });
        
        for (var reponseData in questionData['reponses']) {
          await db.insert('reponses', {
            'question_id': questionId,
            'texte': reponseData['texte'],
            'explication': reponseData['explication'],
            'points': reponseData['points'],
            'est_bonne_reponse': reponseData['id'] == questionData['bonne_reponse'] ? 1 : 0,
          });
        }
      }
      
      print('Données initiales chargées avec succès dans la base de données SQLite.');
    } catch (e) {
      print('Erreur lors du chargement des données initiales: $e');
    }
  }
  
  // Rechercher des questions par texte
  Future<List<Map<String, dynamic>>> searchQuestions(String query) async {
    final db = await database;
    
    return await db.rawQuery('''
      SELECT q.id, q.question, q.categorie, q.difficulte
      FROM questions q
      WHERE q.question LIKE ?
      ORDER BY q.id
      LIMIT 10
    ''', ['%$query%']);
  }
  
  // Recherche avancée avec correspondance de mots-clés
  Future<List<Map<String, dynamic>>> searchQuestionsAdvanced(String query) async {
    final db = await database;
    
    // Diviser la requête en mots-clés
    final keywords = query.toLowerCase().split(' ')
        .where((word) => word.length > 3)
        .toList();
    
    if (keywords.isEmpty) {
      return searchQuestions(query); // Recherche simple si pas de mots-clés
    }
    
    // Construire la requête SQL avec plusieurs conditions LIKE et scoring avancé
    String sql = '''
      SELECT q.id, q.question, q.categorie, q.difficulte,
             (
    ''';
    
    // Ajouter un score pour chaque mot-clé trouvé avec pondération
    for (int i = 0; i < keywords.length; i++) {
      if (i > 0) sql += ' + ';
      // Score plus élevé pour les correspondances exactes dans la question
      sql += "CASE WHEN q.question LIKE '% ${keywords[i]} %' THEN 2.0 ";
      // Score moyen pour les correspondances partielles
      sql += "WHEN q.question LIKE '%${keywords[i]}%' THEN 1.0 ";
      // Score plus faible pour les correspondances dans la catégorie
      sql += "WHEN q.categorie LIKE '%${keywords[i]}%' THEN 0.5 ELSE 0 END";
    }
    
    sql += '''
             ) as score
      FROM questions q
      WHERE 
    ''';
    
    // Ajouter une condition pour chaque mot-clé (au moins un doit correspondre)
    List<String> conditions = [];
    for (int i = 0; i < keywords.length; i++) {
      conditions.add("q.question LIKE '%${keywords[i]}%'");
      conditions.add("q.categorie LIKE '%${keywords[i]}%'");
    }
    
    sql += conditions.join(' OR ');
    
    sql += '''
      ORDER BY score DESC, q.id
      LIMIT 15
    ''';
    
    return await db.rawQuery(sql);
  }

  // Nouvelle méthode pour trouver des questions similaires
  Future<List<Map<String, dynamic>>> findSimilarQuestions(int questionId, {int limit = 5}) async {
    final db = await database;
    
    // Obtenir la question de référence
    final questionData = await db.query(
      'questions',
      where: 'id = ?',
      whereArgs: [questionId],
    );
    
    if (questionData.isEmpty) {
      return [];
    }
    
    final question = questionData.first;
    final categorie = question['categorie'] as String;
    final keywords = _extractKeywords(question['question'] as String);
    
    if (keywords.isEmpty) {
      // Si pas de mots-clés, retourner des questions de la même catégorie
      return await db.query(
        'questions',
        where: 'categorie = ? AND id != ?',
        whereArgs: [categorie, questionId],
        orderBy: 'id',
        limit: limit,
      );
    }
    
    // Construire une requête pour trouver des questions similaires
    String sql = '''
      SELECT q.id, q.question, q.categorie, q.difficulte,
             (CASE WHEN q.categorie = ? THEN 1.0 ELSE 0.0 END) as category_score,
             (
    ''';
    
    // Ajouter un score pour chaque mot-clé trouvé
    for (int i = 0; i < keywords.length; i++) {
      if (i > 0) sql += ' + ';
      sql += "CASE WHEN q.question LIKE '%${keywords[i]}%' THEN 0.5 ELSE 0 END";
    }
    
    sql += '''
             ) as keyword_score,
             (CASE WHEN q.categorie = ? THEN 1.0 ELSE 0.0 END) + (
    ''';
    
    // Répéter les mêmes conditions pour le score total
    for (int i = 0; i < keywords.length; i++) {
      if (i > 0) sql += ' + ';
      sql += "CASE WHEN q.question LIKE '%${keywords[i]}%' THEN 0.5 ELSE 0 END";
    }
    
    sql += '''
             ) as total_score
      FROM questions q
      WHERE q.id != ?
      ORDER BY total_score DESC, q.id
      LIMIT ?
    ''';
    
    return await db.rawQuery(sql, [categorie, categorie, questionId, limit]);
  }
  
  // Méthode pour extraire les mots-clés d'une question
  List<String> _extractKeywords(String text) {
    final stopWords = {
      'le', 'la', 'les', 'un', 'une', 'des', 'et', 'ou', 'mais', 'donc',
      'car', 'ni', 'que', 'qui', 'quoi', 'dont', 'où', 'comment', 'pourquoi',
      'quand', 'est', 'sont', 'être', 'avoir', 'faire', 'dire', 'voir',
      'aller', 'venir', 'pouvoir', 'vouloir', 'devoir', 'falloir', 'savoir'
    };
    
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .split(' ')
        .where((word) => word.length > 3 && !stopWords.contains(word))
        .toList();
  }

  // Obtenir une question par ID avec ses réponses
  Future<Map<String, dynamic>> getQuestionWithResponses(int questionId) async {
    final db = await database;
    
    final questions = await db.query(
      'questions',
      where: 'id = ?',
      whereArgs: [questionId],
    );
    
    if (questions.isEmpty) {
      return {};
    }
    
    final question = questions.first;
    
    final reponses = await db.query(
      'reponses',
      where: 'question_id = ?',
      whereArgs: [questionId],
    );
    
    return {
      ...question,
      'reponses': reponses,
      'bonne_reponse': reponses
          .firstWhere((r) => r['est_bonne_reponse'] == 1)['id'],
    };
  }
  
  // Sauvegarder un message de conversation
  Future<int> saveConversationMessage(String message, bool isUser) async {
    final db = await database;
    
    return await db.insert('conversations', {
      'message': message,
      'is_user': isUser ? 1 : 0,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }
  
  // Obtenir l'historique des conversations
  Future<List<Map<String, dynamic>>> getConversationHistory() async {
    final db = await database;
    
    return await db.query(
      'conversations',
      orderBy: 'timestamp DESC',
      limit: 50,
    );
  }
  
  // Obtenir des questions par catégorie
  Future<List<Map<String, dynamic>>> getQuestionsByCategory(String category) async {
    final db = await database;
    
    return await db.query(
      'questions',
      where: 'categorie = ?',
      whereArgs: [category],
    );
  }
  
  // Nouvelle méthode pour obtenir des questions par difficulté
  Future<List<Map<String, dynamic>>> getQuestionsByDifficulty(String difficulty) async {
    final db = await database;
    
    return await db.query(
      'questions',
      where: 'difficulte = ?',
      whereArgs: [difficulty],
    );
  }
  
  // Nouvelle méthode pour obtenir des statistiques sur les questions
  Future<Map<String, dynamic>> getQuestionStats() async {
    final db = await database;
    
    // Nombre total de questions
    final totalCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM questions')
    );
    
    // Nombre de questions par catégorie
    final categoryCounts = await db.rawQuery('''
      SELECT categorie, COUNT(*) as count
      FROM questions
      GROUP BY categorie
      ORDER BY count DESC
    ''');
    
    // Nombre de questions par difficulté
    final difficultyCounts = await db.rawQuery('''
      SELECT difficulte, COUNT(*) as count
      FROM questions
      GROUP BY difficulte
      ORDER BY difficulte
    ''');
    
    return {
      'totalCount': totalCount,
      'categoryCounts': categoryCounts,
      'difficultyCounts': difficultyCounts,
    };
  }

  // Couleurs par défaut pour les catégories
  String _getCategoryColor(String category) {
    final colors = {
      'transport': '#1976D2',
      'dechets': '#FFA000',
      'eau': '#00ACC1',
      'alimentation': '#43A047',
      'numerique': '#7B1FA2',
      'energie': '#FF7043',
      'mode': '#EC407A',
      'consommation': '#009688',
    };
    
    return colors[category] ?? '#607D8B'; // Gris par défaut
  }
  
  // Fermer la base de données
  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
