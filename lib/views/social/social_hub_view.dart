import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:greens_app/models/eco_activity.dart';
import 'package:greens_app/services/eco_activity_service.dart';
import 'package:greens_app/services/auth_service.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_styles.dart';
import 'package:greens_app/widgets/custom_widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lottie/lottie.dart';

class SocialHubView extends StatefulWidget {
  const SocialHubView({Key? key}) : super(key: key);

  @override
  _SocialHubViewState createState() => _SocialHubViewState();
}

class _SocialHubViewState extends State<SocialHubView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final EcoActivityService _ecoActivityService = EcoActivityService();
  final AuthService _authService = AuthService();
  List<EcoActivity> _communityActivities = [];
  List<EcoActivity> _friendsActivities = [];
  final RxBool _isLoading = false.obs;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadActivities();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadActivities() async {
    _isLoading.value = true;
    try {
      // Simuler le chargement des activités de la communauté et des amis
      // Dans une implémentation réelle, cela proviendrait d'un service dédié
      await Future.delayed(const Duration(seconds: 1));
      
      // Exemple d'activités communautaires
      _communityActivities = [
        EcoActivity(
          id: '1',
          userId: 'community1',
          title: 'Nettoyage du parc municipal',
          description: 'Une équipe de 15 personnes a nettoyé le parc municipal, collectant 25 kg de déchets.',
          type: ActivityType.community,
          carbonImpact: 15.0,
          timestamp: DateTime.now().subtract(const Duration(days: 2)),
          additionalData: {'participants': 15, 'location': 'Parc Municipal'},
          isVerified: true,
        ),
        EcoActivity(
          id: '2',
          userId: 'community2',
          title: 'Atelier de compostage',
          description: 'Atelier éducatif sur le compostage domestique organisé au centre communautaire.',
          type: ActivityType.waste,
          carbonImpact: 8.5,
          timestamp: DateTime.now().subtract(const Duration(days: 3)),
          additionalData: {'participants': 22, 'location': 'Centre Communautaire'},
          isVerified: true,
        ),
      ];
      
      // Exemple d'activités d'amis
      _friendsActivities = [
        EcoActivity(
          id: '3',
          userId: 'friend1',
          title: 'Vélo au travail',
          description: 'J\'ai utilisé mon vélo pour aller au travail toute la semaine!',
          type: ActivityType.transport,
          carbonImpact: 5.2,
          timestamp: DateTime.now().subtract(const Duration(hours: 8)),
          isVerified: true,
        ),
        EcoActivity(
          id: '4',
          userId: 'friend2',
          title: 'Marché fermier local',
          description: 'J\'ai acheté tous mes légumes au marché fermier local ce weekend.',
          type: ActivityType.food,
          carbonImpact: 3.8,
          timestamp: DateTime.now().subtract(const Duration(days: 1)),
          isVerified: true,
        ),
      ];

    } catch (e) {
      print('Erreur lors du chargement des activités: $e');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Communauté', style: AppStyles.titleStyle),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Activités'),
            Tab(text: 'Défis'),
            Tab(text: 'Initiatives'),
          ],
        ),
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primaryColor));
        }
        
        return TabBarView(
          controller: _tabController,
          children: [
            _buildActivitiesTab(),
            _buildChallengesTab(),
            _buildInitiativesTab(),
          ],
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: _showShareActionSheet,
        backgroundColor: AppColors.accentColor,
        child: const Icon(Icons.add, color: Colors.white),
        tooltip: 'Partager une activité',
      ),
    );
  }

  Widget _buildActivitiesTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Activités de la communauté'),
          const SizedBox(height: 8),
          ..._communityActivities.map((activity) => _buildActivityCard(activity, true)).toList(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Activités de vos amis'),
          const SizedBox(height: 8),
          ..._friendsActivities.map((activity) => _buildActivityCard(activity, false)).toList(),
          
          if (_communityActivities.isEmpty && _friendsActivities.isEmpty)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/animations/empty_state.json',
                    width: 200,
                    height: 200,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune activité pour le moment',
                    style: AppStyles.subtitleStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Soyez le premier à partager une activité écologique!',
                    style: AppStyles.bodyStyle,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildChallengesTab() {
    // Liste de défis communautaires
    final challenges = [
      {
        'title': 'Zéro Déchet - 7 jours',
        'description': 'Réduisez vos déchets au maximum pendant une semaine',
        'participants': 58,
        'daysLeft': 3,
        'icon': 'assets/icons/recycle.svg',
        'color': Colors.green[700],
      },
      {
        'title': 'Transport Durable',
        'description': 'Utilisez uniquement des transports écologiques pendant 5 jours',
        'participants': 32,
        'daysLeft': 5,
        'icon': 'assets/icons/bicycle.svg',
        'color': Colors.blue[700],
      },
      {
        'title': 'Économie d\'énergie',
        'description': 'Réduisez votre consommation d\'énergie domestique de 20%',
        'participants': 24,
        'daysLeft': 10,
        'icon': 'assets/icons/energy.svg',
        'color': Colors.amber[700],
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Défis en cours'),
          const SizedBox(height: 16),
          ...challenges.map((challenge) => _buildChallengeCard(challenge)).toList(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Créer un défi'),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 1),
            ),
            child: InkWell(
              onTap: () {
                // Naviguer vers la page de création de défi
                Get.toNamed('/create-challenge');
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: Row(
                  children: [
                    Icon(Icons.add_circle_outline, color: AppColors.primaryColor, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Proposer un nouveau défi',
                            style: AppStyles.subtitleStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Engagez votre communauté dans un défi écologique',
                            style: AppStyles.bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: AppColors.textColor, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInitiativesTab() {
    // Liste d'initiatives locales
    final initiatives = [
      {
        'title': 'Marché fermier bio',
        'location': 'Place de la République',
        'date': 'Tous les samedis',
        'distance': '1,2 km',
        'image': 'assets/images/farmers_market.jpg',
      },
      {
        'title': 'Atelier de réparation communautaire',
        'location': 'Maison de Quartier Centre',
        'date': '15 juin, 14h-18h',
        'distance': '3,5 km',
        'image': 'assets/images/repair_shop.jpg',
      },
      {
        'title': 'Plantation d\'arbres urbains',
        'location': 'Parc Municipal',
        'date': '20 juin, 9h-12h',
        'distance': '2,8 km',
        'image': 'assets/images/tree_planting.jpg',
      },
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle('Initiatives près de chez vous'),
          const SizedBox(height: 16),
          ...initiatives.map((initiative) => _buildInitiativeCard(initiative)).toList(),
          
          const SizedBox(height: 24),
          _buildSectionTitle('Proposer une initiative'),
          const SizedBox(height: 8),
          Card(
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.primaryColor.withOpacity(0.2), width: 1),
            ),
            child: InkWell(
              onTap: () {
                // Naviguer vers la page de proposition d'initiative
                Get.toNamed('/propose-initiative');
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 24.0),
                child: Row(
                  children: [
                    Icon(Icons.add_location_alt_outlined, color: AppColors.primaryColor, size: 32),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ajouter une initiative locale',
                            style: AppStyles.subtitleStyle.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Partagez des événements et initiatives écologiques locales',
                            style: AppStyles.bodyStyle,
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.arrow_forward_ios, color: AppColors.textColor, size: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: AppStyles.subtitleStyle.copyWith(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  Widget _buildActivityCard(EcoActivity activity, bool isCommunity) {
    // Fonction pour déterminer la couleur en fonction du type d'activité
    Color getActivityColor(ActivityType type) {
      switch (type) {
        case ActivityType.transport:
          return Colors.blue[700]!;
        case ActivityType.food:
          return Colors.green[700]!;
        case ActivityType.energy:
          return Colors.amber[700]!;
        case ActivityType.waste:
          return Colors.orange[700]!;
        case ActivityType.community:
          return Colors.purple[700]!;
        default:
          return Colors.teal[700]!;
      }
    }

    // Fonction pour obtenir l'icône correspondante au type d'activité
    IconData getActivityIcon(ActivityType type) {
      switch (type) {
        case ActivityType.transport:
          return Icons.directions_bike;
        case ActivityType.food:
          return Icons.restaurant;
        case ActivityType.energy:
          return Icons.bolt;
        case ActivityType.waste:
          return Icons.delete;
        case ActivityType.community:
          return Icons.people;
        default:
          return Icons.eco;
      }
    }

    // Formatage de la date relative
    String getRelativeTime(DateTime timestamp) {
      final now = DateTime.now();
      final difference = now.difference(timestamp);

      if (difference.inDays > 0) {
        return 'il y a ${difference.inDays} jour${difference.inDays > 1 ? 's' : ''}';
      } else if (difference.inHours > 0) {
        return 'il y a ${difference.inHours} heure${difference.inHours > 1 ? 's' : ''}';
      } else if (difference.inMinutes > 0) {
        return 'il y a ${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''}';
      } else {
        return 'à l\'instant';
      }
    }

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la carte avec user info (simulé)
          ListTile(
            leading: CircleAvatar(
              backgroundColor: getActivityColor(activity.type),
              child: Icon(getActivityIcon(activity.type), color: Colors.white),
            ),
            title: Text(
              isCommunity ? 'Association Verte' : 'Marie Dupont', 
              style: AppStyles.subtitleStyle.copyWith(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              getRelativeTime(activity.timestamp),
              style: AppStyles.captionStyle,
            ),
            trailing: IconButton(
              icon: const Icon(Icons.more_vert),
              onPressed: () {
                // Ouvrir menu d'options
              },
            ),
          ),
          
          // Contenu de l'activité
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: AppStyles.subtitleStyle.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 8),
                Text(
                  activity.description,
                  style: AppStyles.bodyStyle,
                ),
                const SizedBox(height: 16),
                // Afficher des détails spécifiques si disponibles
                if (activity.additionalData.isNotEmpty && 
                    activity.additionalData.containsKey('participants') &&
                    activity.additionalData.containsKey('location'))
                  Wrap(
                    spacing: 16,
                    children: [
                      Chip(
                        backgroundColor: Colors.grey[200],
                        label: Text(
                          '${activity.additionalData['participants']} participants',
                          style: AppStyles.captionStyle,
                        ),
                      ),
                      Chip(
                        backgroundColor: Colors.grey[200],
                        label: Text(
                          '${activity.additionalData['location']}',
                          style: AppStyles.captionStyle,
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 8),
              ],
            ),
          ),
          
          // Pied de carte avec actions
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.thumb_up_alt_outlined),
                  label: const Text('J\'aime'),
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textColor,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.chat_bubble_outline),
                  label: const Text('Commenter'),
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textColor,
                  ),
                ),
                TextButton.icon(
                  icon: const Icon(Icons.share_outlined),
                  label: const Text('Partager'),
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.textColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChallengeCard(Map<String, dynamic> challenge) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          // Naviguer vers la page de détails du défi
          Get.toNamed('/challenge-details');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: challenge['color'],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: SvgPicture.asset(
                      challenge['icon'],
                      width: 24,
                      height: 24,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          challenge['title'],
                          style: AppStyles.subtitleStyle.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          challenge['description'],
                          style: AppStyles.bodyStyle,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${challenge['participants']} participants',
                    style: AppStyles.captionStyle.copyWith(
                      color: AppColors.textColor,
                    ),
                  ),
                  Text(
                    'Reste ${challenge['daysLeft']} jour${challenge['daysLeft'] > 1 ? 's' : ''}',
                    style: AppStyles.captionStyle.copyWith(
                      color: challenge['daysLeft'] <= 3 ? Colors.red[700] : Colors.orange[700],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () {
                  // Rejoindre le défi
                  Get.snackbar(
                    'Défi rejoint !',
                    'Vous participez maintenant au défi "${challenge['title']}"',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: AppColors.primaryColor,
                    colorText: Colors.white,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 40),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text('Rejoindre le défi'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInitiativeCard(Map<String, dynamic> initiative) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image d'en-tête
          Image.asset(
            initiative['image'],
            height: 150,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
          
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  initiative['title'],
                  style: AppStyles.subtitleStyle.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                
                // Lieu et distance
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${initiative['location']} (${initiative['distance']})',
                        style: AppStyles.captionStyle.copyWith(color: Colors.grey[700]),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                
                // Date
                Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      initiative['date'],
                      style: AppStyles.captionStyle.copyWith(color: Colors.grey[700]),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          // Ouvrir les détails de l'initiative
                          Get.toNamed('/initiative-details');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.primaryColor),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          'Plus d\'infos',
                          style: TextStyle(color: AppColors.primaryColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          // Participer à l'initiative
                          Get.snackbar(
                            'Intérêt enregistré !',
                            'Vous avez indiqué votre intérêt pour "${initiative['title']}"',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: AppColors.primaryColor,
                            colorText: Colors.white,
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text('Participer'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showShareActionSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Partager avec la communauté',
              style: AppStyles.titleStyle.copyWith(fontSize: 20),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: Icon(Icons.eco, color: Colors.green[700]),
              ),
              title: const Text('Action écologique'),
              subtitle: const Text('Partagez une activité que vous avez réalisée'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/share-activity');
              },
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.photo_camera, color: Colors.blue[700]),
              ),
              title: const Text('Photo écologique'),
              subtitle: const Text('Partagez une photo de votre initiative verte'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/share-photo');
              },
            ),
            const Divider(),
            ListTile(
              leading: CircleAvatar(
                backgroundColor: Colors.purple[100],
                child: Icon(Icons.event, color: Colors.purple[700]),
              ),
              title: const Text('Événement local'),
              subtitle: const Text('Proposez un événement dans votre communauté'),
              onTap: () {
                Navigator.pop(context);
                Get.toNamed('/create-event');
              },
            ),
          ],
        ),
      ),
    );
  }
} 