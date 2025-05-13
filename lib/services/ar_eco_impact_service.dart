import 'dart:async';
import 'dart:convert';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:greens_app/models/product_scan_model.dart';
import 'package:greens_app/services/product_scan_service.dart';
import 'package:greens_app/services/environmental_impact_service.dart';
import 'package:uuid/uuid.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Modèle pour représenter un impact écologique visualisé en réalité augmentée
class AREnvironmentalImpact {
  final String id;
  final String label;
  final String description;
  final double value;
  final String unit;
  final String iconPath;
  final Color color;
  final String comparisonText;
  
  AREnvironmentalImpact({
    required this.id,
    required this.label,
    required this.description,
    required this.value,
    required this.unit,
    required this.iconPath,
    required this.color,
    required this.comparisonText,
  });
}

/// Modèle pour l'état actuel de la visualisation AR
class ARVisualizationState {
  final bool isEnabled;
  final bool isScanning;
  final List<AREnvironmentalImpact> impacts;
  final String? detectedProductName;
  final ProductScan? detectedProduct;
  final String? scanMessage;
  final double? overlayOpacity;
  
  ARVisualizationState({
    this.isEnabled = false,
    this.isScanning = false,
    this.impacts = const [],
    this.detectedProductName,
    this.detectedProduct,
    this.scanMessage,
    this.overlayOpacity = 0.8,
  });
  
  ARVisualizationState copyWith({
    bool? isEnabled,
    bool? isScanning,
    List<AREnvironmentalImpact>? impacts,
    String? detectedProductName,
    ProductScan? detectedProduct,
    String? scanMessage,
    double? overlayOpacity,
  }) {
    return ARVisualizationState(
      isEnabled: isEnabled ?? this.isEnabled,
      isScanning: isScanning ?? this.isScanning,
      impacts: impacts ?? this.impacts,
      detectedProductName: detectedProductName ?? this.detectedProductName,
      detectedProduct: detectedProduct ?? this.detectedProduct,
      scanMessage: scanMessage ?? this.scanMessage,
      overlayOpacity: overlayOpacity ?? this.overlayOpacity,
    );
  }
}

/// Service pour visualiser les impacts écologiques en réalité augmentée
class AREnvironmentalImpactService extends ChangeNotifier {
  final ProductScanService _productScanService;
  final EnvironmentalImpactService? _environmentalImpactService;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();
  
  // État de la visualisation AR
  ARVisualizationState _visualizationState = ARVisualizationState();
  ARVisualizationState get visualizationState => _visualizationState;
  
  // Contrôleurs de caméra
  CameraController? _cameraController;
  CameraController? get cameraController => _cameraController;
  
  // Historique des scans AR
  List<Map<String, dynamic>> _scanHistory = [];
  List<Map<String, dynamic>> get scanHistory => _scanHistory;
  
  // Erreurs
  String? _error;
  String? get error => _error;
  
  // Paramètres de visualisation
  bool _showCarbonFootprint = true;
  bool _showWaterUsage = true;
  bool _showDeforestation = true;
  bool _showAlternatives = true;
  
  bool get showCarbonFootprint => _showCarbonFootprint;
  bool get showWaterUsage => _showWaterUsage;
  bool get showDeforestation => _showDeforestation;
  bool get showAlternatives => _showAlternatives;
  
  AREnvironmentalImpactService({
    required ProductScanService productScanService,
    EnvironmentalImpactService? environmentalImpactService,
  }) : 
    _productScanService = productScanService,
    _environmentalImpactService = environmentalImpactService {
    _loadSettings();
    _loadScanHistory();
  }
  
