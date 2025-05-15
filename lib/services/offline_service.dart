import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:greens_app/services/storage_service.dart';
import 'package:greens_app/services/environmental_impact_service.dart';
import 'package:greens_app/models/environmental_impact_model.dart';

class OfflineService {
  static final OfflineService _instance = OfflineService._internal();
  final StorageService _storageService = StorageService();
  final EnvironmentalImpactService _impactService = EnvironmentalImpactService();
  
  // Singleton pattern
  factory OfflineService() {
    return _instance;
  }
  
  OfflineService._internal();
  
  // Clés pour le stockage local
  static const String _offlineDataKey = 'offline_data';
  static const String _pendingOperationsKey = 'pending_operations';
  static const String _lastSyncTimestampKey = 'last_sync_timestamp';
  
  // Cache des données
  Map<String, dynamic> _offlineCache = {};
  List<Map<String, dynamic>> _pendingOperations = [];
  DateTime? _lastSyncTimestamp;
  
  // Getters
  Map<String, dynamic> get offlineCache => _offlineCache;
  List<Map<String, dynamic>> get pendingOperations => _pendingOperations;
  DateTime? get lastSyncTimestamp => _lastSyncTimestamp;
  
  /// Initialise le service et charge les données en cache
  Future<void> initialize() async {
    await _loadOfflineData();
    await _loadPendingOperations();
    await _loadLastSyncTimestamp();
  }
  
  /// Charge les données en cache depuis le stockage local
  Future<void> _loadOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final offlineData = prefs.getString(_offlineDataKey);
      
      if (offlineData != null) {
        _offlineCache = jsonDecode(offlineData) as Map<String, dynamic>;
      }
    } catch (e) {
      print('Erreur lors du chargement des données hors-ligne: $e');
    }
  }
  
  /// Charge les opérations en attente
  Future<void> _loadPendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final pendingData = prefs.getString(_pendingOperationsKey);
      
      if (pendingData != null) {
        _pendingOperations = List<Map<String, dynamic>>.from(
          jsonDecode(pendingData) as List
        );
      }
    } catch (e) {
      print('Erreur lors du chargement des opérations en attente: $e');
    }
  }
  
  /// Charge le timestamp de la dernière synchronisation
  Future<void> _loadLastSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getString(_lastSyncTimestampKey);
      
      if (timestamp != null) {
        _lastSyncTimestamp = DateTime.parse(timestamp);
      }
    } catch (e) {
      print('Erreur lors du chargement du timestamp de synchronisation: $e');
    }
  }
  
  /// Sauvegarde les données en cache
  Future<void> _saveOfflineData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_offlineDataKey, jsonEncode(_offlineCache));
    } catch (e) {
      print('Erreur lors de la sauvegarde des données hors-ligne: $e');
    }
  }
  
  /// Sauvegarde les opérations en attente
  Future<void> _savePendingOperations() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingOperationsKey, jsonEncode(_pendingOperations));
    } catch (e) {
      print('Erreur lors de la sauvegarde des opérations en attente: $e');
    }
  }
  
  /// Sauvegarde le timestamp de synchronisation
  Future<void> _saveLastSyncTimestamp() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_lastSyncTimestampKey, DateTime.now().toIso8601String());
      _lastSyncTimestamp = DateTime.now();
    } catch (e) {
      print('Erreur lors de la sauvegarde du timestamp de synchronisation: $e');
    }
  }
  
  /// Vérifie la connectivité
  Future<bool> isOnline() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    return connectivityResult != ConnectivityResult.none;
  }
  
  /// Ajoute une opération à la file d'attente
  Future<void> queueOperation(String type, Map<String, dynamic> data) async {
    _pendingOperations.add({
      'type': type,
      'data': data,
      'timestamp': DateTime.now().toIso8601String(),
    });
    await _savePendingOperations();
  }
  
  /// Synchronise les données avec le serveur
  Future<void> sync() async {
    if (!await isOnline()) return;
    
    try {
      // Traiter les opérations en attente
      for (var operation in _pendingOperations) {
        await _processOperation(operation);
      }
      
      // Vider la file d'attente
      _pendingOperations.clear();
      await _savePendingOperations();
      
      // Mettre à jour le cache avec les données du serveur
      await _updateCache();
      
      // Sauvegarder le timestamp de synchronisation
      await _saveLastSyncTimestamp();
      
    } catch (e) {
      print('Erreur lors de la synchronisation: $e');
    }
  }
  
  /// Traite une opération en attente
  Future<void> _processOperation(Map<String, dynamic> operation) async {
    final type = operation['type'] as String;
    final data = operation['data'] as Map<String, dynamic>;
    
    switch (type) {
      case 'update_impact':
        await _impactService.updateUserImpact(
          data['userId'] as String,
          data['impact'] as EnvironmentalImpactModel,
        );
        break;
      // Ajouter d'autres types d'opérations ici
    }
  }
  
  /// Met à jour le cache avec les données du serveur
  Future<void> _updateCache() async {
    // Mettre à jour les données fréquemment utilisées
    // Par exemple, les statistiques d'impact, les objectifs, etc.
  }
  
  /// Récupère des données du cache
  Future<Map<String, dynamic>?> getCachedData(String key) async {
    return _offlineCache[key];
  }
  
  /// Met à jour des données dans le cache
  Future<void> updateCachedData(String key, Map<String, dynamic> data) async {
    _offlineCache[key] = data;
    await _saveOfflineData();
  }
  
  /// Efface toutes les données en cache
  Future<void> clearCache() async {
    _offlineCache.clear();
    _pendingOperations.clear();
    await _saveOfflineData();
    await _savePendingOperations();
  }
} 