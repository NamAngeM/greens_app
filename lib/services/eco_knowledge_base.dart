import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:uuid/uuid.dart';

/// Classe représentant un document dans la base de connaissances
class EcoDocument {
  final String id;
  final String title;
  final String content;
  final String category;
  final Map<String, dynamic>? metadata;

  EcoDocument({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'category': category,
      'metadata': metadata != null ? jsonEncode(metadata) : null,
    };
  }

  factory EcoDocument.fromMap(Map<String, dynamic> map) {
    return EcoDocument(
      id: map['id'],
      title: map['title'],
      content: map['content'],
      category: map['category'],
      metadata: map['metadata'] != null ? jsonDecode(map['metadata']) : null,
    );
  }
}

/// Service de gestion de la base de connaissances écologiques
class EcoKnowledgeBase {
  static const String dbName = 'eco_knowledge.db';
  static const String tableName = 'documents';

  Database? _database;
  final _uuid = Uuid();

  /// Obtenir une instance de la base de données
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialiser la base de données
  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, dbName);
    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDb,
    );
  }

  /// Créer la structure de la base de données
  Future<void> _createDb(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $tableName(
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        content TEXT NOT NULL,
        category TEXT NOT NULL,
        metadata TEXT,
        ts_title TEXT GENERATED ALWAYS AS (title) STORED,
        ts_content TEXT GENERATED ALWAYS AS (content) STORED
      )
    ''');
    
    // Créer un index de recherche en texte intégral
    await db.execute(
      'CREATE VIRTUAL TABLE IF NOT EXISTS documents_fts USING fts5(title, content, content=documents, content_rowid=rowid)'
    );
    
    // Créer les triggers pour maintenir l'index FTS à jour
    await db.execute('''
      CREATE TRIGGER documents_ai AFTER INSERT ON documents BEGIN
        INSERT INTO documents_fts(rowid, title, content) VALUES (new.rowid, new.title, new.content);
      END;
    ''');
    
    await db.execute('''
      CREATE TRIGGER documents_ad AFTER DELETE ON documents BEGIN
        INSERT INTO documents_fts(documents_fts, rowid, title, content) VALUES('delete', old.rowid, old.title, old.content);
      END;
    ''');
    
    await db.execute('''
      CREATE TRIGGER documents_au AFTER UPDATE ON documents BEGIN
        INSERT INTO documents_fts(documents_fts, rowid, title, content) VALUES('delete', old.rowid, old.title, old.content);
        INSERT INTO documents_fts(rowid, title, content) VALUES (new.rowid, new.title, new.content);
      END;
    ''');
  }

  /// Ajouter un document à la base de connaissances
  Future<String> addDocument({
    required String title,
    required String content,
    required String category,
    Map<String, dynamic>? metadata,
  }) async {
    final db = await database;
    final id = _uuid.v4();
    
    final document = EcoDocument(
      id: id,
      title: title,
      content: content,
      category: category,
      metadata: metadata,
    );
    
    await db.insert(
      tableName,
      document.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    
    return id;
  }

  /// Rechercher des documents par mots-clés
  Future<List<EcoDocument>> search(String query) async {
    final db = await database;
    
    // Recherche dans FTS
    final results = await db.rawQuery('''
      SELECT d.* FROM $tableName d
      JOIN documents_fts fts ON d.rowid = fts.rowid
      WHERE documents_fts MATCH ?
      ORDER BY rank
      LIMIT 5
    ''', [query]);
    
    // Si pas de résultats avec FTS, essayer une recherche LIKE
    if (results.isEmpty) {
      final likeQuery = '%${query.toLowerCase()}%';
      final secondaryResults = await db.query(
        tableName,
        where: 'LOWER(title) LIKE ? OR LOWER(content) LIKE ?',
        whereArgs: [likeQuery, likeQuery],
        limit: 5,
      );
      
      return secondaryResults.map((map) => EcoDocument.fromMap(map)).toList();
    }
    
    return results.map((map) => EcoDocument.fromMap(map)).toList();
  }

  /// Charger des documents prédéfinis dans la base de connaissances
  Future<void> loadPredefinedDocuments() async {
    final db = await database;
    
    // Vérifier si des documents existent déjà
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM $tableName')
    );
    
    if (count != null && count > 0) return;
    
    // Charger et ajouter les données d'exemple
    final String jsonData = await rootBundle.loadString('assets/data/eco_knowledge.json');
    final List<dynamic> documents = jsonDecode(jsonData);
    
    for (var docData in documents) {
      await addDocument(
        title: docData['title'],
        content: docData['content'],
        category: docData['category'],
        metadata: docData['metadata'],
      );
    }
  }

  /// Obtenir un document par son ID
  Future<EcoDocument?> getDocumentById(String id) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    
    if (maps.isEmpty) return null;
    return EcoDocument.fromMap(maps.first);
  }

  /// Supprimer un document
  Future<void> deleteDocument(String id) async {
    final db = await database;
    await db.delete(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Obtenir tous les documents d'une catégorie
  Future<List<EcoDocument>> getDocumentsByCategory(String category) async {
    final db = await database;
    final maps = await db.query(
      tableName,
      where: 'category = ?',
      whereArgs: [category],
    );
    
    return maps.map((map) => EcoDocument.fromMap(map)).toList();
  }
} 