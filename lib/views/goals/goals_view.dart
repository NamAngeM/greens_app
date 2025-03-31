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
  State<GoalsView> createState() => _GoalsViewState();
}

class _GoalsViewState extends State<GoalsView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
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
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primaryColor,
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
            return const Center(child: CircularProgressIndicator());
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // Onglet des objectifs en cours
              _buildActiveGoalsTab(ecoGoalController),
              
              // Onglet des objectifs complétés
              _buildCompletedGoalsTab(ecoGoalController),
              
              // Onglet des statistiques
              _buildStatsTab(ecoGoalController),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primaryColor,
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
            Icon(
              Icons.eco,
              size: 100,
              color: Colors.grey,
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
                backgroundColor: AppColors.primaryColor,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
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
            Icon(
              Icons.check_circle_outline,
              size: 100,
              color: Colors.grey,
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
        return _buildCompletedGoalCard(goal, controller);
      },
    );
  }

  Widget _buildStatsTab(EcoGoalController controller) {
    final totalGoals = controller.userGoals.length;
    final completedGoals = controller.userGoals.where((goal) => goal.isCompleted).length;
    final completionRate = totalGoals > 0 ? (completedGoals / totalGoals) * 100 : 0;
    
    // Regrouper les objectifs par type
    final Map<GoalType, int> goalsByType = {};
    for (var goal in controller.userGoals) {
      if (goalsByType.containsKey(goal.type)) {
        goalsByType[goal.type] = goalsByType[goal.type]! + 1;
      } else {
        goalsByType[goal.type] = 1;
      }
    }
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte de résumé
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Résumé',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem('Total', totalGoals.toString(), Icons.list_alt),
                      _buildStatItem('Complétés', completedGoals.toString(), Icons.check_circle),
                      _buildStatItem(
                        'Taux',
                        '${completionRate.toStringAsFixed(1)}%',
                        Icons.trending_up,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          
          // Graphique de progression
          if (totalGoals > 0) ...[
            const Text(
              'Progression',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              width: 150,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CustomPaint(
                    size: const Size(150, 150),
                    painter: PieChartPainter(
                      completedValue: completedGoals.toDouble(),
                      remainingValue: (totalGoals - completedGoals).toDouble(),
                      completedColor: AppColors.primaryColor,
                      remainingColor: Colors.grey.shade300,
                    ),
                  ),
                  Center(
                    child: Text(
                      '${completionRate.toStringAsFixed(0)}%',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // Legend
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLegendItem('Complétés', AppColors.primaryColor),
                const SizedBox(width: 24),
                _buildLegendItem('En cours', Colors.grey.shade300),
              ],
            ),
          ],
          
          const SizedBox(height: 24),
          
          // Distribution par type
          if (goalsByType.isNotEmpty) ...[
            const Text(
              'Distribution par type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...goalsByType.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildTypeProgressBar(
                  entry.key.toString().split('.').last,
                  entry.value,
                  totalGoals,
                  _getColorForType(entry.key),
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          size: 32,
          color: AppColors.primaryColor,
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade600,
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

  Color _getColorForType(GoalType type) {
    switch (type) {
      case GoalType.waterSaving:
        return Colors.blue;
      case GoalType.energySaving:
        return Colors.orange;
      case GoalType.wasteReduction:
        return Colors.green;
      case GoalType.transportation:
        return Colors.purple;
      case GoalType.sustainableShopping:
        return Colors.red;
      default:
        return AppColors.primaryColor;
    }
  }

  Widget _buildGoalCard(EcoGoal goal, EcoGoalController controller) {
    final progress = goal.currentProgress / goal.target;
    final formattedProgress = (progress * 100).toStringAsFixed(0);
    
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getColorForType(goal.type).withOpacity(0.2),
                  child: Icon(
                    _getIconForType(goal.type),
                    color: _getColorForType(goal.type),
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
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
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Progression: $formattedProgress%',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      LinearProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        backgroundColor: Colors.grey.shade200,
                        valueColor: AlwaysStoppedAnimation<Color>(_getColorForType(goal.type)),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
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
                    backgroundColor: AppColors.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text('Mettre à jour'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Fréquence: ${goal.frequency.toString().split('.').last.capitalize()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Créé le: ${DateFormat('dd/MM/yyyy').format(goal.createdAt)}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedGoalCard(EcoGoal goal, EcoGoalController controller) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.green.withOpacity(0.2),
                  child: const Icon(
                    Icons.check,
                    color: Colors.green,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        goal.description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () {
                    _showDeleteConfirmationDialog(context, goal, controller);
                  },
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Type: ${goal.type.toString().split('.').last.capitalize()}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  'Complété le: ${goal.isCompleted ? DateFormat('dd/MM/yyyy').format(goal.updatedAt) : 'N/A'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(GoalType type) {
    switch (type) {
      case GoalType.waterSaving:
        return Icons.water_drop;
      case GoalType.energySaving:
        return Icons.bolt;
      case GoalType.wasteReduction:
        return Icons.delete;
      case GoalType.transportation:
        return Icons.directions_bus;
      case GoalType.sustainableShopping:
        return Icons.shopping_cart;
      default:
        return Icons.eco;
    }
  }

  void _showAddGoalDialog(BuildContext context) {
    _titleController.clear();
    _descriptionController.clear();
    _selectedType = GoalType.waterSaving;
    _selectedFrequency = GoalFrequency.daily;
    
    final TextEditingController targetController = TextEditingController();
    
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
                  controller: targetController,
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
                  final targetValue = double.parse(targetController.text);
                  
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
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Ajouter'),
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
              final newValue = double.tryParse(progressController.text);
              if (newValue != null) {
                controller.updateGoalProgress(
                  goal.id,
                  newValue.toInt(),
                );
                Navigator.of(context).pop();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
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
              _showDeleteConfirmationDialog(context, goal, controller);
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

  void _showDeleteConfirmationDialog(BuildContext context, EcoGoal goal, EcoGoalController controller) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'objectif'),
        content: Text('Êtes-vous sûr de vouloir supprimer l\'objectif "${goal.title}" ?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              controller.deleteGoal(goal.id);
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Supprimer'),
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
}

class PieChartPainter extends CustomPainter {
  final double completedValue;
  final double remainingValue;
  final Color completedColor;
  final Color remainingColor;

  PieChartPainter({
    required this.completedValue,
    required this.remainingValue,
    required this.completedColor,
    required this.remainingColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final total = completedValue + remainingValue;
    if (total <= 0) return;
    
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Draw background circle (remaining)
    final backgroundPaint = Paint()
      ..color = remainingColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, backgroundPaint);
    
    if (completedValue > 0) {
      // Draw completed arc
      final completedPaint = Paint()
        ..color = completedColor
        ..style = PaintingStyle.fill;
      
      final sweepAngle = (completedValue / total) * 2 * 3.14159;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        -3.14159 / 2, // Start from top
        sweepAngle,
        true,
        completedPaint,
      );
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