import 'package:flutter/material.dart';
import '../models/product.dart';
import '../widgets/eco_score_indicator.dart';
import '../widgets/transport_footprint_widget.dart';
import '../widgets/carbon_footprint_widget.dart';
import '../widgets/water_footprint_widget.dart';
import '../widgets/digital_footprint_widget.dart';
import '../widgets/sound_pollution_widget.dart';

class ProductDetailsScreen extends StatelessWidget {
  final Product product;

  const ProductDetailsScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(product.name),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image du produit
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                product.imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[200],
                  child: Center(
                    child: Icon(Icons.image_not_supported, size: 64, color: Colors.grey),
                  ),
                ),
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Informations de base du produit
                  Text(
                    product.name,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(
                    product.brand,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  Text(
                    product.category,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Indicateur d'Eco Score
                  Text(
                    'Impact Environnemental',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Center(child: EcoScoreIndicator(score: product.ecoScore)),
                  
                  const SizedBox(height: 24),
                  
                  // Détails de l'impact environnemental
                  _buildEnvironmentalImpactSection(context),
                  
                  const SizedBox(height: 24),
                  
                  // Liste des ingrédients
                  Text(
                    'Ingrédients',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  ...product.ingredients.map((ingredient) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4.0),
                    child: Row(
                      children: [
                        Icon(Icons.fiber_manual_record, size: 8, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Expanded(child: Text(ingredient)),
                      ],
                    ),
                  )),
                  
                  const SizedBox(height: 24),
                  
                  // Alternatives plus écologiques
                  Text(
                    'Alternatives plus écologiques',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  _buildAlternativesSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEnvironmentalImpactSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (product.environmentalImpact['carbonFootprint'] != null)
          CarbonFootprintWidget(
            emissions: product.environmentalImpact['carbonFootprint'],
            productType: product.category,
          ),
        
        if (product.environmentalImpact['waterUsage'] != null)
          WaterFootprintWidget(
            liters: product.environmentalImpact['waterUsage'],
            productCategory: product.category,
          ),
        
        if (product.environmentalImpact['transportDistance'] != null &&
            product.environmentalImpact['transportType'] != null &&
            product.environmentalImpact['origin'] != null)
          TransportFootprintWidget(
            distance: product.environmentalImpact['transportDistance'],
            transportType: product.environmentalImpact['transportType'],
            origin: product.environmentalImpact['origin'],
          ),
          
        if (product.environmentalImpact['digitalEmissions'] != null &&
            product.environmentalImpact['dataUsage'] != null &&
            product.environmentalImpact['serverLocation'] != null)
          DigitalFootprintWidget(
            digitalEmissions: product.environmentalImpact['digitalEmissions'],
            dataUsage: product.environmentalImpact['dataUsage'],
            serverLocation: product.environmentalImpact['serverLocation'],
          ),
          
        if (product.environmentalImpact['soundLevel'] != null &&
            product.environmentalImpact['deviceType'] != null)
          SoundPollutionWidget(
            decibelLevel: product.environmentalImpact['soundLevel'],
            deviceType: product.environmentalImpact['deviceType'],
            hasNoiseReduction: product.environmentalImpact['hasNoiseReduction'] ?? false,
          ),
          
        Card(
          elevation: 2,
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Caractéristiques environnementales',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 12),
                
                Row(
                  children: [
                    Icon(Icons.recycling, color: Colors.green[700]),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recyclabilité: ${product.environmentalImpact['packagingRecyclability']}%',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    if (product.environmentalImpact['biodegradable'] == true)
                      _buildEcoChip('Biodégradable', Icons.compost),
                    if (product.environmentalImpact['sustainablySourced'] == true)
                      _buildEcoChip('Sources durables', Icons.eco),
                    if (product.environmentalImpact['veganFriendly'] == true)
                      _buildEcoChip('Vegan', Icons.spa),
                    if (product.environmentalImpact['palmOilFree'] == true)
                      _buildEcoChip('Sans huile de palme', Icons.forest),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEcoChip(String label, IconData icon) {
    return Chip(
      avatar: Icon(icon, size: 16, color: Colors.green[700]),
      label: Text(label),
      backgroundColor: Colors.green[50],
      labelStyle: TextStyle(color: Colors.green[700], fontSize: 12),
    );
  }

  Widget _buildAlternativesSection(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: product.alternatives.length,
        itemBuilder: (context, index) {
          final alternative = product.alternatives[index];
          return Container(
            width: 160,
            margin: const EdgeInsets.only(right: 12),
            child: Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image de l'alternative
                  Expanded(
                    child: Image.network(
                      alternative['imageUrl'] ?? '',
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[200],
                        child: const Center(
                          child: Icon(Icons.image_not_supported, size: 32, color: Colors.grey),
                        ),
                      ),
                    ),
                  ),
                  
                  // Informations sur l'alternative
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alternative['name'] ?? 'Produit',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          alternative['brand'] ?? 'Marque',
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _getScoreColor(double.parse(alternative['ecoScore'] ?? '0')),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                'Score: ${alternative['ecoScore']}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green[700]!;
    if (score >= 60) return Colors.green;
    if (score >= 40) return Colors.amber;
    if (score >= 20) return Colors.orange;
    return Colors.red;
  }
}