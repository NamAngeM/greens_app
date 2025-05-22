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
    
    // Construire la requête SQL avec plusieurs conditions LIKE
    String sql = '''
      SELECT q.id, q.question, q.categorie, q.difficulte,
             (
    ''';
    
    // Ajouter un score pour chaque mot-clé trouvé
    for (int i = 0; i < keywords.length; i++) {
      if (i > 0) sql += ' + ';
      sql += "CASE WHEN q.question LIKE '%${keywords[i]}%' THEN 1 ELSE 0 END";
    }
    
    sql += '''
             ) as score
      FROM questions q
      WHERE 
    ''';
    
    // Ajouter une condition pour chaque mot-clé (au moins un doit correspondre)
    for (int i = 0; i < keywords.length; i++) {
      if (i > 0) sql += ' OR ';
      sql += "q.question LIKE '%${keywords[i]}%'";
    }
    
    sql += '''
      ORDER BY score DESC, q.id
      LIMIT 10
    ''';
    
    return await db.rawQuery(sql);
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
