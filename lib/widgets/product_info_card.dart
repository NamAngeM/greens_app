import 'package:flutter/material.dart';

class ProductInfoCard extends StatelessWidget {
  final Map<String, dynamic> productInfo;
  final VoidCallback onScanAgain;

  const ProductInfoCard({
    Key? key,
    required this.productInfo,
    required this.onScanAgain,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        productInfo['name'],
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        productInfo['brand'],
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                _buildEcoScore(productInfo['ecoScore']),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              productInfo['description'],
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            _buildImpactSection(context),
            const SizedBox(height: 24),
            _buildAlternativesSection(context),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton.icon(
                onPressed: onScanAgain,
                icon: const Icon(Icons.refresh),
                label: const Text('Scanner un autre produit'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoScore(String score) {
    Color scoreColor;
    switch (score) {
      case 'A':
        scoreColor = Colors.green;
        break;
      case 'B':
        scoreColor = Colors.lightGreen;
        break;
      case 'C':
        scoreColor = Colors.orange;
        break;
      case 'D':
        scoreColor = Colors.deepOrange;
        break;
      case 'E':
        scoreColor = Colors.red;
        break;
      default:
        scoreColor = Colors.grey;
    }

    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: scoreColor,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(
          score,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildImpactSection(BuildContext context) {
    final impact = productInfo['impact'] as Map<String, dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Impact Environnemental',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildImpactItem(
              context,
              'Carbone',
              impact['carbon'],
              Icons.cloud,
            ),
            _buildImpactItem(
              context,
              'Eau',
              impact['water'],
              Icons.water_drop,
            ),
            _buildImpactItem(
              context,
              'Déchets',
              impact['waste'],
              Icons.delete,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImpactItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
  ) {
    return Column(
      children: [
        Icon(icon, size: 32, color: Colors.grey[600]),
        const SizedBox(height: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativesSection(BuildContext context) {
    final alternatives = productInfo['alternatives'] as List<dynamic>;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alternatives Écologiques',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        ...alternatives.map((alt) => Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Row(
            children: [
              const Icon(Icons.eco, color: Colors.green),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alt.toString(),
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }
} 