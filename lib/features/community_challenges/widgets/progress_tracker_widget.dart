import 'package:flutter/material.dart';

class ProgressTrackerWidget extends StatelessWidget {
  final double progress;
  final int totalDays;
  final int daysPassed;
  
  const ProgressTrackerWidget({
    Key? key, 
    required this.progress,
    required this.totalDays,
    required this.daysPassed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Barre de progression
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 16,
            backgroundColor: Colors.grey[200],
            valueColor: const AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        const SizedBox(height: 8),
        
        // Pourcentage
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '${(progress * 100).round()}% complété',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            Text(
              '$daysPassed sur $totalDays jours',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
        
        // Représentation visuelle des jours du défi
        if (totalDays <= 30) ...[
          const SizedBox(height: 16),
          _buildDaysGrid(),
        ],
      ],
    );
  }
  
  Widget _buildDaysGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7, // Une semaine
        childAspectRatio: 1,
        crossAxisSpacing: 5,
        mainAxisSpacing: 5,
      ),
      itemCount: totalDays,
      itemBuilder: (context, index) {
        // Jour actuel
        final isCurrentDay = index == daysPassed - 1;
        // Jour passé
        final isPastDay = index < daysPassed;
        
        return Container(
          decoration: BoxDecoration(
            color: isPastDay ? Colors.green : Colors.grey[200],
            borderRadius: BorderRadius.circular(4),
            border: isCurrentDay ? Border.all(color: Colors.blue, width: 2) : null,
          ),
          child: Center(
            child: Text(
              '${index + 1}',
              style: TextStyle(
                color: isPastDay ? Colors.white : Colors.black,
                fontWeight: isCurrentDay ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }
} 