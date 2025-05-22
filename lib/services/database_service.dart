import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/qa_model.dart';
import '../data/eco_qa_data.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;
  
  // Cache pour les requêtes fréquentes
  final Map<String, List<QAModel>> _cache = {};
  final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheDuration = Duration(minutes: 5);
  
  // Index pour les recherches rapides
  final Map<String, Set<int>> _keywordIndex = {};
  final Map<String, Set<int>> _categoryIndex = {};

  factory DatabaseService() => _instance;

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'eco_chatbot.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE qa_pairs(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        question TEXT NOT NULL,
        answer TEXT NOT NULL,
        keywords TEXT NOT NULL,
        category TEXT,
        usage_count INTEGER DEFAULT 0,
        last_used TIMESTAMP,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      )
    ''');

    // Créer les index pour optimiser les recherches
    await db.execute('CREATE INDEX idx_keywords ON qa_pairs(keywords)');
    await db.execute('CREATE INDEX idx_category ON qa_pairs(category)');
    await db.execute('CREATE INDEX idx_usage ON qa_pairs(usage_count)');
    await db.execute('CREATE INDEX idx_last_used ON qa_pairs(last_used)');

    // Insérer les données initiales
    final initialQA = getInitialEcoQA();
    for (var qa in initialQA) {
      final id = await db.insert('qa_pairs', {
        'question': qa.question,
        'answer': qa.answer,
        'keywords': qa.keywords.join(','),
        'category': _determineCategory(qa.question),
        'created_at': DateTime.now().toIso8601String(),
      });
      
      // Mettre à jour les index
      _updateIndexes(id, qa);
    }
  }

  void _updateIndexes(int id, QAModel qa) {
    // Index des mots-clés
    for (final keyword in qa.keywords) {
      _keywordIndex.putIfAbsent(keyword, () => {}).add(id);
    }
    
    // Index des catégories
    if (qa.category != null) {
      _categoryIndex.putIfAbsent(qa.category!, () => {}).add(id);
    }
  }

  String _determineCategory(String question) {
    final lowerQuestion = question.toLowerCase();
    if (lowerQuestion.contains('climat') || lowerQuestion.contains('réchauffement')) return 'climat';
    if (lowerQuestion.contains('énergie')) return 'énergie';
    if (lowerQuestion.contains('déchet') || lowerQuestion.contains('recyclage')) return 'déchets';
    if (lowerQuestion.contains('eau')) return 'eau';
    if (lowerQuestion.contains('biodiversité')) return 'biodiversité';
    if (lowerQuestion.contains('agriculture') || lowerQuestion.contains('alimentation')) return 'agriculture';
    if (lowerQuestion.contains('transport') || lowerQuestion.contains('mobilité')) return 'transport';
    if (lowerQuestion.contains('maison') || lowerQuestion.contains('habitat')) return 'habitat';
    if (lowerQuestion.contains('consommation')) return 'consommation';
    if (lowerQuestion.contains('pollution')) return 'pollution';
    return 'général';
  }

  Future<int> insertQA(QAModel qa) async {
    final db = await database;
    return await db.insert('qa_pairs', qa.toMap());
  }

  Future<List<QAModel>> getAllQA() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('qa_pairs');
    return List.generate(maps.length, (i) => QAModel.fromMap(maps[i]));
  }

  Future<List<QAModel>> searchQA(String query) async {
    // Vérifier le cache
    final cacheKey = 'search:$query';
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final db = await database;
    final normalizedQuery = query.toLowerCase();
    
    // Recherche par mots-clés
    final keywords = normalizedQuery.split(' ').where((word) => word.length > 2).toList();
    final keywordConditions = keywords.map((k) => 'keywords LIKE ?').join(' OR ');
    final keywordArgs = keywords.map((k) => '%$k%').toList();
    
    // Recherche par similarité de question
    final questionConditions = keywords.map((k) => 'question LIKE ?').join(' OR ');
    final questionArgs = keywords.map((k) => '%$k%').toList();
    
    final results = await db.query(
      'qa_pairs',
      where: '($keywordConditions) OR ($questionConditions)',
      whereArgs: [...keywordArgs, ...questionArgs],
      orderBy: 'usage_count DESC, last_used DESC',
    );

    // Mettre à jour le compteur d'utilisation et la date de dernière utilisation
    if (results.isNotEmpty) {
      await db.update(
        'qa_pairs',
        {
          'usage_count': 'usage_count + 1',
          'last_used': DateTime.now().toIso8601String(),
        },
        where: 'id = ?',
        whereArgs: [results[0]['id']],
      );
    }

    final qaList = results.map((row) => QAModel.fromMap(row)).toList();
    
    // Mettre en cache
    _cache[cacheKey] = qaList;
    _cacheTimestamps[cacheKey] = DateTime.now();
    
    return qaList;
  }

  bool _isCacheValid(String key) {
    if (!_cache.containsKey(key)) return false;
    final timestamp = _cacheTimestamps[key];
    if (timestamp == null) return false;
    return DateTime.now().difference(timestamp) < _cacheDuration;
  }

  void _clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
  }

  Future<void> insertInitialData() async {
    final db = await database;
    final count = Sqflite.firstIntValue(await db.rawQuery('SELECT COUNT(*) FROM qa_pairs'));
    
    if (count == 0) {
      final initialData = getInitialEcoQA();
      for (var qa in initialData) {
        await insertQA(qa);
      }
    }
  }

  Future<void> importFromJson(String jsonPath) async {
    try {
      // Lire le fichier JSON
      final String jsonString = await rootBundle.loadString(jsonPath);
      final List<dynamic> jsonData = json.decode(jsonString);
      
      // Convertir en QAModel et insérer dans la base de données
      for (var item in jsonData) {
        final qa = QAModel(
          question: item['question'],
          answer: item['answer'],
          keywords: List<String>.from(item['keywords']),
        );
        await insertQA(qa);
      }
    } catch (e) {
      print('Erreur lors de l\'import du fichier JSON: $e');
      rethrow;
    }
  }

  Future<void> exportToJson(String jsonPath) async {
    try {
      final List<QAModel> qaList = await getAllQA();
      final List<Map<String, dynamic>> jsonData = qaList.map((qa) => {
        'question': qa.question,
        'answer': qa.answer,
        'keywords': qa.keywords,
      }).toList();
      
      final String jsonString = json.encode(jsonData);
      // Note: L'écriture de fichiers nécessite des permissions supplémentaires
      // et dépend de la plateforme. Cette fonction est un exemple conceptuel.
    } catch (e) {
      print('Erreur lors de l\'export vers JSON: $e');
      rethrow;
    }
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete('qa_pairs');
  }

  Future<void> resetDatabase() async {
    await clearDatabase();
    await insertInitialData();
  }

  Future<void> deleteQA(int id) async {
    final db = await database;
    await db.delete(
      'qa_pairs',
      where: 'id = ?',
      whereArgs: [id],
    );
    
    // Mettre à jour les index
    _keywordIndex.clear();
    _categoryIndex.clear();
    final allQA = await getAllQA();
    for (var qa in allQA) {
      _updateIndexes(qa.id!, qa);
    }
    
    _clearCache();
  }

  Future<void> updateQA(int id, QAModel qa) async {
    final db = await database;
    await db.update(
      'qa_pairs',
      {
        'question': qa.question,
        'answer': qa.answer,
        'keywords': qa.keywords.join(','),
        'category': _determineCategory(qa.question),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
    
    // Mettre à jour les index
    _keywordIndex.clear();
    _categoryIndex.clear();
    final allQA = await getAllQA();
    for (var qa in allQA) {
      _updateIndexes(qa.id!, qa);
    }
    
    _clearCache();
  }

  Future<void> addQA(QAModel qa) async {
    final db = await database;
    final id = await db.insert('qa_pairs', {
      'question': qa.question,
      'answer': qa.answer,
      'keywords': qa.keywords.join(','),
      'category': _determineCategory(qa.question),
      'created_at': DateTime.now().toIso8601String(),
    });
    
    _updateIndexes(id, qa);
    _clearCache();
  }

  Future<List<QAModel>> getPopularQA({int limit = 10}) async {
    final cacheKey = 'popular:$limit';
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final db = await database;
    final results = await db.query(
      'qa_pairs',
      orderBy: 'usage_count DESC',
      limit: limit,
    );
    
    final qaList = results.map((row) => QAModel.fromMap(row)).toList();
    
    _cache[cacheKey] = qaList;
    _cacheTimestamps[cacheKey] = DateTime.now();
    
    return qaList;
  }

  Future<List<QAModel>> getRecentQA({int limit = 10}) async {
    final cacheKey = 'recent:$limit';
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final db = await database;
    final results = await db.query(
      'qa_pairs',
      orderBy: 'last_used DESC',
      limit: limit,
    );
    
    final qaList = results.map((row) => QAModel.fromMap(row)).toList();
    
    _cache[cacheKey] = qaList;
    _cacheTimestamps[cacheKey] = DateTime.now();
    
    return qaList;
  }

  Future<List<QAModel>> getQAByCategory(String category) async {
    final cacheKey = 'category:$category';
    if (_isCacheValid(cacheKey)) {
      return _cache[cacheKey]!;
    }

    final db = await database;
    final results = await db.query(
      'qa_pairs',
      where: 'category = ?',
      whereArgs: [category],
    );
    
    final qaList = results.map((row) => QAModel.fromMap(row)).toList();
    
    _cache[cacheKey] = qaList;
    _cacheTimestamps[cacheKey] = DateTime.now();
    
    return qaList;
  }

  Future<void> optimizeDatabase() async {
    final db = await database;
    await db.execute('VACUUM');
    await db.execute('ANALYZE');
  }

  Future<List<QAModel>> getPopularQuestions({int limit = 10}) async {
    // Cette méthode est un alias de getPopularQA pour compatibilité avec LocalChatbotService
    return await getPopularQA(limit: limit);
  }
} 