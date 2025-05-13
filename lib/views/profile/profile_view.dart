import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/widgets/custom_button.dart';
import 'package:greens_app/widgets/menu.dart';
import 'package:greens_app/models/user_model.dart';
import 'package:greens_app/services/eco_journey_service.dart';
import 'package:greens_app/services/eco_challenge_service.dart';
import 'package:greens_app/models/user_eco_level.dart';
import 'package:greens_app/models/eco_badge.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({Key? key}) : super(key: key);

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isEditing = false;
  bool _isLoading = true;
  UserModel? _mockUser; // Utilisateur fictif pour les tests
  
  // Nouvelles variables pour les informations écologiques
  UserEcoLevel? _userLevel;
  List<EcoBadge> _userBadges = [];
  int _ecoPoints = 0;
  double _journeyProgress = 0.0;
  Map<String, dynamic> _challengeStats = {};
  
  // Contrôleur de tab
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Créer un utilisateur fictif si le vrai n'existe pas
    _mockUser = UserModel(
      uid: 'mock-user-id',
      email: 'user@example.com',
      firstName: 'Sam',
      lastName: 'Green',
      photoUrl: null,
      carbonPoints: 350,
    );
    
    _loadUserData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  void _loadUserData() {
    final authController = Provider.of<AuthController>(context, listen: false);
    final user = authController.currentUser ?? _mockUser;
    
    if (user != null) {
      String displayName = '';
      if (user.firstName != null && user.firstName!.isNotEmpty) {
        displayName = user.firstName!;
        if (user.lastName != null && user.lastName!.isNotEmpty) {
          displayName += ' ${user.lastName!}';
        }
      } else if (user.lastName != null && user.lastName!.isNotEmpty) {
        displayName = user.lastName!;
      } else {
        displayName = 'Utilisateur GreenMinds';
      }
      
      _nameController.text = displayName;
      _emailController.text = user.email ?? '';
      
      // Charger les données écologiques
      _loadEcoData(user.uid);
    }
  }
  
  Future<void> _loadEcoData(String userId) async {
    try {
      final journeyService = Provider.of<EcoJourneyService>(context, listen: false);
      final challengeService = Provider.of<EcoChallengeService>(context, listen: false);
      
      final userLevelNumber = await journeyService.getUserEcoLevel(userId);
      final userLevel = journeyService.getLevelInfo(userLevelNumber);
      final ecoPoints = await journeyService.getUserEcoPoints(userId);
      final journeyProgress = await journeyService.getOverallProgress(userId);
      
      // Initialiser les défis pour récupérer les statistiques
      await challengeService.initialize(userId);
      final challengeStats = challengeService.getUserChallengeStats();
      
      setState(() {
        _userLevel = userLevel;
        _ecoPoints = ecoPoints;
        _journeyProgress = journeyProgress;
        _challengeStats = challengeStats;
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des données écologiques: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _toggleEdit() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final String fullName = _nameController.text.trim();
      final List<String> nameParts = fullName.split(' ');
      final String firstName = nameParts.isNotEmpty ? nameParts[0] : '';
      final String lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
      
      final authController = Provider.of<AuthController>(context, listen: false);
      
      _updateUserInfo(firstName, lastName, authController).then((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil mis à jour avec succès'),
            backgroundColor: AppColors.secondaryColor,
          ),
        );
        setState(() {
          _isEditing = false;
        });
      }).catchError((error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${error.toString()}'),
            backgroundColor: AppColors.errorColor,
          ),
        );
      });
    }
  }
  
  Future<void> _updateUserInfo(String firstName, String lastName, AuthController authController) async {
    // Dans une version réelle, cela mettrait à jour les informations de l'utilisateur
    setState(() {
      if (_mockUser != null) {
        _mockUser = _mockUser!.copyWith(
          firstName: firstName,
          lastName: lastName,
        );
      }
    });
    await Future.delayed(const Duration(milliseconds: 500));
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final user = authController.currentUser ?? _mockUser;

    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            const Icon(
              Icons.person_outline,
              color: Color(0xFF4CAF50),
              size: 24,
            ),
            const SizedBox(width: 8),
            const Text(
              "Mon profil",
              style: TextStyle(
                color: Color(0xFF1F3140),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit, color: Color(0xFF1F3140)),
            onPressed: _isEditing ? _saveProfile : _toggleEdit,
          ),
        ],
      ),
      body: user == null
          ? const Center(child: Text("Aucune information utilisateur disponible"))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileHeader(user),
                    const SizedBox(height: 24),
                    
                    if (_isEditing) ...[
                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: 'Nom',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Veuillez entrer votre nom';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      
                      TextFormField(
                        controller: _emailController,
                        enabled: false, 
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: const Icon(Icons.email_outlined),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ] else ...[
                      _buildTabs(),
                      
                      SizedBox(
                        height: 300,
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildEcoJourneyTab(),
                            _buildBadgesTab(),
                            _buildStatisticsTab(),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      _buildActionButtons(),
                    ],
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const CustomMenu(currentIndex: 3),
    );
  }
  
  Widget _buildProfileHeader(UserModel user) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: AppColors.profilePrimaryColor.withOpacity(0.2),
              child: Icon(
                Icons.person,
                size: 80,
                color: AppColors.profilePrimaryColor,
              ),
            ),
            if (_userLevel != null)
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Text(
                  '${_userLevel!.level}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          _nameController.text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1F3140),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          _userLevel?.title ?? 'Débutant écologique',
          style: const TextStyle(
            fontSize: 16,
            color: Color(0xFF4CAF50),
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF4CAF50).withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.eco,
                color: Color(0xFF4CAF50),
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                '$_ecoPoints points',
                style: const TextStyle(
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
  
  Widget _buildTabs() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: BoxDecoration(
          color: const Color(0xFF4CAF50),
          borderRadius: BorderRadius.circular(16),
        ),
        labelColor: Colors.white,
        unselectedLabelColor: Colors.grey.shade700,
        tabs: const [
          Tab(text: 'Parcours'),
          Tab(text: 'Badges'),
          Tab(text: 'Statistiques'),
        ],
      ),
    );
  }
  
  Widget _buildEcoJourneyTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Votre parcours écologique',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3140),
            ),
          ),
          const SizedBox(height: 16),
          LinearPercentIndicator(
            lineHeight: 16.0,
            percent: _journeyProgress,
            center: Text(
              '${(_journeyProgress * 100).toInt()}%',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            progressColor: const Color(0xFF4CAF50),
            backgroundColor: Colors.grey.shade200,
            barRadius: const Radius.circular(8),
            padding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildEcoMetricItem(
                '$_ecoPoints',
                'Points accumulés',
                Icons.stars,
                const Color(0xFF4CAF50),
              ),
              _buildEcoMetricItem(
                '${_challengeStats['totalCompleted'] ?? 0}',
                'Défis complétés',
                Icons.check_circle,
                const Color(0xFF4CAF50),
              ),
              _buildEcoMetricItem(
                '${(_challengeStats['totalImpact'] ?? 0.0).toStringAsFixed(1)} kg',
                'CO2 économisé',
                Icons.eco,
                const Color(0xFF4CAF50),
              ),
            ],
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.ecoJourney);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4CAF50),
              side: const BorderSide(color: Color(0xFF4CAF50)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              minimumSize: const Size(double.infinity, 48),
            ),
            child: const Text('Voir mon parcours complet'),
          ),
        ],
      ),
    );
  }
  
  Widget _buildBadgesTab() {
    // À remplir avec les badges de l'utilisateur
    if (_userBadges.isEmpty) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.emoji_events_outlined,
            size: 60,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          const Text(
            'Complétez des défis pour gagner des badges !',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 24),
          OutlinedButton(
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.challenges);
            },
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF4CAF50),
              side: const BorderSide(color: Color(0xFF4CAF50)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Voir les défis disponibles'),
          ),
        ],
      );
    } else {
      return GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: _userBadges.length,
        itemBuilder: (context, index) {
          final badge = _userBadges[index];
          return Column(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.emoji_events, color: Colors.amber),
              ),
              const SizedBox(height: 8),
              Text(
                badge.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );
        },
      );
    }
  }
  
  Widget _buildStatisticsTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Statistiques',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3140),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 10.0,
                percent: _journeyProgress,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${(_journeyProgress * 100).toInt()}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'Parcours',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                progressColor: const Color(0xFF4CAF50),
                backgroundColor: Colors.grey.shade200,
                circularStrokeCap: CircularStrokeCap.round,
              ),
              CircularPercentIndicator(
                radius: 60.0,
                lineWidth: 10.0,
                percent: (_challengeStats['totalCompleted'] ?? 0) / 10,
                center: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${_challengeStats['totalCompleted'] ?? 0}',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const Text(
                      'Défis',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                progressColor: Colors.blue,
                backgroundColor: Colors.grey.shade200,
                circularStrokeCap: CircularStrokeCap.round,
              ),
            ],
          ),
          const SizedBox(height: 24),
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Impact environnemental',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildStatItem(
                        '${(_challengeStats['totalImpact'] ?? 0.0).toStringAsFixed(1)} kg',
                        'CO2 économisé',
                        Icons.eco,
                        Colors.green,
                      ),
                      _buildStatItem(
                        '${_challengeStats['totalPoints'] ?? 0}',
                        'Points gagnés',
                        Icons.stars,
                        Colors.amber,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildEcoMetricItem(String value, String label, IconData icon, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: color,
            size: 20,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildStatItem(String value, String label, IconData icon, Color color) {
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
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
  
  Widget _buildActionButtons() {
    return Column(
      children: [
        CustomButton(
          text: 'Mon parcours écologique',
          icon: Icons.eco,
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.ecoJourney);
          },
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Mes défis écologiques',
          icon: Icons.assignment,
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.challenges);
          },
        ),
        const SizedBox(height: 12),
        CustomButton(
          text: 'Paramètres',
          icon: Icons.settings_outlined,
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.settings);
          },
        ),
        const SizedBox(height: 24),
        Container(
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Déconnexion',
              style: TextStyle(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Déconnexion'),
                  content: const Text('Êtes-vous sûr de vouloir vous déconnecter ?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        // Simuler la déconnexion
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Déconnexion réussie'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.pop(context);
                      },
                      child: const Text(
                        'Déconnexion',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}