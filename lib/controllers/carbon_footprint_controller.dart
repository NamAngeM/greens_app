import 'package:flutter/material.dart';
import 'package:greens_app/models/carbon_footprint_model.dart';
import 'package:greens_app/services/carbon_footprint_service.dart';

class CarbonFootprintController extends ChangeNotifier {
  final CarbonFootprintService _carbonFootprintService = CarbonFootprintService();
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

  // Calculer l'empreinte carbone
  Future<bool> calculateCarbonFootprint({
    required double transportScore,
    required double energyScore,
    required double foodScore,
    required double consumptionScore,
    required Map<String, dynamic> details,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentFootprint = await _carbonFootprintService.calculateCarbonFootprint(
        transportScore: transportScore,
        energyScore: energyScore,
        foodScore: foodScore,
        consumptionScore: consumptionScore,
        details: details,
      );
      
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

  // Obtenir les points gagnés lors du dernier calcul
  int getPointsEarned() {
    if (_currentFootprint == null) {
      return 0;
    }
    
    return _currentFootprint!.pointsEarned;
  }
}
