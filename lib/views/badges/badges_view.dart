import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/eco_badge_controller.dart';
import 'package:greens_app/models/eco_badge.dart';

class BadgesView extends StatefulWidget {
  final String userId;
  
  const BadgesView({Key? key, required this.userId}) : super(key: key);

  @override
  _BadgesViewState createState() => _BadgesViewState();
}

class _BadgesViewState extends State<BadgesView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: BadgeCategory.values.length + 1, vsync: this);
    
    // Load user badges
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<EcoBadgeController>().getUserBadges(widget.userId);
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
      appBar: AppBar(
        title: const Text('My Eco Badges'),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            const Tab(text: 'All'),
            ...BadgeCategory.values.map((category) {
              final categoryName = category.toString().split('.').last;
              return Tab(text: categoryName);
            }).toList(),
          ],
        ),
      ),
      body: Consumer<EcoBadgeController>(
        builder: (context, badgeController, child) {
          if (badgeController.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (badgeController.userBadges.isEmpty) {
            return const Center(
              child: Text(
                'You haven\'t earned any badges yet.\nComplete eco goals to earn badges!',
                textAlign: TextAlign.center,
              ),
            );
          }
          
          return TabBarView(
            controller: _tabController,
            children: [
              // All badges
              _buildBadgeGrid(badgeController.userBadges),
              
              // Category-specific badges
              ...BadgeCategory.values.map((category) {
                final categoryBadges = badgeController.getBadgesByCategory(category);
                return _buildBadgeGrid(categoryBadges);
              }).toList(),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildBadgeGrid(List<EcoBadge> badges) {
    if (badges.isEmpty) {
      return const Center(
        child: Text('No badges in this category yet.'),
      );
    }
    
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: badges.length,
      itemBuilder: (context, index) {
        final badge = badges[index];
        return _buildBadgeCard(badge);
      },
    );
  }
  
  Widget _buildBadgeCard(EcoBadge badge) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: Color(int.parse(badge.badgeColor.substring(1, 7), radix: 16) + 0xFF000000),
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: () => _showBadgeDetails(badge),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              badge.imageUrl.isNotEmpty
                ? Image.asset(
                    badge.imageUrl,
                    height: 80,
                    width: 80,
                  )
                : Icon(
                    badge.categoryIcon,
                    size: 80,
                    color: Colors.grey,
                  ),
              const SizedBox(height: 12),
              Text(
                badge.title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 4),
              Text(
                '${badge.pointsAwarded} points',
                style: const TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Earned: ${badge.earnedDate != null ? _formatDate(badge.earnedDate!) : "Not earned yet"}',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  
  void _showBadgeDetails(EcoBadge badge) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(badge.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            badge.imageUrl.isNotEmpty
              ? Image.asset(
                  badge.imageUrl,
                  height: 100,
                  width: 100,
                )
              : Icon(
                  badge.categoryIcon,
                  size: 100,
                  color: Colors.grey,
                ),
            const SizedBox(height: 16),
            Text(badge.description),
            const SizedBox(height: 8),
            Text(
              'Category: ${badge.category.toString().split('.').last}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Level: ${badge.level.toString().split('.').last}',
              style: const TextStyle(color: Colors.grey),
            ),
            Text(
              'Points: ${badge.pointsAwarded}',
              style: const TextStyle(color: Colors.green),
            ),
            Text(
              'Earned on: ${badge.earnedDate != null ? _formatDate(badge.earnedDate!, includeTime: true) : "Not earned yet"}',
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              final badgeController = context.read<EcoBadgeController>();
              badgeController.toggleBadgeDisplay(
                badge.id, 
                !badge.isDisplayedOnProfile
              );
              Navigator.of(context).pop();
            },
            child: Text(
              badge.isDisplayedOnProfile 
                ? 'Hide from Profile' 
                : 'Show on Profile'
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
  
  String _formatDate(DateTime date, {bool includeTime = false}) {
    if (includeTime) {
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
    }
    return '${date.day}/${date.month}/${date.year}';
  }
}