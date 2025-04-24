import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/quick_impact_action_model.dart';

class QuickImpactActionsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final CollectionReference _actionsCollection;
  final CollectionReference _completedActionsCollection;
  final CollectionReference _userStatsCollection;

  QuickImpactActionsService() 
      : _actionsCollection = FirebaseFirestore.instance.collection('quick_impact_actions'),
        _completedActionsCollection = FirebaseFirestore.instance.collection('completed_actions'),
        _userStatsCollection = FirebaseFirestore.instance.collection('user_stats');

  // Récupérer toutes les actions disponibles
  Future<List<QuickImpactActionModel>> getAllActions() async {
    try {
      final snapshot = await _actionsCollection.get();
      return snapshot.docs
          .map((doc) => QuickImpactActionModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des actions: $e');
      return [];
    }
  }

  // Récupérer les actions par catégorie
  Future<List<QuickImpactActionModel>> getActionsByCategory(ActionCategory category) async {
    try {
      final snapshot = await _actionsCollection
          .where('category', isEqualTo: category.name)
          .get();
      
      return snapshot.docs
          .map((doc) => QuickImpactActionModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des actions par catégorie: $e');
      return [];
    }
  }

  // Récupérer les actions par niveau de difficulté
  Future<List<QuickImpactActionModel>> getActionsByDifficulty(ActionDifficulty difficulty) async {
    try {
      final snapshot = await _actionsCollection
          .where('difficulty', isEqualTo: difficulty.name)
          .get();
      
      return snapshot.docs
          .map((doc) => QuickImpactActionModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération des actions par difficulté: $e');
      return [];
    }
  }

  // Récupérer des actions recommandées pour l'utilisateur
  Future<List<QuickImpactActionModel>> getRecommendedActionsForUser(String userId, {int limit = 5}) async {
    try {
      // Récupérer l'historique des actions de l'utilisateur
      final completedActionsSnapshot = await _completedActionsCollection
          .where('userId', isEqualTo: userId)
          .get();
      
      final completedActions = completedActionsSnapshot.docs
          .map((doc) => CompletedActionModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
      
      // Obtenir toutes les actions disponibles
      final allActions = await getAllActions();
      
      // Filtrer les actions selon les critères suivants:
      // 1. Si l'action est non récurrente, ne pas la recommander si elle a déjà été réalisée
      // 2. Si l'action est récurrente, vérifier si la période entre deux réalisations est respectée
      final DateTime now = DateTime.now();
      final filteredActions = allActions.where((action) {
        // Vérifier si l'action a déjà été réalisée
        final completedAction = completedActions
            .where((completed) => completed.actionId == action.id)
            .toList();
        
        // Si l'action n'a jamais été réalisée, elle peut être recommandée
        if (completedAction.isEmpty) {
          return true;
        }
        
        // Si l'action n'est pas récurrente et a déjà été réalisée, ne pas la recommander
        if (!action.isRecurring) {
          return false;
        }
        
        // Si l'action est récurrente, vérifier la période entre deux réalisations
        completedAction.sort((a, b) => b.completedDate.compareTo(a.completedDate));
        final lastCompletedDate = completedAction.first.completedDate;
        final daysSinceLastCompletion = now.difference(lastCompletedDate).inDays;
        
        return daysSinceLastCompletion >= action.frequencyLimitInDays;
      }).toList();
      
      // Trier les actions par pertinence (ici par nombre de points)
      filteredActions.sort((a, b) => b.rewardPoints.compareTo(a.rewardPoints));
      
      // Retourner les actions recommandées (limitées au nombre spécifié)
      return filteredActions.take(limit).toList();
    } catch (e) {
      print('Erreur lors de la récupération des actions recommandées: $e');
      return [];
    }
  }

  // Marquer une action comme complétée
  Future<bool> completeAction(String userId, String actionId, {String? userNote}) async {
    try {
      // Récupérer l'action depuis Firestore
      final actionDoc = await _actionsCollection.doc(actionId).get();
      if (!actionDoc.exists) {
        print('Action non trouvée: $actionId');
        return false;
      }
      
      final action = QuickImpactActionModel.fromJson({
        'id': actionDoc.id,
        ...actionDoc.data() as Map<String, dynamic>,
      });
      
      // Créer un modèle d'action complétée
      final completedAction = CompletedActionModel(
        id: '', // Sera généré par Firestore
        actionId: actionId,
        userId: userId,
        completedDate: DateTime.now(),
        userNote: userNote,
        earnedPoints: action.rewardPoints,
        carbonSaved: action.estimatedCarbonSaving,
      );
      
      // Ajouter l'action complétée à Firestore
      final docRef = await _completedActionsCollection.add(completedAction.toJson());
      
      // Mettre à jour les statistiques de l'utilisateur
      await _updateUserStats(
        userId: userId,
        pointsEarned: action.rewardPoints,
        carbonSaved: action.estimatedCarbonSaving,
        category: action.category,
      );
      
      return docRef.id.isNotEmpty;
    } catch (e) {
      print('Erreur lors de la complétion de l\'action: $e');
      return false;
    }
  }

  // Mettre à jour les statistiques de l'utilisateur
  Future<void> _updateUserStats({
    required String userId,
    required int pointsEarned,
    required double carbonSaved,
    required ActionCategory category,
  }) async {
    try {
      // Référence au document de statistiques de l'utilisateur
      final userStatsRef = _userStatsCollection.doc(userId);
      
      // Vérifier si le document existe déjà
      final userStatsDoc = await userStatsRef.get();
      
      if (userStatsDoc.exists) {
        // Mettre à jour les statistiques existantes
        final Map<String, dynamic> currentStats = userStatsDoc.data() as Map<String, dynamic>;
        
        // Récupérer les valeurs actuelles ou initialiser à 0 si elles n'existent pas
        final totalPoints = (currentStats['totalPoints'] ?? 0) + pointsEarned;
        final totalCarbonSaved = (currentStats['totalCarbonSaved'] ?? 0.0) + carbonSaved;
        final totalActionsCompleted = (currentStats['totalActionsCompleted'] ?? 0) + 1;
        
        // Mettre à jour les compteurs par catégorie
        final Map<String, dynamic> categoryCounts = 
            Map<String, dynamic>.from(currentStats['categoryCounts'] ?? {});
        final int currentCategoryCount = categoryCounts[category.name] ?? 0;
        categoryCounts[category.name] = currentCategoryCount + 1;
        
        // Mettre à jour le document
        await userStatsRef.update({
          'totalPoints': totalPoints,
          'totalCarbonSaved': totalCarbonSaved,
          'totalActionsCompleted': totalActionsCompleted,
          'categoryCounts': categoryCounts,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      } else {
        // Créer un nouveau document de statistiques
        final Map<String, dynamic> newStats = {
          'userId': userId,
          'totalPoints': pointsEarned,
          'totalCarbonSaved': carbonSaved,
          'totalActionsCompleted': 1,
          'categoryCounts': {
            category.name: 1,
          },
          'createdAt': FieldValue.serverTimestamp(),
          'lastUpdated': FieldValue.serverTimestamp(),
        };
        
        await userStatsRef.set(newStats);
      }
    } catch (e) {
      print('Erreur lors de la mise à jour des statistiques utilisateur: $e');
    }
  }

  // Récupérer l'historique des actions d'un utilisateur
  Future<List<CompletedActionModel>> getUserActionHistory(String userId) async {
    try {
      final snapshot = await _completedActionsCollection
          .where('userId', isEqualTo: userId)
          .orderBy('completedDate', descending: true)
          .get();
      
      return snapshot.docs
          .map((doc) => CompletedActionModel.fromJson({
                'id': doc.id,
                ...doc.data() as Map<String, dynamic>,
              }))
          .toList();
    } catch (e) {
      print('Erreur lors de la récupération de l\'historique des actions: $e');
      return [];
    }
  }

  // Récupérer les statistiques d'un utilisateur
  Future<Map<String, dynamic>?> getUserStats(String userId) async {
    try {
      final userStatsDoc = await _userStatsCollection.doc(userId).get();
      
      if (userStatsDoc.exists) {
        return userStatsDoc.data() as Map<String, dynamic>;
      } else {
        return {
          'userId': userId,
          'totalPoints': 0,
          'totalCarbonSaved': 0.0,
          'totalActionsCompleted': 0,
          'categoryCounts': {},
        };
      }
    } catch (e) {
      print('Erreur lors de la récupération des statistiques utilisateur: $e');
      return null;
    }
  }
} 