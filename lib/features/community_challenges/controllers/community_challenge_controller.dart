import 'package:flutter/material.dart';
import '../models/community_challenge_model.dart';

class Challenge {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final DateTime startDate;
  final DateTime endDate;
  final int participants;
  final bool isJoined;
  final List<String> rewards;
  final int totalCarbonSaved;
  final List<Participant> topParticipants;

  Challenge({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.startDate,
    required this.endDate,
    required this.participants,
    this.isJoined = false,
    required this.rewards,
    required this.totalCarbonSaved,
    required this.topParticipants,
  });
}

class Participant {
  final String id;
  final String name;
  final String avatarUrl;
  final int points;
  final int rank;

  Participant({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.points,
    required this.rank,
  });
}

class CommunityChallengeController extends ChangeNotifier {
  List<Challenge> _challenges = [];
  List<Challenge> _myJoinedChallenges = [];
  List<Challenge> _filteredChallenges = [];
  List<CommunityChallenge> _availableChallenges = [];
  List<CommunityChallenge> _userChallenges = [];
  Challenge? _selectedChallenge;
  bool _isLoading = false;
  String? _errorMessage;

  List<Challenge> get challenges => _filteredChallenges;
  List<Challenge> get myJoinedChallenges => _myJoinedChallenges;
  List<CommunityChallenge> get availableChallenges => _availableChallenges;
  List<CommunityChallenge> get userChallenges => _userChallenges;
  Challenge? get selectedChallenge => _selectedChallenge;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Méthode pour charger tous les défis
  Future<void> loadChallenges() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 1));
      
      // Créer des défis factices
      _challenges = [
        Challenge(
          id: 'challenge-1',
          title: 'Une semaine sans déchets plastiques',
          description: 'Relevez le défi de ne générer aucun déchet plastique pendant une semaine complète. Partagez vos astuces et vos alternatives pour inspirer la communauté.',
          imageUrl: 'assets/images/challenges/plastic_free.jpg',
          startDate: DateTime.now().subtract(const Duration(days: 3)),
          endDate: DateTime.now().add(const Duration(days: 4)),
          participants: 283,
          isJoined: true,
          rewards: ['Badge "Zéro Plastique"', '50 points éco', 'Accès à des ateliers exclusifs'],
          totalCarbonSaved: 3650,
          topParticipants: [
            Participant(
              id: 'user-1',
              name: 'Laura M.',
              avatarUrl: 'assets/images/avatars/avatar1.png',
              points: 85,
              rank: 1,
            ),
            Participant(
              id: 'user-2',
              name: 'Thomas L.',
              avatarUrl: 'assets/images/avatars/avatar2.png',
              points: 72,
              rank: 2,
            ),
            Participant(
              id: 'user-3',
              name: 'Emma D.',
              avatarUrl: 'assets/images/avatars/avatar3.png',
              points: 68,
              rank: 3,
            ),
          ],
        ),
        Challenge(
          id: 'challenge-2',
          title: 'Mobilité verte pendant 30 jours',
          description: 'Utilisez uniquement des moyens de transport écologiques pendant 30 jours : marche, vélo, transports en commun, covoiturage...',
          imageUrl: 'assets/images/challenges/green_mobility.jpg',
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          participants: 427,
          isJoined: false,
          rewards: ['Badge "Mobilité Verte"', '75 points éco', 'Réduction sur un service de location de vélo'],
          totalCarbonSaved: 7250,
          topParticipants: [
            Participant(
              id: 'user-4',
              name: 'Julien B.',
              avatarUrl: 'assets/images/avatars/avatar4.png',
              points: 92,
              rank: 1,
            ),
            Participant(
              id: 'user-5',
              name: 'Sarah K.',
              avatarUrl: 'assets/images/avatars/avatar5.png',
              points: 86,
              rank: 2,
            ),
            Participant(
              id: 'user-6',
              name: 'Marc T.',
              avatarUrl: 'assets/images/avatars/avatar6.png',
              points: 77,
              rank: 3,
            ),
          ],
        ),
        Challenge(
          id: 'challenge-3',
          title: 'Alimentation locale et de saison',
          description: 'Consommez uniquement des produits locaux et de saison pendant deux semaines pour réduire l\'impact environnemental de votre alimentation.',
          imageUrl: 'assets/images/challenges/local_food.jpg',
          startDate: DateTime.now().add(const Duration(days: 7)),
          endDate: DateTime.now().add(const Duration(days: 21)),
          participants: 158,
          isJoined: false,
          rewards: ['Badge "Locavore"', '60 points éco', 'Panier de produits locaux'],
          totalCarbonSaved: 0, // Défi pas encore commencé
          topParticipants: [],
        ),
      ];
      
      // Créer des défis pour le modèle CommunityChallenge
      _availableChallenges = [
        CommunityChallenge(
          id: 'challenge-1',
          title: 'Une semaine sans déchets plastiques',
          description: 'Relevez le défi de ne générer aucun déchet plastique pendant une semaine complète.',
          category: 'Déchets',
          difficulty: 3,
          startDate: DateTime.now().subtract(const Duration(days: 3)),
          endDate: DateTime.now().add(const Duration(days: 4)),
          participantsCount: 283,
          points: 50,
          tasks: ['Utiliser des sacs réutilisables', 'Éviter les emballages plastiques'],
          createdBy: 'admin',
          imageUrl: 'assets/images/challenges/plastic_free.jpg',
          joined: true,
        ),
        CommunityChallenge(
          id: 'challenge-2',
          title: 'Mobilité verte pendant 30 jours',
          description: 'Utilisez uniquement des moyens de transport écologiques pendant 30 jours.',
          category: 'Transport',
          difficulty: 4,
          startDate: DateTime.now().subtract(const Duration(days: 15)),
          endDate: DateTime.now().add(const Duration(days: 15)),
          participantsCount: 427,
          points: 75,
          tasks: ['Utiliser le vélo', 'Prendre les transports en commun'],
          createdBy: 'admin',
          imageUrl: 'assets/images/challenges/green_mobility.jpg',
        ),
      ];
      
      // Défis de l'utilisateur
      _userChallenges = [
        CommunityChallenge(
          id: 'challenge-1',
          title: 'Une semaine sans déchets plastiques',
          description: 'Relevez le défi de ne générer aucun déchet plastique pendant une semaine complète.',
          category: 'Déchets',
          difficulty: 3,
          startDate: DateTime.now().subtract(const Duration(days: 3)),
          endDate: DateTime.now().add(const Duration(days: 4)),
          participantsCount: 283,
          points: 50,
          tasks: ['Utiliser des sacs réutilisables', 'Éviter les emballages plastiques'],
          createdBy: 'admin',
          imageUrl: 'assets/images/challenges/plastic_free.jpg',
          joined: true,
          progress: 0.6,
          completedTasks: ['Utiliser des sacs réutilisables'],
        ),
      ];
      
      // Filtrer les défis rejoints
      _myJoinedChallenges = _challenges.where((challenge) => challenge.isJoined).toList();
      
      // Par défaut, montrer tous les défis
      _filteredChallenges = _challenges;
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des défis: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour sélectionner un défi
  void selectChallenge(String challengeId) {
    _selectedChallenge = _challenges.firstWhere((challenge) => challenge.id == challengeId);
    notifyListeners();
  }

  // Méthode pour rejoindre/quitter un défi
  Future<void> toggleJoinChallenge(String challengeId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 1));
      
      // Mettre à jour l'état du défi
      final index = _challenges.indexWhere((challenge) => challenge.id == challengeId);
      if (index >= 0) {
        final challenge = _challenges[index];
        final updatedChallenge = Challenge(
          id: challenge.id,
          title: challenge.title,
          description: challenge.description,
          imageUrl: challenge.imageUrl,
          startDate: challenge.startDate,
          endDate: challenge.endDate,
          participants: challenge.isJoined ? challenge.participants - 1 : challenge.participants + 1,
          isJoined: !challenge.isJoined,
          rewards: challenge.rewards,
          totalCarbonSaved: challenge.totalCarbonSaved,
          topParticipants: challenge.topParticipants,
        );
        
        _challenges[index] = updatedChallenge;
        
        // Mettre à jour les listes filtrées
        _myJoinedChallenges = _challenges.where((challenge) => challenge.isJoined).toList();
        
        if (_selectedChallenge?.id == challengeId) {
          _selectedChallenge = updatedChallenge;
        }
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'inscription au défi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthode pour filtrer les défis
  void filterChallenges(String query) {
    if (query.isEmpty) {
      _filteredChallenges = _challenges;
    } else {
      _filteredChallenges = _challenges.where((challenge) => 
        challenge.title.toLowerCase().contains(query.toLowerCase()) ||
        challenge.description.toLowerCase().contains(query.toLowerCase())
      ).toList();
    }
    notifyListeners();
  }
  
  // Méthode pour rejoindre un défi
  Future<void> joinChallenge(String challengeId) async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 1));
      
      // Mettre à jour l'état du défi dans availableChallenges
      final challengeIndex = _availableChallenges.indexWhere((challenge) => challenge.id == challengeId);
      if (challengeIndex >= 0) {
        final challenge = _availableChallenges[challengeIndex];
        final updatedChallenge = challenge.copyWith(
          joined: true,
          participantsCount: challenge.participantsCount + 1,
        );
        
        _availableChallenges[challengeIndex] = updatedChallenge;
        
        // Ajouter aux défis de l'utilisateur
        if (!_userChallenges.any((c) => c.id == challengeId)) {
          _userChallenges.add(updatedChallenge);
        }
      }
    } catch (e) {
      _errorMessage = 'Erreur lors de l\'inscription au défi: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Méthode pour charger les défis de l'utilisateur
  Future<void> loadUserChallenges() async {
    _isLoading = true;
    notifyListeners();
    
    try {
      // Simuler un délai réseau
      await Future.delayed(const Duration(seconds: 1));
      
      // Les défis de l'utilisateur sont déjà chargés dans loadChallenges()
      // Cette méthode pourrait réellement charger depuis une API dans un cas réel
      
    } catch (e) {
      _errorMessage = 'Erreur lors du chargement des défis de l\'utilisateur: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
} 