import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:greens_app/models/eco_qa_model.dart';

class EcoQAService {
  static Database? _database;
  static const String tableName = 'eco_qa';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), 'greens_app.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        await db.execute('''
          CREATE TABLE $tableName(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            question TEXT NOT NULL,
            answer TEXT NOT NULL
          )
        ''');
      },
    );
  }

  Future<void> loadDataFromJson() async {
    try {
      // Lire le fichier JSON
      final String jsonString = await rootBundle.loadString('assets/ecologie.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Obtenir la liste des paires QA
      final List<dynamic> qaPairs = jsonData['qa_pairs'];
      
      // Insérer les données dans la base de données
      final db = await database;
      await db.transaction((txn) async {
        for (var qa in qaPairs) {
          await txn.insert(
            tableName,
            {
              'question': qa['question'],
              'answer': qa['answer'],
            },
            conflictAlgorithm: ConflictAlgorithm.replace,
          );
        }
      });
      
      print('Données écologiques chargées avec succès');
    } catch (e) {
      print('Erreur lors du chargement des données: $e');
      rethrow;
    }
  }

  Future<List<EcoQAModel>> getAllQA() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(tableName);
    return List.generate(maps.length, (i) => EcoQAModel.fromMap(maps[i]));
  }

  Future<EcoQAModel?> getQAById(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isNotEmpty) {
      return EcoQAModel.fromMap(maps.first);
    }
    return null;
  }

  Future<List<EcoQAModel>> searchQA(String query) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      tableName,
      where: 'question LIKE ? OR answer LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
    );
    return List.generate(maps.length, (i) => EcoQAModel.fromMap(maps[i]));
  }

  Future<void> clearDatabase() async {
    final db = await database;
    await db.delete(tableName);
  }
} 