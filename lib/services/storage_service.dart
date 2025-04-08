// File: lib/services/storage_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service unifié pour gérer le stockage des données
/// Centralise l'accès à Firebase et SharedPreferences
class StorageService {
  static final StorageService _instance = StorageService._internal();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  SharedPreferences? _prefs;
  
  // Singleton pattern
  factory StorageService() {
    return _instance;
  }
  
  StorageService._internal() {
    _initPrefs();
  }
  
  Future<void> _initPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }
  
  // Méthodes pour SharedPreferences
  Future<bool> setBool(String key, bool value) async {
    if (_prefs == null) await _initPrefs();
    return await _prefs!.setBool(key, value);
  }
  
  bool? getBool(String key) {
    return _prefs?.getBool(key);
  }
  
  Future<bool> setString(String key, String value) async {
    if (_prefs == null) await _initPrefs();
    return await _prefs!.setString(key, value);
  }
  
  String? getString(String key) {
    return _prefs?.getString(key);
  }
  
  // Méthodes pour Firestore
  Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await _firestore.collection(collection).doc(docId).get();
  }
  
  Future<QuerySnapshot> getCollection(String collection, {
    String? field,
    dynamic isEqualTo,
    String? orderBy,
    bool descending = false,
  }) async {
    Query query = _firestore.collection(collection);
    
    if (field != null && isEqualTo != null) {
      query = query.where(field, isEqualTo: isEqualTo);
    }
    
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }
    
    return await query.get();
  }
  
  Future<DocumentReference> addDocument(String collection, Map<String, dynamic> data) async {
    return await _firestore.collection(collection).add(data);
  }
  
  Future<void> updateDocument(String collection, String docId, Map<String, dynamic> data) async {
    return await _firestore.collection(collection).doc(docId).update(data);
  }
  
  Future<void> deleteDocument(String collection, String docId) async {
    return await _firestore.collection(collection).doc(docId).delete();
  }
}
