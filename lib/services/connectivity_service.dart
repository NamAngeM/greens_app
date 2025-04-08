import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectivityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final StreamController<bool> _connectionStatusController = StreamController<bool>.broadcast();
  
  Stream<bool> get connectionStatus => _connectionStatusController.stream;
  bool _isConnected = true;
  Timer? _periodicCheck;
  
  ConnectivityService() {
    // Initialiser l'état de connexion
    checkConnection();
    
    // Vérifier périodiquement la connexion
    _periodicCheck = Timer.periodic(const Duration(minutes: 2), (timer) {
      checkConnection();
    });
  }
  
  /// Vérifier si l'appareil est connecté à Internet et peut accéder à Firebase
  Future<bool> checkConnection() async {
    bool wasConnected = _isConnected;
    
    try {
      // Utiliser une requête légère pour vérifier la connectivité
      await _firestore.collection('connectivity_check')
          .doc('ping')
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 5));
      
      _isConnected = true;
    } catch (e) {
      _isConnected = false;
      debugPrint('Connectivité perdue: $e');
    }
    
    // Notifier seulement si l'état a changé
    if (wasConnected != _isConnected) {
      _connectionStatusController.add(_isConnected);
    }
    
    return _isConnected;
  }
  
  /// Tenter de se reconnecter et synchroniser les données
  Future<bool> attemptReconnect() async {
    return await checkConnection();
  }
  
  /// Fermer le service proprement
  void dispose() {
    _periodicCheck?.cancel();
    _connectionStatusController.close();
  }
} 