  /// Initialise la caméra pour la visualisation AR
  Future<bool> initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        _error = "Aucune caméra disponible";
        notifyListeners();
        return false;
      }
      
      // Utiliser la caméra arrière par défaut
      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      
      _cameraController = CameraController(
        camera,
        ResolutionPreset.high,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      
      await _cameraController!.initialize();
      
      _visualizationState = _visualizationState.copyWith(
        isEnabled: true,
        isScanning: false,
      );
      
      notifyListeners();
      return true;
    } catch (e) {
      _error = "Erreur lors de l'initialisation de la caméra: $e";
      notifyListeners();
      return false;
    }
  }
  
  /// Libère les ressources utilisées par la caméra
  Future<void> disposeCamera() async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
      _cameraController = null;
    }
    
    _visualizationState = _visualizationState.copyWith(
      isEnabled: false,
      isScanning: false,
    );
    
    notifyListeners();
  }
  
  /// Démarre l'analyse d'un produit
  Future<void> startScanning() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      _error = "La caméra n'est pas initialisée";
      notifyListeners();
      return;
    }
    
    _visualizationState = _visualizationState.copyWith(
      isScanning: true,
      scanMessage: "Pointez la caméra vers un produit...",
    );
    
    notifyListeners();
  }
  
  /// Simule la détection d'un code-barres (pour la démonstration)
  Future<void> simulateBarcodeScan(String barcode, String userId) async {
    try {
      _visualizationState = _visualizationState.copyWith(
        scanMessage: "Analyse du produit en cours...",
      );
      notifyListeners();
      
      // Simuler un délai pour l'analyse
      await Future.delayed(const Duration(seconds: 1));
      
      // Obtenir les informations du produit
      final product = await _productScanService.getProductInfo(barcode, userId);
      
      // Générer les impacts environnementaux pour la visualisation AR
      final impacts = _generateEnvironmentalImpacts(product);
      
      // Mettre à jour l'état de visualisation
      _visualizationState = _visualizationState.copyWith(
        detectedProductName: product.productName,
        detectedProduct: product,
        impacts: impacts,
        scanMessage: "Produit détecté: ${product.productName}",
      );
      
      // Enregistrer le scan dans l'historique
      _addScanToHistory(product);
      
      notifyListeners();
    } catch (e) {
      _error = "Erreur lors de l'analyse du produit: $e";
      _visualizationState = _visualizationState.copyWith(
        scanMessage: "Erreur lors de l'analyse du produit",
      );
      notifyListeners();
    }
  }
  
  /// Arrête l'analyse
  void stopScanning() {
    _visualizationState = _visualizationState.copyWith(
      isScanning: false,
      scanMessage: null,
    );
    
    notifyListeners();
  }
  
  /// Efface les résultats d'analyse actuels
  void clearResults() {
    _visualizationState = _visualizationState.copyWith(
      impacts: [],
      detectedProductName: null,
      detectedProduct: null,
      scanMessage: null,
    );
    
    notifyListeners();
  }
  
  /// Génère des impacts environnementaux pour la visualisation AR
  List<AREnvironmentalImpact> _generateEnvironmentalImpacts(ProductScan product) {
    final impacts = <AREnvironmentalImpact>[];
    
    // Impact carbone
    if (_showCarbonFootprint) {
      impacts.add(AREnvironmentalImpact(
        id: _uuid.v4(),
        label: "Empreinte carbone",
        description: "Impact sur le changement climatique",
        value: product.carbonFootprint.toDouble(),
        unit: "kg CO₂",
        iconPath: "assets/icons/carbon_footprint.png",
        color: _getCarbonFootprintColor(product.carbonFootprint),
        comparisonText: "Équivalent à ${(product.carbonFootprint * 6).toStringAsFixed(1)} km en voiture",
      ));
    }
    
    // Impact eau
    if (_showWaterUsage) {
      final waterImpact = product.waterFootprint ?? 3;
      impacts.add(AREnvironmentalImpact(
        id: _uuid.v4(),
        label: "Consommation d'eau",
        description: "Quantité d'eau utilisée pour la production",
        value: waterImpact * 100.0, // Conversion vers litres
        unit: "L",
        iconPath: "assets/icons/water_usage.png",
        color: _getWaterUsageColor(waterImpact),
        comparisonText: "Équivalent à ${(waterImpact * 0.8).toStringAsFixed(1)} douches",
      ));
    }
    
    // Impact déforestation
    if (_showDeforestation) {
      final deforestationImpact = product.deforestationImpact ?? 2;
      impacts.add(AREnvironmentalImpact(
        id: _uuid.v4(),
        label: "Impact sur la forêt",
        description: "Contribution à la déforestation",
        value: deforestationImpact.toDouble(),
        unit: "m²",
        iconPath: "assets/icons/deforestation.png",
        color: _getDeforestationColor(deforestationImpact),
        comparisonText: "Équivalent à ${deforestationImpact * 0.25} arbres",
      ));
    }
    
    return impacts;
  }
  
  /// Détermine la couleur de l'impact carbone en fonction de sa valeur
  Color _getCarbonFootprintColor(int value) {
    if (value <= 2) return Colors.green;
    if (value <= 3) return Colors.lightGreen;
    if (value <= 4) return Colors.amber;
    return Colors.red;
  }
  
  /// Détermine la couleur de l'impact eau en fonction de sa valeur
  Color _getWaterUsageColor(int value) {
    if (value <= 2) return Colors.blue;
    if (value <= 3) return Colors.lightBlue;
    if (value <= 4) return Colors.orange;
    return Colors.red;
  }
  
  /// Détermine la couleur de l'impact déforestation en fonction de sa valeur
  Color _getDeforestationColor(int value) {
    if (value <= 2) return Colors.green;
    if (value <= 3) return Colors.lightGreen;
    if (value <= 4) return Colors.orange;
    return Colors.red;
  }
  
  /// Ajoute un scan à l'historique
  void _addScanToHistory(ProductScan product) {
    final scanData = {
      'id': _uuid.v4(),
      'productName': product.productName,
      'barcode': product.barcode,
      'ecoScore': product.ecoScore,
      'scanDate': DateTime.now().toIso8601String(),
      'impacts': _visualizationState.impacts.map((impact) => {
        'label': impact.label,
        'value': impact.value,
        'unit': impact.unit,
      }).toList(),
    };
    
    _scanHistory.insert(0, scanData);
    if (_scanHistory.length > 20) {
      _scanHistory = _scanHistory.sublist(0, 20);
    }
    
    _saveScanHistory();
  }
  
  /// Enregistre un impact environnemental pour l'utilisateur
  Future<void> saveEnvironmentalImpact(String userId, String productName, double carbonImpact) async {
    if (_environmentalImpactService != null) {
      try {
        await _environmentalImpactService!.addEnvironmentalImpact(
          userId, 
          carbonImpact, 
          'product_scan'
        );
        
        // Enregistrer l'action dans Firestore
        await _firestore.collection('user_actions').add({
          'userId': userId,
          'action': 'product_scan',
          'productName': productName,
          'carbonImpact': carbonImpact,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } catch (e) {
        print('Erreur lors de l\'enregistrement de l\'impact environnemental: $e');
      }
    }
  }
  
  /// Met à jour les paramètres de visualisation
  void updateVisualizationSettings({
    bool? showCarbonFootprint,
    bool? showWaterUsage,
    bool? showDeforestation,
    bool? showAlternatives,
    double? overlayOpacity,
  }) {
    if (showCarbonFootprint != null) _showCarbonFootprint = showCarbonFootprint;
    if (showWaterUsage != null) _showWaterUsage = showWaterUsage;
    if (showDeforestation != null) _showDeforestation = showDeforestation;
    if (showAlternatives != null) _showAlternatives = showAlternatives;
    
    // Mettre à jour l'opacité de la superposition AR
    if (overlayOpacity != null) {
      _visualizationState = _visualizationState.copyWith(
        overlayOpacity: overlayOpacity,
      );
    }
    
    // Si un produit est détecté, régénérer les impacts
    if (_visualizationState.detectedProduct != null) {
      final impacts = _generateEnvironmentalImpacts(_visualizationState.detectedProduct!);
      _visualizationState = _visualizationState.copyWith(impacts: impacts);
    }
    
    _saveSettings();
    notifyListeners();
  }
  
  /// Charge les paramètres de visualisation depuis les préférences
  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      _showCarbonFootprint = prefs.getBool('ar_show_carbon_footprint') ?? true;
      _showWaterUsage = prefs.getBool('ar_show_water_usage') ?? true;
      _showDeforestation = prefs.getBool('ar_show_deforestation') ?? true;
      _showAlternatives = prefs.getBool('ar_show_alternatives') ?? true;
      
      final overlayOpacity = prefs.getDouble('ar_overlay_opacity') ?? 0.8;
      _visualizationState = _visualizationState.copyWith(overlayOpacity: overlayOpacity);
      
      notifyListeners();
    } catch (e) {
      print('Erreur lors du chargement des paramètres AR: $e');
    }
  }
  
  /// Enregistre les paramètres de visualisation dans les préférences
  Future<void> _saveSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      await prefs.setBool('ar_show_carbon_footprint', _showCarbonFootprint);
      await prefs.setBool('ar_show_water_usage', _showWaterUsage);
      await prefs.setBool('ar_show_deforestation', _showDeforestation);
      await prefs.setBool('ar_show_alternatives', _showAlternatives);
      await prefs.setDouble('ar_overlay_opacity', _visualizationState.overlayOpacity ?? 0.8);
    } catch (e) {
      print('Erreur lors de l\'enregistrement des paramètres AR: $e');
    }
  }
  
  /// Charge l'historique des scans depuis les préférences
  Future<void> _loadScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getString('ar_scan_history');
      
      if (historyJson != null) {
        final List<dynamic> data = await jsonDecode(historyJson);
        _scanHistory = data.map((item) => Map<String, dynamic>.from(item)).toList();
      }
    } catch (e) {
      print('Erreur lors du chargement de l\'historique des scans AR: $e');
      _scanHistory = [];
    }
  }
  
  /// Enregistre l'historique des scans dans les préférences
  Future<void> _saveScanHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = jsonEncode(_scanHistory);
      await prefs.setString('ar_scan_history', historyJson);
    } catch (e) {
      print('Erreur lors de l\'enregistrement de l\'historique des scans AR: $e');
    }
  }
  
  /// Efface l'historique des scans
  Future<void> clearScanHistory() async {
    _scanHistory = [];
    await _saveScanHistory();
    notifyListeners();
  }
} 