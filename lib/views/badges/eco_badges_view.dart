import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/eco_badge_controller.dart';
import 'package:greens_app/models/eco_badge.dart';
import 'package:greens_app/widgets/app_bar_with_back_button.dart';
import 'package:greens_app/widgets/eco_progress_indicator.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

class EcoBadgesView extends StatefulWidget {
  const EcoBadgesView({Key? key}) : super(key: key);

  @override
  State<EcoBadgesView> createState() => _EcoBadgesViewState();
}

class _EcoBadgesViewState extends State<EcoBadgesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    // Créer un contrôleur d'onglets avec le nombre de catégories de badges
    _tabController = TabController(
      length: BadgeCategory.values.length,
      vsync: this,
    );
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBarWithBackButton(
        title: 'Mes Badges Écologiques',
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showBadgesInfo(context),
          ),
        ],
      ),
      body: Consumer<EcoBadgeController>(
        builder: (context, badgeController, child) {
          return Column(
            children: [
              // Résumé des badges
              _buildBadgeSummary(badgeController),
              
              // Onglets pour les catégories de badges
              TabBar(
                controller: _tabController,
                isScrollable: true,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: BadgeCategory.values.map((category) {
                  final badge = badgeController.getBadgesByCategory(category).first;
                  return Tab(
                    icon: Icon(badge.categoryIcon),
                    text: _getCategoryName(category),
                  );
                }).toList(),
              ),
              
              // Contenu des onglets
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: BadgeCategory.values.map((category) {
                    return _buildCategoryBadges(badgeController, category);
                  }).toList(),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
  
  /// Construire le résumé des badges
  Widget _buildBadgeSummary(EcoBadgeController controller) {
    final unlockedCount = controller.totalUnlockedBadges;
    final totalCount = controller.totalBadges;
    final progress = controller.overallProgressPercentage / 100;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Votre progression',
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '$unlockedCount / $totalCount badges',
                style: TextStyle(
                  fontSize: 16.0,
                  color: Theme.of(context).primaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16.0),
          LinearPercentIndicator(
            lineHeight: 14.0,
            percent: progress,
            backgroundColor: Colors.grey.shade200,
            progressColor: Theme.of(context).primaryColor,
            barRadius: const Radius.circular(7.0),
            padding: EdgeInsets.zero,
            animation: true,
            animationDuration: 1000,
          ),
          if (controller.recentlyUnlockedBadges.isNotEmpty) ...[
            const SizedBox(height: 16.0),
            const Text(
              'Badges récemment débloqués',
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            SizedBox(
              height: 80.0,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: controller.recentlyUnlockedBadges.length,
                itemBuilder: (context, index) {
                  final badge = controller.recentlyUnlockedBadges[index];
                  return Padding(
                    padding: const EdgeInsets.only(right: 12.0),
                    child: _buildRecentBadgeItem(badge),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  /// Construire un élément de badge récent
  Widget _buildRecentBadgeItem(EcoBadge badge) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(context, badge),
      child: Column(
        children: [
          CircleAvatar(
            radius: 30.0,
            backgroundColor: badge.levelColor,
            child: Icon(
              badge.categoryIcon,
              color: Colors.white,
              size: 24.0,
            ),
          ),
          const SizedBox(height: 4.0),
          Text(
            badge.title.split(' - ').last,
            style: const TextStyle(fontSize: 12.0),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
  
  /// Construire la liste des badges pour une catégorie
  Widget _buildCategoryBadges(EcoBadgeController controller, BadgeCategory category) {
    final badges = controller.getBadgesByCategory(category);
    
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Progression de la catégorie
          _buildCategoryProgress(controller, category),
          const SizedBox(height: 16.0),
          
          // Liste des badges
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16.0,
                mainAxisSpacing: 16.0,
                childAspectRatio: 0.85,
              ),
              itemCount: badges.length,
              itemBuilder: (context, index) {
                return _buildBadgeCard(badges[index]);
              },
            ),
          ),
        ],
      ),
    );
  }
  
  /// Construire la progression d'une catégorie
  Widget _buildCategoryProgress(EcoBadgeController controller, BadgeCategory category) {
    final nextBadge = controller.getNextBadgeForCategory(category);
    final progress = controller.getProgressPercentageForNextBadge(category) / 100;
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          CircularPercentIndicator(
            radius: 35.0,
            lineWidth: 8.0,
            percent: progress,
            center: Icon(
              _getCategoryIcon(category),
              color: Theme.of(context).primaryColor,
            ),
            progressColor: Theme.of(context).primaryColor,
            backgroundColor: Colors.grey.shade200,
            circularStrokeCap: CircularStrokeCap.round,
            animation: true,
            animationDuration: 1000,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _getCategoryName(category),
                  style: const TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                if (nextBadge != null)
                  Text(
                    'Prochain badge: ${nextBadge.title.split(' - ').last}',
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                  )
                else
                  const Text(
                    'Tous les badges débloqués !',
                    style: TextStyle(
                      fontSize: 14.0,
                      color: Colors.green,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                const SizedBox(height: 4.0),
                if (nextBadge != null)
                  Text(
                    '${nextBadge.progress} / ${nextBadge.threshold} points',
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Theme.of(context).primaryColor,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  /// Construire une carte de badge
  Widget _buildBadgeCard(EcoBadge badge) {
    return GestureDetector(
      onTap: () => _showBadgeDetails(context, badge),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: badge.isUnlocked
              ? Border.all(color: badge.levelColor, width: 2.0)
              : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                CircleAvatar(
                  radius: 40.0,
                  backgroundColor: badge.isUnlocked
                      ? badge.levelColor
                      : Colors.grey.shade300,
                  child: Icon(
                    badge.categoryIcon,
                    color: Colors.white,
                    size: 32.0,
                  ),
                ),
                if (!badge.isUnlocked)
                  const CircleAvatar(
                    radius: 40.0,
                    backgroundColor: Colors.black38,
                    child: Icon(
                      Icons.lock,
                      color: Colors.white,
                      size: 24.0,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12.0),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text(
                badge.title.split(' - ').last,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.bold,
                  color: badge.isUnlocked
                      ? Colors.black87
                      : Colors.grey,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4.0),
            if (!badge.isUnlocked) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: LinearPercentIndicator(
                  lineHeight: 6.0,
                  percent: badge.progressPercentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  progressColor: Colors.grey.shade500,
                  barRadius: const Radius.circular(3.0),
                  padding: EdgeInsets.zero,
                ),
              ),
              const SizedBox(height: 4.0),
              Text(
                '${badge.progress} / ${badge.threshold}',
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Colors.grey,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  /// Afficher les détails d'un badge
  void _showBadgeDetails(BuildContext context, EcoBadge badge) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 50.0,
                backgroundColor: badge.isUnlocked
                    ? badge.levelColor
                    : Colors.grey.shade300,
                child: Icon(
                  badge.categoryIcon,
                  color: Colors.white,
                  size: 40.0,
                ),
              ),
              const SizedBox(height: 16.0),
              Text(
                badge.title,
                style: const TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8.0),
              Text(
                badge.description,
                style: const TextStyle(
                  fontSize: 16.0,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16.0),
              if (badge.isUnlocked) ...[
                const Text(
                  'Badge débloqué !',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                if (badge.earnedDate != null)
                  Text(
                    'Obtenu le ${_formatDate(badge.earnedDate!)}',
                    style: const TextStyle(
                      fontSize: 14.0,
                      color: Colors.grey,
                    ),
                  ),
              ] else ...[
                const Text(
                  'Progression',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                LinearPercentIndicator(
                  lineHeight: 10.0,
                  percent: badge.progressPercentage / 100,
                  backgroundColor: Colors.grey.shade200,
                  progressColor: Theme.of(context).primaryColor,
                  barRadius: const Radius.circular(5.0),
                  padding: EdgeInsets.zero,
                  center: Text(
                    '${badge.progress} / ${badge.threshold}',
                    style: const TextStyle(
                      fontSize: 12.0,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                Text(
                  'Il vous manque ${badge.threshold - badge.progress} points pour débloquer ce badge',
                  style: const TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32.0,
                    vertical: 12.0,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0),
                  ),
                ),
                child: const Text('Fermer'),
              ),
            ],
          ),
        );
      },
    );
  }
  
  /// Afficher les informations sur les badges
  void _showBadgesInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('À propos des badges'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Les badges écologiques sont une façon de suivre et de récompenser vos actions en faveur de l\'environnement.',
                  style: TextStyle(fontSize: 16.0),
                ),
                const SizedBox(height: 16.0),
                const Text(
                  'Catégories de badges :',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                ...BadgeCategory.values.map((category) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Icon(_getCategoryIcon(category)),
                        const SizedBox(width: 8.0),
                        Text(
                          _getCategoryName(category),
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  );
                }).toList(),
                const SizedBox(height: 16.0),
                const Text(
                  'Niveaux de badges :',
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8.0),
                ...BadgeLevel.values.map((level) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8.0),
                    child: Row(
                      children: [
                        Container(
                          width: 24.0,
                          height: 24.0,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _getLevelColor(level),
                          ),
                        ),
                        const SizedBox(width: 8.0),
                        Text(
                          _getLevelName(level),
                          style: const TextStyle(fontSize: 14.0),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fermer'),
            ),
          ],
        );
      },
    );
  }
  
  /// Obtenir le nom d'une catégorie
  String _getCategoryName(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.dailyActions:
        return 'Actions Quotidiennes';
      case BadgeCategory.consumption:
        return 'Consommation';
      case BadgeCategory.mobility:
        return 'Mobilité';
      case BadgeCategory.community:
        return 'Communauté';
      case BadgeCategory.special:
        return 'Spécial';
    }
  }
  
  /// Obtenir l'icône d'une catégorie
  IconData _getCategoryIcon(BadgeCategory category) {
    switch (category) {
      case BadgeCategory.dailyActions:
        return Icons.eco;
      case BadgeCategory.consumption:
        return Icons.shopping_basket;
      case BadgeCategory.mobility:
        return Icons.directions_bike;
      case BadgeCategory.community:
        return Icons.people;
      case BadgeCategory.special:
        return Icons.star;
    }
  }
  
  /// Obtenir le nom d'un niveau
  String _getLevelName(BadgeLevel level) {
    switch (level) {
      case BadgeLevel.beginner:
        return 'Débutant';
      case BadgeLevel.intermediate:
        return 'Intermédiaire';
      case BadgeLevel.advanced:
        return 'Avancé';
      case BadgeLevel.expert:
        return 'Expert';
    }
  }
  
  /// Obtenir la couleur d'un niveau
  Color _getLevelColor(BadgeLevel level) {
    switch (level) {
      case BadgeLevel.beginner:
        return Colors.green.shade300;
      case BadgeLevel.intermediate:
        return Colors.blue.shade300;
      case BadgeLevel.advanced:
        return Colors.amber.shade300;
      case BadgeLevel.expert:
        return Colors.purple.shade300;
    }
  }
  
  /// Formater une date
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
