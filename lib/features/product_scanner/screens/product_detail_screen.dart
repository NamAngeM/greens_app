import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/product_model.dart';
import '../widgets/eco_score_indicator.dart';
import '../widgets/footprint_info_card.dart';

class ProductDetailScreen extends StatelessWidget {
  final Product product;

  const ProductDetailScreen({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Détails du produit'),
        actions: [
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () {
              // TODO: Implémenter le partage
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProductHeader(context),
            _buildSection(
              context,
              title: 'Impact écologique',
              content: _buildEcoImpact(context),
            ),
            _buildSection(
              context,
              title: 'Composition',
              content: _buildComposition(context),
            ),
            if (product.alternatives.isNotEmpty)
              _buildSection(
                context,
                title: 'Alternatives recommandées',
                content: _buildAlternatives(context),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Ajouter au journal personnel
        },
        child: const Icon(Icons.add),
        tooltip: 'Ajouter à mon journal',
      ),
    );
  }

  Widget _buildProductHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(8),
            ),
            child: product.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      product.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_not_supported,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    ),
                  )
                : Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey[400],
                  ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  product.brand,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  product.category,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Code-barres: ${product.barcode}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required Widget content,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Colors.grey[100],
            width: double.infinity,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          content,
        ],
      ),
    );
  }

  Widget _buildEcoImpact(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: EcoScoreIndicator(score: product.ecoScore),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildImpactRow(
            context,
            icon: Icons.co2,
            title: 'Empreinte carbone',
            value: '${product.co2Emissions} kg CO₂ eq',
            info: 'Impact: ${_getCO2ImpactLabel(product.co2Emissions)}',
          ),
          _buildImpactRow(
            context,
            icon: Icons.water_drop,
            title: 'Utilisation d\'eau',
            value: '${product.waterUsage} L',
            info: 'Impact: ${_getWaterImpactLabel(product.waterUsage)}',
          ),
          _buildImpactRow(
            context,
            icon: Icons.local_shipping,
            title: 'Distance de transport',
            value: '${product.transportDistance} km',
            info: null,
          ),
          _buildImpactRow(
            context,
            icon: Icons.recycling,
            title: 'Emballage recyclable',
            value: product.recyclablePackaging ? 'Oui' : 'Non',
            info: null,
            valueColor: product.recyclablePackaging
                ? Colors.green
                : Colors.red,
          ),
        ],
      ),
    );
  }

  String _getCO2ImpactLabel(double co2) {
    if (co2 < 0.5) return 'Très faible';
    if (co2 < 1.0) return 'Faible';
    if (co2 < 2.0) return 'Moyen';
    if (co2 < 3.0) return 'Élevé';
    return 'Très élevé';
  }

  String _getWaterImpactLabel(int water) {
    if (water < 300) return 'Très faible';
    if (water < 600) return 'Faible';
    if (water < 900) return 'Moyen';
    if (water < 1500) return 'Élevé';
    return 'Très élevé';
  }

  Widget _buildImpactRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    String? info,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.grey[600],
            size: 24,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (info != null)
                  Text(
                    info,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                  ),
              ],
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: valueColor,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildComposition(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final ingredient in product.ingredients)
            _buildIngredientRow(context, ingredient),
        ],
      ),
    );
  }

  Widget _buildIngredientRow(BuildContext context, Ingredient ingredient) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(
            ingredient.sustainable
                ? Icons.check_circle
                : Icons.warning,
            color: ingredient.sustainable
                ? Colors.green
                : Colors.amber,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              ingredient.name,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Text(
            ingredient.origin,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlternatives(BuildContext context) {
    return Container(
      height: 220,
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: product.alternatives.length,
        itemBuilder: (context, index) {
          final alternative = product.alternatives[index];
          return _buildAlternativeItem(context, alternative);
        },
      ),
    );
  }

  Widget _buildAlternativeItem(BuildContext context, Product alternative) {
    return Container(
      width: 160,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image du produit
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Stack(
              children: [
                if (alternative.imageUrl != null)
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                    ),
                    child: Image.network(
                      alternative.imageUrl!,
                      width: double.infinity,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Icon(
                          Icons.image_not_supported,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  )
                else
                  Center(
                    child: Icon(
                      Icons.image_not_supported,
                      color: Colors.grey[400],
                    ),
                  ),
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: alternative.ecoScoreColor,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      alternative.ecoScoreLabel,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Informations du produit
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alternative.name,
                  style: Theme.of(context).textTheme.titleSmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  alternative.brand,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 