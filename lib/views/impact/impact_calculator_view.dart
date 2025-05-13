import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/widgets/instant_impact_calculator.dart';

class ImpactCalculatorView extends StatelessWidget {
  const ImpactCalculatorView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Calculateur d\'impact'),
        backgroundColor: AppColors.primaryColor,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: 20),
                const InstantImpactCalculator(),
                const SizedBox(height: 20),
                _buildAdditionalInfo(),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Mesurez votre impact écologique',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Calculez l\'impact de vos actions quotidiennes sur l\'environnement et découvrez comment les réduire.',
          style: TextStyle(
            fontSize: 16,
            color: AppColors.textSecondaryColor,
          ),
        ),
      ],
    );
  }
  
  Widget _buildAdditionalInfo() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pourquoi calculer son impact ?',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 16),
            _buildInfoItem(
              icon: Icons.analytics_outlined,
              title: 'Prendre conscience',
              description: 'Visualisez l\'impact réel de vos actions quotidiennes sur l\'environnement.',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.trending_down,
              title: 'Réduire votre empreinte',
              description: 'Identifiez les domaines où vous pouvez facilement réduire votre impact écologique.',
            ),
            const SizedBox(height: 12),
            _buildInfoItem(
              icon: Icons.track_changes,
              title: 'Suivre vos progrès',
              description: 'Mesurez vos progrès au fil du temps et voyez l\'impact positif de vos changements d\'habitudes.',
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
            Text(
              'Méthodologie',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Nos calculs sont basés sur des données scientifiques provenant de sources reconnues comme l\'ADEME, le GIEC et des études universitaires. Les facteurs d\'émission sont régulièrement mis à jour pour garantir la précision des estimations.',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textSecondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildInfoItem({required IconData icon, required String title, required String description}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: AppColors.accentColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppColors.accentColor,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textColor,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textSecondaryColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
} 