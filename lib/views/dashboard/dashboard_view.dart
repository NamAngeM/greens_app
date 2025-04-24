import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/controllers/dashboard_controller.dart';
import 'package:greens_app/models/dashboard_stats_model.dart';
import 'package:greens_app/models/quick_impact_action_model.dart';
import 'package:greens_app/services/quick_impact_actions_service.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/views/dashboard/quick_impact_actions_widget.dart';
import 'package:greens_app/views/dashboard/dashboard_stats_widget.dart';
import 'package:greens_app/widgets/app_bar.dart';

class DashboardView extends StatefulWidget {
  const DashboardView({Key? key}) : super(key: key);

  @override
  State<DashboardView> createState() => _DashboardViewState();
}

class _DashboardViewState extends State<DashboardView> {
  bool _isLoading = true;
  String _userId = '';
  DashboardStatsModel? _stats;
  final QuickImpactActionsService _actionsService = QuickImpactActionsService();
  
  @override
  void initState() {
    super.initState();
    _loadDashboard();
  }
  
  Future<void> _loadDashboard() async {
    setState(() {
      _isLoading = true;
    });
    
    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        throw Exception('Utilisateur non connecté');
      }
      
      _userId = currentUser.uid;
      
      // Charger les statistiques via le contrôleur
      final dashboardController = Provider.of<DashboardController>(context, listen: false);
      await dashboardController.loadUserStats(_userId);
      
      setState(() {
        _stats = dashboardController.stats;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Erreur lors du chargement du tableau de bord: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du chargement du tableau de bord'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
  
  void _handleActionCompleted(int points, double carbonSaved) {
    // Mettre à jour les statistiques locales
    setState(() {
      if (_stats != null) {
        _stats = _stats!.copyWith(
          totalPoints: _stats!.totalPoints + points,
          carbonSaved: _stats!.carbonSaved + carbonSaved,
          productsScanCount: _stats!.productsScanCount + 1,
        );
      }
    });
    
    // Notifier le contrôleur de la mise à jour
    final dashboardController = Provider.of<DashboardController>(context, listen: false);
    dashboardController.updateStats(_stats);
    
    // Afficher un message de succès
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bravo ! Vous avez gagné $points points et économisé ${carbonSaved.toStringAsFixed(1)} kg de CO2'),
        backgroundColor: Colors.green,
      ),
    );
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Tableau de bord',
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadDashboard,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildDashboard(),
    );
  }
  
  Widget _buildDashboard() {
    return RefreshIndicator(
      onRefresh: _loadDashboard,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Widget de statistiques
              if (_stats != null)
                DashboardStatsWidget(stats: _stats!),
              
              const SizedBox(height: 24),
              
              // Titre de la section
              const Text(
                'Actions à impact rapide',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              const Text(
                'Des gestes simples pour réduire votre empreinte carbone au quotidien',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Widget des actions à impact rapide
              QuickImpactActionsWidget(
                userId: _userId,
                onActionCompleted: _handleActionCompleted,
              ),
              
              const SizedBox(height: 24),
              
              // Bouton pour voir toutes les actions
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    // Navigation vers la page complète des actions
                    // Navigator.push(context, MaterialPageRoute(builder: (context) => AllActionsView()));
                  },
                  icon: const Icon(Icons.list),
                  label: const Text('Voir toutes les actions'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    backgroundColor: AppColors.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
} 