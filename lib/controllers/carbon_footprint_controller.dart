import 'package:flutter/material.dart';
import 'package:greens_app/models/carbon_footprint_model.dart';
import 'package:greens_app/services/carbon_footprint_service.dart';
import 'package:greens_app/services/digital_carbon_service.dart';

class CarbonFootprintController extends ChangeNotifier {
  final CarbonFootprintService _carbonFootprintService = CarbonFootprintService();
  final DigitalCarbonService _digitalCarbonService = DigitalCarbonService();
  List<CarbonFootprintModel> _userFootprints = [];
  CarbonFootprintModel? _currentFootprint;
  bool _isLoading = false;
  String? _errorMessage;

  List<CarbonFootprintModel> get userFootprints => _userFootprints;
  CarbonFootprintModel? get currentFootprint => _currentFootprint;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Récupérer l'historique des empreintes carbone d'un utilisateur
  Future<void> getUserFootprintHistory(String userId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _userFootprints = await _carbonFootprintService.getUserFootprintHistory(userId);
    } catch (e) {
      _errorMessage = 'Erreur lors de la récupération de l\'historique: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculer l'empreinte carbone numérique
  Future<double> calculateDigitalFootprint({
    // Streaming
    required double hoursVideoSD,
    required double hoursVideoHD,
    required double hoursVideo4K,
    required double hoursMusic,
    required double hoursVideoCalls,
    
    // Emails
    required int emailsSimple,
    required int emailsWithAttachment,
    required int spamEmails,
    
    // Stockage
    required double cloudStorageGB,
    required int photosStored,
    required int videoMinutesStored,
    
    // Utilisation des appareils
    required double hoursSmartphone,
    required double hoursLaptop,
    required double hoursTablet,
    required double hoursDesktop,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Calculer les émissions par catégorie
      final streamingEmissions = _digitalCarbonService.calculateStreamingEmissions(
        hoursVideoSD: hoursVideoSD,
        hoursVideoHD: hoursVideoHD,
        hoursVideo4K: hoursVideo4K,
        hoursMusic: hoursMusic,
        hoursVideoCalls: hoursVideoCalls,
      );
      
      final emailEmissions = _digitalCarbonService.calculateEmailEmissions(
        emailsSimple: emailsSimple,
        emailsWithAttachment: emailsWithAttachment,
        spamEmails: spamEmails,
      );
      
      final storageEmissions = _digitalCarbonService.calculateStorageEmissions(
        cloudStorageGB: cloudStorageGB,
        photosStored: photosStored,
        videoMinutesStored: videoMinutesStored,
      );
      
      final deviceEmissions = _digitalCarbonService.calculateDeviceUsageEmissions(
        hoursSmartphone: hoursSmartphone,
        hoursLaptop: hoursLaptop,
        hoursTablet: hoursTablet,
        hoursDesktop: hoursDesktop,
      );
      
      // Calculer le score total en kg CO2e
      final digitalScore = _digitalCarbonService.calculateTotalDigitalFootprint(
        hoursVideoSD: hoursVideoSD,
        hoursVideoHD: hoursVideoHD,
        hoursVideo4K: hoursVideo4K,
        hoursMusic: hoursMusic,
        hoursVideoCalls: hoursVideoCalls,
        emailsSimple: emailsSimple,
        emailsWithAttachment: emailsWithAttachment,
        spamEmails: spamEmails,
        cloudStorageGB: cloudStorageGB,
        photosStored: photosStored,
        videoMinutesStored: videoMinutesStored,
        hoursSmartphone: hoursSmartphone,
        hoursLaptop: hoursLaptop,
        hoursTablet: hoursTablet,
        hoursDesktop: hoursDesktop,
      );
      
      // Générer des recommandations spécifiques
      final digitalRecommendations = _digitalCarbonService.generateDigitalRecommendations(
        streamingEmissions: streamingEmissions,
        emailEmissions: emailEmissions,
        storageEmissions: storageEmissions,
        deviceEmissions: deviceEmissions,
      );
      
      // Si nous avons déjà un calcul d'empreinte carbone en cours, mettre à jour avec les données numériques
      if (_currentFootprint != null) {
        // Créer un nouveau dictionnaire de détails qui inclut les détails numériques
        final Map<String, dynamic> updatedDetails = Map.from(_currentFootprint!.details ?? {});
        updatedDetails['digital'] = {
          'streamingEmissions': streamingEmissions,
          'emailEmissions': emailEmissions,
          'storageEmissions': storageEmissions,
          'deviceEmissions': deviceEmissions,
          'recommendations': digitalRecommendations,
        };
        
        // Mettre à jour l'empreinte carbone actuelle
        _currentFootprint = _currentFootprint!.copyWith(
          digitalScore: digitalScore,
          totalScore: (_currentFootprint!.totalScore - (_currentFootprint!.digitalScore ?? 0)) + digitalScore,
          details: updatedDetails,
        );
        
        notifyListeners();
      }
      
      return digitalScore;
    } catch (e) {
      _errorMessage = 'Erreur lors du calcul de l\'empreinte numérique: $e';
      return 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Calculer l'empreinte carbone
  Future<bool> calculateCarbonFootprint({
    required double transportScore,
    required double energyScore,
    required double foodScore,
    required double consumptionScore,
    double digitalScore = 0.0, // Nouveau paramètre avec valeur par défaut
    required Map<String, dynamic> details,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Calculer l'empreinte carbone avec le service
      _currentFootprint = await _carbonFootprintService.calculateCarbonFootprint(
        transportScore: transportScore,
        energyScore: energyScore,
        foodScore: foodScore,
        consumptionScore: consumptionScore,
        digitalScore: digitalScore, // Ajouter le score numérique
        details: details,
      );
      
      // Ajouter l'empreinte calculée à l'historique
      if (_currentFootprint != null) {
        _userFootprints.insert(0, _currentFootprint!);
      }
      
      return _currentFootprint != null;
    } catch (e) {
      _errorMessage = 'Erreur lors du calcul de l\'empreinte carbone: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sauvegarder l'empreinte carbone
  Future<bool> saveCarbonFootprint(double totalScore) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (_currentFootprint == null) {
        // Si aucune empreinte n'est calculée, créer une empreinte basique
        _currentFootprint = CarbonFootprintModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          userId: '', // Sera rempli par le service
          date: DateTime.now(),
          totalScore: totalScore,
          transportScore: 0,
          energyScore: 0,
          foodScore: 0,
          consumptionScore: 0,
          digitalScore: 0, // Ajout du score numérique
          details: {},
          recommendations: [],
          pointsEarned: (100 - totalScore).round(), // Points inversement proportionnels à l'empreinte
        );
      }
      
      final success = await _carbonFootprintService.saveFootprint(_currentFootprint!);
      
      if (success && !_userFootprints.contains(_currentFootprint)) {
        _userFootprints.insert(0, _currentFootprint!);
      }
      
      return success;
    } catch (e) {
      _errorMessage = 'Erreur lors de la sauvegarde de l\'empreinte carbone: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Obtenir des recommandations basées sur la dernière empreinte carbone
  List<String> getRecommendations() {
    if (_currentFootprint == null || _currentFootprint!.recommendations == null) {
      return [];
    }
    
    return _currentFootprint!.recommendations!;
  }

  // Obtenir les recommandations spécifiques à l'empreinte numérique
  List<String> getDigitalRecommendations() {
    if (_currentFootprint == null || _currentFootprint!.details == null) {
      return [];
    }
    
    final details = _currentFootprint!.details!;
    if (!details.containsKey('digital') || 
        !details['digital'].containsKey('recommendations')) {
      return [];
    }
    
    return List<String>.from(details['digital']['recommendations']);
  }

  // Obtenir les points gagnés lors du dernier calcul
  int getPointsEarned() {
    if (_currentFootprint == null) {
      return 0;
    }
    
    return _currentFootprint!.pointsEarned;
  }

  // Obtenir la répartition des émissions numériques par catégorie
  Map<String, double> getDigitalEmissionsBreakdown() {
    if (_currentFootprint == null || _currentFootprint!.details == null) {
      return {};
    }
    
    final details = _currentFootprint!.details!;
    if (!details.containsKey('digital')) {
      return {};
    }
    
    final digital = details['digital'] as Map<String, dynamic>;
    
    return {
      'streaming': digital['streamingEmissions'] as double? ?? 0.0,
      'email': digital['emailEmissions'] as double? ?? 0.0,
      'storage': digital['storageEmissions'] as double? ?? 0.0,
      'devices': digital['deviceEmissions'] as double? ?? 0.0,
    };
  }

  // Calculer l'équivalence de l'empreinte numérique en termes concrets
  String getDigitalFootprintEquivalent() {
    if (_currentFootprint == null) {
      return "Équivalence non disponible";
    }
    
    final digitalScore = _currentFootprint!.digitalScore;
    
    if (digitalScore < 1) {
      return "${(digitalScore * 5).toStringAsFixed(1)} km en voiture";
    } else if (digitalScore < 5) {
      return "${(digitalScore * 3).toStringAsFixed(1)} km en voiture";
    } else if (digitalScore < 20) {
      return "${(digitalScore / 5).toStringAsFixed(1)} jours de chauffage d'une maison";
    } else {
      return "${(digitalScore / 100).toStringAsFixed(2)} vols Paris-Londres";
    }
  }

  // Comparer l'empreinte numérique avec la moyenne nationale
  double getDigitalFootprintComparedToAverage() {
    if (_currentFootprint == null) {
      return 0.0;
    }
    
    // La moyenne nationale d'empreinte numérique est d'environ 200 kg CO2e par an
    // soit environ 0.55 kg CO2e par jour
    const double averageDailyDigitalFootprint = 0.55;
    
    return _currentFootprint!.digitalScore / averageDailyDigitalFootprint;
  }
}
