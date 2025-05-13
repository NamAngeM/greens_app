import 'package:flutter/material.dart';
import 'package:greens_app/controllers/eco_challenge_controller.dart';
import 'package:greens_app/models/eco_challenge_model.dart';
import 'package:provider/provider.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';

class EcoChallengesView extends StatefulWidget {
  const EcoChallengesView({Key? key}) : super(key: key);

  @override
  State<EcoChallengesView> createState() => _EcoChallengesViewState();
}

class _EcoChallengesViewState extends State<EcoChallengesView>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Initialiser le contrôleur de défis
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initChallenges();
    });
  }

  Future<void> _initChallenges() async {
    setState(() {
      _isLoading = true;
    });
    
    final controller = Provider.of<EcoChallengeController>(context, listen: false);
    await controller.initialize();
    
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
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
          'Défis Écologiques',
          style: TextStyle(
            color: Color(0xFF1F3140),
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: const Color(0xFF4CAF50),
          unselectedLabelColor: Colors.grey,
          indicatorColor: const Color(0xFF4CAF50),
          tabs: const [
            Tab(text: 'QUOTIDIENS'),
            Tab(text: 'HEBDO'),
            Tab(text: 'MES DÉFIS'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1F3140)),
            onPressed: _initChallenges,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            )
          : TabBarView(
              controller: _tabController,
              children: [
                _buildDailyChallengesTab(),
                _buildWeeklyChallengesTab(),
                _buildActiveChallengesTab(),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF4CAF50),
        child: const Icon(Icons.add),
        onPressed: () {
          _showCreateChallengeDialog();
        },
      ),
    );
  }

  Widget _buildDailyChallengesTab() {
    final controller = Provider.of<EcoChallengeController>(context);
    final challenges = controller.dailyChallenges;
    
    if (challenges.isEmpty) {
      return _buildEmptyState(
        'Aucun défi quotidien disponible',
        'Revenez demain pour de nouveaux défis, ou créez votre propre défi.',
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => controller.generateDailyChallenges(),
      color: const Color(0xFF4CAF50),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          return _buildChallengeCard(challenges[index], isActive: false);
        },
      ),
    );
  }

  Widget _buildWeeklyChallengesTab() {
    final controller = Provider.of<EcoChallengeController>(context);
    final challenges = controller.weeklyChallenges;
    
    if (challenges.isEmpty) {
      return _buildEmptyState(
        'Aucun défi hebdomadaire disponible',
        'Revenez la semaine prochaine pour de nouveaux défis, ou créez votre propre défi.',
      );
    }
    
    return RefreshIndicator(
      onRefresh: () => controller.generateWeeklyChallenges(),
      color: const Color(0xFF4CAF50),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: challenges.length,
        itemBuilder: (context, index) {
          return _buildChallengeCard(challenges[index], isActive: false);
        },
      ),
    );
  }

  Widget _buildActiveChallengesTab() {
    final controller = Provider.of<EcoChallengeController>(context);
    final challenges = controller.activeChallenges;
    
    if (challenges.isEmpty) {
      return _buildEmptyState(
        'Vous n\'avez pas de défis en cours',
        'Acceptez des défis quotidiens ou hebdomadaires pour commencer.',
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: challenges.length,
      itemBuilder: (context, index) {
        return _buildChallengeCard(challenges[index], isActive: true);
      },
    );
  }

  Widget _buildEmptyState(String title, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.eco_outlined,
              size: 80,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChallengeCard(EcoChallenge challenge, {required bool isActive}) {
    final controller = Provider.of<EcoChallengeController>(context, listen: false);
    
    // Définir la couleur en fonction de la catégorie
    Color categoryColor;
    switch (challenge.category) {
      case ChallengeCategory.transport:
        categoryColor = Colors.blue;
        break;
      case ChallengeCategory.energy:
        categoryColor = Colors.orange;
        break;
      case ChallengeCategory.food:
        categoryColor = Colors.deepOrange;
        break;
      case ChallengeCategory.waste:
        categoryColor = Colors.brown;
        break;
      case ChallengeCategory.water:
        categoryColor = Colors.lightBlue;
        break;
      case ChallengeCategory.digital:
        categoryColor = Colors.purple;
        break;
      case ChallengeCategory.community:
        categoryColor = Colors.teal;
        break;
      default:
        categoryColor = const Color(0xFF4CAF50);
    }
    
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête du défi
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: categoryColor.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: categoryColor,
                  child: Icon(
                    _getCategoryIcon(challenge.category),
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        challenge.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1F3140),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          _buildLevelIndicator(challenge.level),
                          const SizedBox(width: 8),
                          Text(
                            '${challenge.pointsValue} points',
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _getDurationText(challenge.duration),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Description du défi
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  challenge.description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Impact environnemental
                Row(
                  children: [
                    Icon(
                      Icons.eco,
                      size: 16,
                      color: const Color(0xFF4CAF50),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Impact: ${challenge.estimatedImpact} kg CO₂ économisés',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4CAF50),
                      ),
                    ),
                  ],
                ),
                
                // Conseils (si disponibles)
                if (challenge.tips.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text(
                    'Conseils:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1F3140),
                    ),
                  ),
                  const SizedBox(height: 4),
                  ...challenge.tips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.check_circle,
                          size: 14,
                          color: categoryColor,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                
                // Barre de progression pour les défis actifs
                if (isActive) ...[
                  const SizedBox(height: 16),
                  LinearPercentIndicator(
                    lineHeight: 8.0,
                    percent: challenge.progressPercentage / 100,
                    progressColor: const Color(0xFF4CAF50),
                    backgroundColor: Colors.grey.shade200,
                    barRadius: const Radius.circular(4),
                    padding: EdgeInsets.zero,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${challenge.progressPercentage.toInt()}% complété',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      if (challenge.startDate != null)
                        Text(
                          _getTimeRemaining(challenge),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                    ],
                  ),
                ],
                
                // Boutons d'action
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (!isActive)
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          final success = await controller.acceptChallenge(challenge.id);
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Défi accepté avec succès!'),
                                backgroundColor: Color(0xFF4CAF50),
                              ),
                            );
                            _tabController.animateTo(2); // Aller à l'onglet "Mes défis"
                          }
                        },
                        child: const Text('Accepter le défi'),
                      )
                    else ...[
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.grey.shade400),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () {
                          _showUpdateProgressDialog(challenge);
                        },
                        child: const Text('Mettre à jour'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4CAF50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                        ),
                        onPressed: () async {
                          final success = await controller.completeChallenge(challenge.id);
                          if (success && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Félicitations! Vous avez gagné ${challenge.pointsValue} points.'),
                                backgroundColor: const Color(0xFF4CAF50),
                              ),
                            );
                          }
                        },
                        child: const Text('Terminer'),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.transport:
        return Icons.directions_car;
      case ChallengeCategory.energy:
        return Icons.flash_on;
      case ChallengeCategory.food:
        return Icons.restaurant;
      case ChallengeCategory.waste:
        return Icons.delete;
      case ChallengeCategory.water:
        return Icons.water_drop;
      case ChallengeCategory.digital:
        return Icons.devices;
      case ChallengeCategory.community:
        return Icons.people;
      default:
        return Icons.eco;
    }
  }

  Widget _buildLevelIndicator(ChallengeLevel level) {
    Color color;
    String text;
    
    switch (level) {
      case ChallengeLevel.beginner:
        color = Colors.green;
        text = 'Débutant';
        break;
      case ChallengeLevel.intermediate:
        color = Colors.orange;
        text = 'Intermédiaire';
        break;
      case ChallengeLevel.advanced:
        color = Colors.red;
        text = 'Avancé';
        break;
      case ChallengeLevel.expert:
        color = Colors.purple;
        text = 'Expert';
        break;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.5)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  String _getDurationText(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} jour${duration.inDays > 1 ? 's' : ''}';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} heure${duration.inHours > 1 ? 's' : ''}';
    } else {
      return '${duration.inMinutes} min';
    }
  }

  String _getTimeRemaining(EcoChallenge challenge) {
    if (challenge.startDate == null) return '';
    
    final endDate = challenge.startDate!.add(challenge.duration);
    final now = DateTime.now();
    
    if (now.isAfter(endDate)) {
      return 'Terminé';
    }
    
    final remaining = endDate.difference(now);
    
    if (remaining.inDays > 0) {
      return 'Reste ${remaining.inDays} jour${remaining.inDays > 1 ? 's' : ''}';
    } else if (remaining.inHours > 0) {
      return 'Reste ${remaining.inHours} heure${remaining.inHours > 1 ? 's' : ''}';
    } else {
      return 'Reste ${remaining.inMinutes} min';
    }
  }

  void _showUpdateProgressDialog(EcoChallenge challenge) {
    double newProgress = challenge.progressPercentage;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Mettre à jour la progression'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Ajustez votre progression pour le défi "${challenge.title}"',
              style: TextStyle(color: Colors.grey.shade700),
            ),
            const SizedBox(height: 24),
            StatefulBuilder(
              builder: (context, setState) => Column(
                children: [
                  CircularPercentIndicator(
                    radius: 60.0,
                    lineWidth: 10.0,
                    percent: newProgress / 100,
                    center: Text(
                      '${newProgress.toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
                    ),
                    progressColor: const Color(0xFF4CAF50),
                    backgroundColor: Colors.grey.shade200,
                    circularStrokeCap: CircularStrokeCap.round,
                  ),
                  const SizedBox(height: 16),
                  Slider(
                    value: newProgress,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    label: '${newProgress.toInt()}%',
                    activeColor: const Color(0xFF4CAF50),
                    onChanged: (value) {
                      setState(() {
                        newProgress = value;
                      });
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            onPressed: () async {
              Navigator.of(context).pop();
              
              final controller = Provider.of<EcoChallengeController>(context, listen: false);
              final success = await controller.updateChallengeProgress(challenge.id, newProgress);
              
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Progression mise à jour avec succès!'),
                    backgroundColor: Color(0xFF4CAF50),
                  ),
                );
              }
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _showCreateChallengeDialog() {
    final formKey = GlobalKey<FormState>();
    String title = '';
    String description = '';
    int points = 50;
    int durationDays = 1;
    ChallengeCategory category = ChallengeCategory.general;
    ChallengeFrequency frequency = ChallengeFrequency.daily;
    ChallengeLevel level = ChallengeLevel.beginner;
    double impact = 1.0;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Créer un défi personnalisé'),
        content: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Titre du défi',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer un titre' : null,
                  onChanged: (value) => title = value,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  validator: (value) => value!.isEmpty ? 'Veuillez entrer une description' : null,
                  onChanged: (value) => description = value,
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Points',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: '50',
                        validator: (value) => value!.isEmpty ? 'Requis' : null,
                        onChanged: (value) => points = int.tryParse(value) ?? 50,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        decoration: const InputDecoration(
                          labelText: 'Durée (jours)',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        initialValue: '1',
                        validator: (value) => value!.isEmpty ? 'Requis' : null,
                        onChanged: (value) => durationDays = int.tryParse(value) ?? 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ChallengeCategory>(
                  decoration: const InputDecoration(
                    labelText: 'Catégorie',
                    border: OutlineInputBorder(),
                  ),
                  value: category,
                  items: ChallengeCategory.values.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(_getCategoryName(c)),
                  )).toList(),
                  onChanged: (value) => category = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ChallengeFrequency>(
                  decoration: const InputDecoration(
                    labelText: 'Fréquence',
                    border: OutlineInputBorder(),
                  ),
                  value: frequency,
                  items: ChallengeFrequency.values.map((f) => DropdownMenuItem(
                    value: f,
                    child: Text(_getFrequencyName(f)),
                  )).toList(),
                  onChanged: (value) => frequency = value!,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<ChallengeLevel>(
                  decoration: const InputDecoration(
                    labelText: 'Niveau de difficulté',
                    border: OutlineInputBorder(),
                  ),
                  value: level,
                  items: ChallengeLevel.values.map((l) => DropdownMenuItem(
                    value: l,
                    child: Text(_getLevelName(l)),
                  )).toList(),
                  onChanged: (value) => level = value!,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Impact environnemental (kg CO₂)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  initialValue: '1.0',
                  validator: (value) => value!.isEmpty ? 'Requis' : null,
                  onChanged: (value) => impact = double.tryParse(value) ?? 1.0,
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            child: const Text('Annuler'),
            onPressed: () => Navigator.of(context).pop(),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
            ),
            onPressed: () async {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop();
                
                final challenge = EcoChallenge(
                  id: 'temp_id',
                  title: title,
                  description: description,
                  pointsValue: points,
                  duration: Duration(days: durationDays),
                  category: category,
                  frequency: frequency,
                  level: level,
                  estimatedImpact: impact,
                );
                
                final controller = Provider.of<EcoChallengeController>(context, listen: false);
                final success = await controller.createCustomChallenge(challenge);
                
                if (success && mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Défi personnalisé créé avec succès!'),
                      backgroundColor: Color(0xFF4CAF50),
                    ),
                  );
                }
              }
            },
            child: const Text('Créer'),
          ),
        ],
      ),
    );
  }

  String _getCategoryName(ChallengeCategory category) {
    switch (category) {
      case ChallengeCategory.transport:
        return 'Transport';
      case ChallengeCategory.energy:
        return 'Énergie';
      case ChallengeCategory.food:
        return 'Alimentation';
      case ChallengeCategory.waste:
        return 'Déchets';
      case ChallengeCategory.water:
        return 'Eau';
      case ChallengeCategory.digital:
        return 'Numérique';
      case ChallengeCategory.community:
        return 'Communauté';
      default:
        return 'Général';
    }
  }

  String _getFrequencyName(ChallengeFrequency frequency) {
    switch (frequency) {
      case ChallengeFrequency.daily:
        return 'Quotidien';
      case ChallengeFrequency.weekly:
        return 'Hebdomadaire';
      case ChallengeFrequency.monthly:
        return 'Mensuel';
      default:
        return 'Une fois';
    }
  }

  String _getLevelName(ChallengeLevel level) {
    switch (level) {
      case ChallengeLevel.beginner:
        return 'Débutant';
      case ChallengeLevel.intermediate:
        return 'Intermédiaire';
      case ChallengeLevel.advanced:
        return 'Avancé';
      default:
        return 'Expert';
    }
  }
} 