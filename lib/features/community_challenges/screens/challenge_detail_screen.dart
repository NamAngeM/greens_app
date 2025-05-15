import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../controllers/community_challenge_controller.dart';
import '../widgets/progress_tracker_widget.dart';
import 'package:confetti/confetti.dart';
import 'package:greens_app/utils/app_colors.dart';

class ChallengeDetailScreen extends StatefulWidget {
  final Challenge challenge;
  
  const ChallengeDetailScreen({
    Key? key,
    required this.challenge,
  }) : super(key: key);

  @override
  State<ChallengeDetailScreen> createState() => _ChallengeDetailScreenState();
}

class _ChallengeDetailScreenState extends State<ChallengeDetailScreen> {
  late ConfettiController _confettiController;
  
  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(duration: const Duration(seconds: 3));
  }
  
  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.challenge.startDate.isBefore(DateTime.now()) && 
                    widget.challenge.endDate.isAfter(DateTime.now());
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du défi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // Fonctionnalité de partage
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Fonctionnalité de partage à implémenter'))
              );
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image du défi
                SizedBox(
                  height: 200,
                  width: double.infinity,
                  child: widget.challenge.imageUrl.isEmpty
                      ? Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.eco, size: 80, color: Colors.white),
                        )
                      : Image.asset(
                          widget.challenge.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stack) => Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.broken_image, size: 80, color: Colors.white),
                          ),
                        ),
                ),
                
                // Badge de statut
                if (isActive)
                  Positioned(
                    top: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.green,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Text(
                        'En cours',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                
                // Informations du défi
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.challenge.title,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      
                      // Dates du défi
                      Row(
                        children: [
                          const Icon(Icons.date_range, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            '${DateFormat('dd/MM/yyyy').format(widget.challenge.startDate)} - ${DateFormat('dd/MM/yyyy').format(widget.challenge.endDate)}',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      
                      // Participants
                      Row(
                        children: [
                          const Icon(Icons.people, size: 18, color: Colors.grey),
                          const SizedBox(width: 8),
                          Text(
                            '${widget.challenge.participants} participants',
                            style: TextStyle(
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 16),
                      const Divider(),
                      const SizedBox(height: 16),
                      
                      // Description
                      const Text(
                        'Description',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.challenge.description,
                        style: const TextStyle(fontSize: 16),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Récompenses
                      const Text(
                        'Récompenses',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildRewardsList(widget.challenge.rewards),
                      
                      const SizedBox(height: 24),
                      
                      // Top participants
                      if (widget.challenge.topParticipants.isNotEmpty) ...[
                        const Text(
                          'Top participants',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _buildTopParticipantsList(widget.challenge.topParticipants),
                        
                        const SizedBox(height: 24),
                      ],
                      
                      // Impact environnemental
                      const Text(
                        'Impact environnemental',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildEnvironmentalImpact(widget.challenge.totalCarbonSaved),
                      
                      const SizedBox(height: 32),
                      
                      // Bouton pour rejoindre ou voir sa progression
                      widget.challenge.isJoined
                          ? _buildProgressSection()
                          : _buildJoinButton(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Effet de confetti
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              maxBlastForce: 5,
              minBlastForce: 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.1,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildRewardsList(List<String> rewards) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: rewards.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              const Icon(Icons.emoji_events, color: Colors.amber),
              const SizedBox(width: 8),
              Expanded(child: Text(rewards[index])),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildTopParticipantsList(List<Participant> participants) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: participants.length,
      itemBuilder: (context, index) {
        final participant = participants[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundImage: AssetImage(participant.avatarUrl),
                onBackgroundImageError: (_, __) {},
                child: participant.avatarUrl.isEmpty
                    ? Text(participant.name[0],
                        style: const TextStyle(fontWeight: FontWeight.bold))
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  participant.name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                '${participant.points} pts',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(width: 4),
              _buildRankBadge(participant.rank),
            ],
          ),
        );
      },
    );
  }
  
  Widget _buildRankBadge(int rank) {
    Color color;
    
    switch (rank) {
      case 1:
        color = Colors.amber;
        break;
      case 2:
        color = Colors.grey[300]!;
        break;
      case 3:
        color = Colors.brown;
        break;
      default:
        color = Colors.grey[400]!;
    }
    
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          rank.toString(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
  
  Widget _buildEnvironmentalImpact(int carbonSaved) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green[100]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.nature, color: Colors.green),
              const SizedBox(width: 8),
              const Text(
                'Réduction des émissions CO2',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ce défi a permis d\'économiser $carbonSaved kg de CO2',
            style: const TextStyle(fontSize: 14),
          ),
          if (carbonSaved > 0) ...[
            const SizedBox(height: 16),
            const Text(
              'Équivalences :',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text('🚗 ${(carbonSaved / 120).toStringAsFixed(1)} trajets de 100 km en voiture'),
            Text('🌲 ${(carbonSaved / 25).toStringAsFixed(1)} arbres plantés (absorption annuelle)'),
            Text('💡 ${(carbonSaved * 300).toStringAsFixed(0)} heures d\'ampoule LED'),
          ],
        ],
      ),
    );
  }
  
  Widget _buildProgressSection() {
    // Simuler des tâches pour l'exemple
    final List<String> tasks = [
      'Utiliser des sacs réutilisables',
      'Éviter les produits à usage unique',
      'Cuisiner des repas sans déchets plastiques',
      'Utiliser des contenants réutilisables',
      'Partager une photo de votre démarche'
    ];
    
    // Simuler que seulement certaines tâches sont complétées
    final List<bool> completedTasks = [true, true, false, false, false];
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Votre progression',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        ProgressTrackerWidget(
          progress: 0.4, // 40% de progression
          totalDays: widget.challenge.endDate.difference(widget.challenge.startDate).inDays,
          daysPassed: DateTime.now().difference(widget.challenge.startDate).inDays,
        ),
        const SizedBox(height: 24),
        
        const Text(
          'Objectifs à atteindre',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return CheckboxListTile(
              title: Text(tasks[index]),
              value: completedTasks[index],
              activeColor: Colors.green,
              onChanged: (bool? value) {
                // Dans un cas réel, cette action mettrait à jour l'état sur le serveur
                setState(() {
                  completedTasks[index] = value ?? false;
                  
                  // Si toutes les tâches sont complétées, déclencher la célébration
                  if (completedTasks.every((task) => task)) {
                    _confettiController.play();
                  }
                });
              },
            );
          },
        ),
        
        // Bouton pour marquer le défi comme terminé
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: completedTasks.every((task) => task)
                ? () {
                    // Logique pour marquer le défi comme complété
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Félicitations ! Vous avez terminé ce défi.'),
                        backgroundColor: Colors.green,
                      ),
                    );
                    _confettiController.play();
                  }
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              backgroundColor: Colors.green,
              disabledBackgroundColor: Colors.grey[300],
              disabledForegroundColor: Colors.grey[700],
            ),
            child: const Text(
              'Valider le défi',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildJoinButton(BuildContext context) {
    final challengeController = Provider.of<CommunityChallengeController>(context, listen: false);
    final isActive = widget.challenge.startDate.isBefore(DateTime.now()) && 
                    widget.challenge.endDate.isAfter(DateTime.now());
    
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isActive
            ? () async {
                try {
                  await challengeController.toggleJoinChallenge(widget.challenge.id);
                  
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vous avez rejoint ce défi !'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Erreur: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              }
            : null,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 12),
          backgroundColor: AppColors.primaryColor,
          disabledBackgroundColor: Colors.grey[300],
          disabledForegroundColor: Colors.grey[700],
        ),
        child: Text(
          isActive
              ? 'Rejoindre le défi'
              : widget.challenge.startDate.isAfter(DateTime.now())
                  ? 'Ce défi n\'a pas encore commencé'
                  : 'Ce défi est terminé',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
} 