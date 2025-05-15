import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';

class LeaderboardEntry {
  final String id;
  final String name;
  final String avatarUrl;
  final int score;
  final int rank;

  LeaderboardEntry({
    required this.id,
    required this.name,
    required this.avatarUrl,
    required this.score,
    required this.rank,
  });
}

class LeaderboardWidget extends StatelessWidget {
  final List<LeaderboardEntry> entries;
  final String title;
  final String scoreLabel;
  final bool showTrophies;
  
  const LeaderboardWidget({
    Key? key, 
    required this.entries,
    this.title = 'Classement',
    this.scoreLabel = 'points',
    this.showTrophies = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events),
                  const SizedBox(width: 8),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18, 
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            if (entries.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Center(
                  child: Text('Aucune donnée disponible'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: entries.length,
                itemBuilder: (context, index) {
                  final entry = entries[index];
                  return _buildLeaderboardItem(context, entry);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem(BuildContext context, LeaderboardEntry entry) {
    Widget rankWidget;
    
    if (showTrophies && entry.rank <= 3) {
      IconData trophyIcon;
      Color trophyColor;
      
      switch (entry.rank) {
        case 1:
          trophyIcon = Icons.emoji_events;
          trophyColor = Colors.amber;
          break;
        case 2:
          trophyIcon = Icons.emoji_events;
          trophyColor = Colors.grey.shade400;
          break;
        case 3:
          trophyIcon = Icons.emoji_events;
          trophyColor = Colors.brown.shade300;
          break;
        default:
          trophyIcon = Icons.emoji_events;
          trophyColor = Colors.transparent;
      }
      
      rankWidget = Icon(
        trophyIcon,
        color: trophyColor,
        size: 24,
      );
    } else {
      rankWidget = Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primaryColor.withOpacity(0.1),
        ),
        child: Center(
          child: Text(
            '${entry.rank}',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: AppColors.primaryColor,
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          rankWidget,
          const SizedBox(width: 12),
          CircleAvatar(
            backgroundImage: AssetImage(entry.avatarUrl),
            radius: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              '${entry.score} $scoreLabel',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }
} 