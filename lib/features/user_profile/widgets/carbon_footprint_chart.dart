import 'package:flutter/material.dart';

class CarbonFootprintChart extends StatelessWidget {
  final Map<String, double>? data;

  const CarbonFootprintChart({
    Key? key,
    this.data,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Données fictives de démonstration si aucune donnée n'est fournie
    final chartData = data ?? {
      'Transport': 2.3,
      'Alimentation': 1.8,
      'Logement': 1.5,
      'Numérique': 0.5,
      'Autres': 0.8,
    };

    // Calcul du total
    final total = chartData.values.fold<double>(0, (sum, value) => sum + value);

    // Préparation des données pour le graphique
    final entries = chartData.entries.toList();
    
    // Couleurs pour les différentes catégories
    final Map<String, Color> categoryColors = {
      'Transport': Colors.blue,
      'Alimentation': Colors.green,
      'Logement': Colors.orange,
      'Numérique': Colors.purple,
      'Autres': Colors.grey,
    };
    
    // Index pour les couleurs de secours
    int colorIndex = 0;
    final defaultColors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.indigo,
      Colors.amber,
    ];
    
    return Column(
      children: [
        // En-tête
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Text(
            'Répartition de votre empreinte carbone',
            style: Theme.of(context).textTheme.titleMedium,
            textAlign: TextAlign.center,
          ),
        ),
        
        // Barres horizontales pour chaque catégorie
        ...entries.map((entry) {
          final percentage = (entry.value / total) * 100;
          final color = categoryColors[entry.key] ?? 
              defaultColors[colorIndex++ % defaultColors.length];
          
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 4.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '${entry.value.toStringAsFixed(1)} t',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.value / total,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    minHeight: 8,
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: Text(
                    '${percentage.toStringAsFixed(1)}%',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        
        // Footer avec total
        Padding(
          padding: const EdgeInsets.only(top: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TOTAL',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                '${total.toStringAsFixed(1)} t CO₂e/an',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
