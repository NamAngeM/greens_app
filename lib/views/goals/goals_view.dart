import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/eco_goal_controller.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/models/eco_goal_model.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:intl/intl.dart';

class GoalsView extends StatefulWidget {
  const GoalsView({Key? key}) : super(key: key);

  @override
  _GoalsViewState createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _targetController = TextEditingController();
  GoalType _selectedType = GoalType.waterSaving;
  GoalFrequency _selectedFrequency = GoalFrequency.daily;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Récupérer les objectifs de l'utilisateur
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);
      final ecoGoalController = Provider.of<EcoGoalController>(context, listen: false);
      
      if (authController.currentUser != null) {
        ecoGoalController.getUserGoals(authController.currentUser!.uid);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    _targetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Mes Objectifs Écologiques',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.of(context).pop(),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4CAF50),
          tabs: const [
            Tab(text: 'En cours'),
            Tab(text: 'Complétés'),
            Tab(text: 'Statistiques'),
          ],
        ),
      ),
      body: Consumer<EcoGoalController>(
        builder: (context, ecoGoalController, child) {
          if (ecoGoalController.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              )
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Onglet des objectifs en cours
              _buildActiveGoalsTab(ecoGoalController),
              
              // Onglet des objectifs complétés
              _buildCompletedGoalsTab(ecoGoalController),
              
              // Onglet des statistiques
              _buildStatisticsTab(),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        elevation: 4,
        child: const Icon(Icons.add),
        onPressed: () {
          _showAddGoalDialog(context);
        },
      ),
    );
  }

  Widget _buildActiveGoalsTab(EcoGoalController controller) {
    final activeGoals = controller.userGoals.where((goal) => !goal.isCompleted).toList();
    
    if (activeGoals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.eco,
                size: 80,
                color: Color(0xFF4CAF50),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Vous n\'avez pas encore d\'objectifs',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Ajoutez un objectif pour commencer',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _showAddGoalDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4CAF50),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 4,
              ),
              child: const Text(
                'Ajouter un objectif',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: activeGoals.length,
      itemBuilder: (context, index) {
        final goal = activeGoals[index];
        return _buildGoalCard(goal, controller);
      },
    );
  }

  Widget _buildCompletedGoalsTab(EcoGoalController controller) {
    final completedGoals = controller.userGoals.where((goal) => goal.isCompleted).toList();
    
    if (completedGoals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.amber.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_outline,
                size: 80,
                color: Colors.amber,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Pas d\'objectifs complétés',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Complétez vos objectifs pour les voir ici',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: completedGoals.length,
      itemBuilder: (context, index) {
        final goal = completedGoals[index];
        return _buildGoalCard(goal, controller);
      },
    );
  }

  Widget _buildStatisticsTab() {
    final controller = Provider.of<EcoGoalController>(context);
    final goals = controller.userGoals;
    
    if (goals.isEmpty) {
      return const Center(
        child: Text(
          'Aucun objectif pour le moment',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
          ),
        ),
      );
    }
    
    // Calcul des statistiques
    final completedGoals = goals.where((goal) => goal.isCompleted).length;
    final activeGoals = goals.where((goal) => !goal.isCompleted).length;
    final totalGoals = goals.length;
    final completionRate = totalGoals > 0 ? (completedGoals / totalGoals) * 100 : 0;
    
    // Répartition par type
    final Map<GoalType, int> goalsByType = {};
    for (var type in GoalType.values) {
      goalsByType[type] = 0;
    }
    
    for (var goal in goals) {
      goalsByType[goal.type] = (goalsByType[goal.type] ?? 0) + 1;
    }
    
    // Couleurs pour le graphique
    final typeColors = [
      Colors.blue,        // Water
      Colors.yellow[800]!, // Energy
      Colors.orange,      // Waste
      Colors.purple,      // Shopping
      Colors.teal,        // Transport
      Colors.green,       // Custom
    ];
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Carte de résumé
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Résumé de vos objectifs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatCard(
                        'Total',
                        totalGoals.toString(),
                        Icons.list_alt,
                        Colors.blue,
                      ),
                      _buildStatCard(
                        'Actifs',
                        activeGoals.toString(),
                        Icons.pending_actions,
                        Colors.orange,
                      ),
                      _buildStatCard(
                        'Complétés',
                        completedGoals.toString(),
                        Icons.check_circle_outline,
                        Colors.green,
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Taux de complétion: ${completionRate.toStringAsFixed(0)}%',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: completionRate / 100,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Répartition par type
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    blurRadius: 10,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Répartition par type',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 200,
                    child: CustomPaint(
                      size: const Size(double.infinity, 200),
                      painter: PieChartPainter(
                        values: goalsByType.values.map((v) => v.toDouble()).toList(),
                        colors: typeColors,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _buildLegendItem('Eau', Colors.blue),
                      _buildLegendItem('Énergie', Colors.yellow[800]!),
                      _buildLegendItem('Déchets', Colors.orange),
                      _buildLegendItem('Achats', Colors.purple),
                      _buildLegendItem('Transport', Colors.teal),
                      _buildLegendItem('Autre', Colors.green),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 24,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildGoalCard(EcoGoal goal, EcoGoalController controller) {
    final IconData iconData = _getIconForType(goal.type);
    final Color iconColor = _getColorForType(goal.type);
    final double progress = goal.currentProgress / (goal.target > 0 ? goal.target : 1);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.15),
            spreadRadius: 2,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec icône et titre
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    iconData,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        goal.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getFrequencyText(goal.frequency),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  onPressed: () {
                    _showGoalOptionsDialog(context, goal, controller);
                  },
                ),
              ],
            ),
          ),
          
          // Corps avec description et progression
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  goal.description,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Progression',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 12,
                                ),
                              ),
                              const Spacer(),
                              Text(
                                '${(progress * 100).toStringAsFixed(0)}%',
                                style: TextStyle(
                                  color: iconColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              backgroundColor: Colors.grey.shade200,
                              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
                              minHeight: 8,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton(
                      onPressed: () {
                        _showUpdateProgressDialog(context, goal, controller);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: iconColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Mettre à jour',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Créé le ${DateFormat('dd/MM/yyyy').format(goal.createdAt)}',
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeProgressBar(String label, int count, int total, Color color) {
    final percentage = total > 0 ? (count / total) * 100 : 0;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label.capitalize(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '$count (${percentage.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percentage / 100,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(color),
          minHeight: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  void _showDeleteConfirmation(BuildContext context, EcoGoal goal, EcoGoalController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'objectif'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'objectif "${goal.title}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              controller.deleteGoal(goal.id);
              Navigator.of(context).pop();
            },
            child: const Text('Supprimer'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        ],
      ),
    );
  }

  void _showUpdateProgressDialog(BuildContext context, EcoGoal goal, EcoGoalController controller) {
    final TextEditingController progressController = TextEditingController();
    progressController.text = goal.currentProgress.toString();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mettre à jour la progression'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Objectif: ${goal.title}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: progressController,
              decoration: InputDecoration(
                labelText: 'Progression actuelle',
                border: const OutlineInputBorder(),
                suffixText: '/ ${goal.target}',
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final newValue = int.tryParse(progressController.text);
              if (newValue != null) {
                controller.updateGoalProgress(
                  goal.id,
                  newValue,
                );
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Mettre à jour'),
          ),
        ],
      ),
    );
  }

  void _showGoalOptionsDialog(BuildContext context, EcoGoal goal, EcoGoalController controller) {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Options'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              _showUpdateProgressDialog(context, goal, controller);
            },
            child: const Row(
              children: [
                Icon(Icons.update),
                SizedBox(width: 12),
                Text('Mettre à jour la progression'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              // Logique pour modifier l'objectif
            },
            child: const Row(
              children: [
                Icon(Icons.edit),
                SizedBox(width: 12),
                Text('Modifier l\'objectif'),
              ],
            ),
          ),
          SimpleDialogOption(
            onPressed: () {
              Navigator.of(context).pop();
              _showDeleteConfirmation(context, goal, controller);
            },
            child: const Row(
              children: [
                Icon(Icons.delete, color: Colors.red),
                SizedBox(width: 12),
                Text('Supprimer', style: TextStyle(color: Colors.red)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getColorForType(GoalType type) {
    switch (type) {
      case GoalType.waterSaving:
        return Colors.blue;
      case GoalType.energySaving:
        return Colors.yellow.shade800;
      case GoalType.wasteReduction:
        return Colors.orange;
      case GoalType.transportation:
        return Colors.teal;
      case GoalType.sustainableShopping:
        return Colors.purple;
      case GoalType.custom:
        return Colors.green;
      default:
        return Colors.green;
    }
  }

  String _getFrequencyText(GoalFrequency frequency) {
    switch (frequency) {
      case GoalFrequency.daily:
        return 'Quotidien';
      case GoalFrequency.weekly:
        return 'Hebdomadaire';
      case GoalFrequency.monthly:
        return 'Mensuel';
      default:
        return 'Personnalisé';
    }
  }

  IconData _getIconForType(GoalType type) {
    switch (type) {
      case GoalType.wasteReduction:
        return Icons.delete_outline;
      case GoalType.waterSaving:
        return Icons.water_drop_outlined;
      case GoalType.energySaving:
        return Icons.bolt_outlined;
      case GoalType.sustainableShopping:
        return Icons.shopping_bag_outlined;
      case GoalType.transportation:
        return Icons.directions_bus_outlined;
      case GoalType.custom:
        return Icons.eco_outlined;
      default:
        return Icons.eco_outlined;
    }
  }

  void _showAddGoalDialog(BuildContext context) {
    _titleController.clear();
    _descriptionController.clear();
    _targetController.clear();
    _selectedType = GoalType.waterSaving;
    _selectedFrequency = GoalFrequency.daily;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter un objectif'),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Titre',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer un titre';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<GoalType>(
                  value: _selectedType,
                  decoration: const InputDecoration(
                    labelText: 'Type',
                    border: OutlineInputBorder(),
                  ),
                  items: GoalType.values.map((type) {
                    return DropdownMenuItem<GoalType>(
                      value: type,
                      child: Text(type.toString().split('.').last.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedType = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<GoalFrequency>(
                  value: _selectedFrequency,
                  decoration: const InputDecoration(
                    labelText: 'Fréquence',
                    border: OutlineInputBorder(),
                  ),
                  items: GoalFrequency.values.map((frequency) {
                    return DropdownMenuItem<GoalFrequency>(
                      value: frequency,
                      child: Text(frequency.toString().split('.').last.capitalize()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedFrequency = value;
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _targetController,
                  decoration: const InputDecoration(
                    labelText: 'Valeur cible',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Veuillez entrer une valeur cible';
                    }
                    if (double.tryParse(value) == null) {
                      return 'Veuillez entrer un nombre valide';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final authController = Provider.of<AuthController>(context, listen: false);
                final ecoGoalController = Provider.of<EcoGoalController>(context, listen: false);
                
                if (authController.currentUser != null) {
                  final targetValue = double.parse(_targetController.text);
                  
                  ecoGoalController.createGoal(
                    userId: authController.currentUser!.uid,
                    title: _titleController.text,
                    description: _descriptionController.text,
                    type: _selectedType,
                    frequency: _selectedFrequency,
                    target: targetValue.toInt(),
                    startDate: DateTime.now(),
                    endDate: DateTime.now().add(const Duration(days: 30)),
                  );
                  
                  Navigator.of(context).pop();
                }
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            child: const Text('Ajouter'),
          ),
        ],
      ),
    );
  }
}

class PieChartPainter extends CustomPainter {
  final List<double> values;
  final List<Color> colors;

  PieChartPainter({
    required this.values,
    required this.colors,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = values.reduce((value, element) => value + element);
    if (total <= 0) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    double startAngle = -3.14159 / 2;
    
    for (int i = 0; i < values.length; i++) {
      final value = values[i];
      final color = colors[i];
      
      final sweepAngle = (value / total) * 2 * 3.14159;
      
      final paint = Paint()
        ..color = color
        ..style = PaintingStyle.fill;
      
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        true,
        paint,
      );
      
      startAngle += sweepAngle;
    }
    
    // Draw center hole
    final holePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius * 0.5, holePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}