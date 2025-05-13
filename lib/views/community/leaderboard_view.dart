import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/services/eco_level_service.dart';
import 'package:greens_app/models/eco_level_model.dart';

class LeaderboardView extends StatefulWidget {
  const LeaderboardView({Key? key}) : super(key: key);

  @override
  State<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends State<LeaderboardView> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _leaderboard = [];
  int _userRanking = 0;
  
  @override
  void initState() {
    super.initState();
    _loadLeaderboardData();
  }
  
  Future<void> _loadLeaderboardData() async {
    setState(() {
      _isLoading = true;
    });
    
    final ecoLevelService = Provider.of<EcoLevelService>(context, listen: false);
    
    try {
      // Charger les 50 premiers utilisateurs du classement
      final leaderboard = await ecoLevelService.getLeaderboard(limit: 50);
      final userRanking = await ecoLevelService.getUserRanking();
      
      setState(() {
        _leaderboard = leaderboard;
        _userRanking = userRanking['rank'] as int? ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      
      // Afficher une erreur si le chargement échoue
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur lors du chargement du classement: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'Classement écologique',
          style: TextStyle(
            color: Color(0xFF1F3140),
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1F3140)),
            onPressed: _loadLeaderboardData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadLeaderboardData,
              color: const Color(0xFF4CAF50),
              child: _buildLeaderboardContent(),
            ),
    );
  }
  
  Widget _buildLeaderboardContent() {
    final ecoLevelService = Provider.of<EcoLevelService>(context, listen: false);
    final userId = ecoLevelService.currentUserId;
    
    return Column(
      children: [
        _buildLeaderboardHeader(),
        Expanded(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: _leaderboard.length,
            itemBuilder: (context, index) {
              final user = _leaderboard[index];
              final isCurrentUser = user['userId'] == userId;
              
              return _buildLeaderboardItem(
                user: user,
                rank: index + 1,
                isCurrentUser: isCurrentUser,
              );
            },
          ),
        ),
        
        // Afficher le rang de l'utilisateur s'il n'est pas dans le top 50
        if (_userRanking > 50 && userId != null)
          _buildUserRankingFooter()
      ],
    );
  }
  
  Widget _buildLeaderboardHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Classement des utilisateurs les plus écologiques',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1F3140),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              // Colonne pour le rang
              Expanded(
                flex: 1,
                child: Text(
                  'Rang',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              // Colonne pour l'utilisateur
              Expanded(
                flex: 3,
                child: Text(
                  'Utilisateur',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              // Colonne pour le niveau
              Expanded(
                flex: 3,
                child: Text(
                  'Niveau',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
              // Colonne pour les points
              Expanded(
                flex: 2,
                child: Text(
                  'Points',
                  textAlign: TextAlign.right,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required Map<String, dynamic> user,
    required int rank,
    required bool isCurrentUser,
  }) {
    final levelColorName = user['level'].toLowerCase();
    Color levelColor;
    
    switch (levelColorName) {
      case 'beginner':
        levelColor = Color(int.parse('FF4CAF50', radix: 16));
        break;
      case 'aware':
        levelColor = Color(int.parse('FF009688', radix: 16));
        break;
      case 'engaged':
        levelColor = Color(int.parse('FF00796B', radix: 16));
        break;
      case 'ambassador':
        levelColor = Color(int.parse('FF2E7D32', radix: 16));
        break;
      case 'expert':
        levelColor = Color(int.parse('FF1B5E20', radix: 16));
        break;
      default:
        levelColor = Color(int.parse('FF4CAF50', radix: 16));
    }
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? levelColor.withOpacity(0.1) 
            : (rank <= 3 ? Colors.amber.withOpacity(0.05) : Colors.white),
        borderRadius: BorderRadius.circular(8),
        border: isCurrentUser
            ? Border.all(color: levelColor.withOpacity(0.5))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        children: [
          // Rang
          Expanded(
            flex: 1,
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: rank <= 3 
                    ? [Colors.amber, Colors.grey.shade300, Colors.brown.shade300][rank - 1].withOpacity(0.2)
                    : Colors.grey.shade200,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$rank',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: rank <= 3 
                        ? [Colors.amber.shade800, Colors.grey.shade700, Colors.brown.shade700][rank - 1]
                        : Colors.grey.shade700,
                  ),
                ),
              ),
            ),
          ),
          
          // Utilisateur
          Expanded(
            flex: 3,
            child: Row(
              children: [
                if (user['photoURL'] != null)
                  CircleAvatar(
                    radius: 16,
                    backgroundImage: NetworkImage(user['photoURL']),
                  )
                else
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey.shade300,
                    child: Text(
                      user['username'].substring(0, 1).toUpperCase(),
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user['username'],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      color: isCurrentUser ? levelColor : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Niveau
          Expanded(
            flex: 3,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    color: levelColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    user['levelTitle'],
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Points
          Expanded(
            flex: 2,
            child: Text(
              '${user['points']} pts',
              textAlign: TextAlign.right,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isCurrentUser ? levelColor : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildUserRankingFooter() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        border: Border(
          top: BorderSide(
            color: const Color(0xFF4CAF50).withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.emoji_events,
            color: Color(0xFF4CAF50),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Votre position dans le classement: ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          Text(
            '$_userRanking',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF4CAF50),
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
} 