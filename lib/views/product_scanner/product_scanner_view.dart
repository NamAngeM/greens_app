import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/widgets/menu.dart';

class ProductScannerView extends StatefulWidget {
  const ProductScannerView({Key? key}) : super(key: key);

  @override
  State<ProductScannerView> createState() => _ProductScannerViewState();
}

class _ProductScannerViewState extends State<ProductScannerView> {
  bool _isScanning = false;
  Map<String, dynamic>? _productData;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner un produit'),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.textColor,
        elevation: 0,
      ),
      body: _productData == null ? _buildScanner() : _buildProductInfo(),
      bottomNavigationBar: const CustomMenu(currentIndex: 4),
    );
  }

  Widget _buildScanner() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.qr_code_scanner,
            size: 100,
            color: AppColors.primaryColor,
          ),
          const SizedBox(height: 20),
          const Text(
            'Scannez le code-barres d\'un produit',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: _startScanning,
            icon: const Icon(Icons.camera_alt),
            label: const Text('Scanner'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductInfo() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildProductHeader(),
          const SizedBox(height: 20),
          _buildNutritionalInfo(),
          const SizedBox(height: 20),
          _buildEcoIndex(),
          const SizedBox(height: 20),
          _buildHealthImpact(),
          const SizedBox(height: 20),
          _buildEthics(),
          const SizedBox(height: 20),
          _buildAlternatives(),
          const SizedBox(height: 20),
          _buildShopButton(),
          const SizedBox(height: 20),
          _buildProviderNote(),
        ],
      ),
    );
  }

  Widget _buildProductHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.image, size: 40),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Nom du produit',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Marque',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionalInfo() {
    return _buildSection(
      title: 'Information nutritionnelle',
      icon: Icons.restaurant_menu,
      child: Column(
        children: [
          _buildNutritionItem('Calories', '150 kcal'),
          _buildNutritionItem('Protéines', '5g'),
          _buildNutritionItem('Glucides', '20g'),
          _buildNutritionItem('Lipides', '3g'),
          _buildNutritionItem('Fibres', '2g'),
        ],
      ),
    );
  }

  Widget _buildEcoIndex() {
    return _buildSection(
      title: 'Indice écologique',
      icon: Icons.eco,
      child: Column(
        children: [
          _buildEcoScore(85, 'Excellent'),
          const SizedBox(height: 16),
          _buildEcoDetail('Emballage', 'Recyclable', Colors.green),
          _buildEcoDetail('Transport', 'Local', Colors.green),
          _buildEcoDetail('Production', 'Bio', Colors.green),
        ],
      ),
    );
  }

  Widget _buildHealthImpact() {
    return _buildSection(
      title: 'Santé et impact sur le corps',
      icon: Icons.favorite,
      child: Column(
        children: [
          _buildHealthScore(75, 'Bon'),
          const SizedBox(height: 16),
          _buildHealthDetail('Additifs', '2 additifs', Colors.orange),
          _buildHealthDetail('Nutriments', 'Équilibré', Colors.green),
          _buildHealthDetail('Allergènes', 'Sans allergènes majeurs', Colors.green),
        ],
      ),
    );
  }

  Widget _buildEthics() {
    return _buildSection(
      title: 'Éthique',
      icon: Icons.handshake,
      child: Column(
        children: [
          _buildEthicsScore(90, 'Excellent'),
          const SizedBox(height: 16),
          _buildEthicsDetail('Conditions de travail', 'Certifié', Colors.green),
          _buildEthicsDetail('Commerce équitable', 'Oui', Colors.green),
          _buildEthicsDetail('Transparence', 'Bonne', Colors.green),
        ],
      ),
    );
  }

  Widget _buildAlternatives() {
    return _buildSection(
      title: 'Alternatives',
      icon: Icons.compare_arrows,
      child: Column(
        children: [
          _buildAlternativeItem(
            'Alternative 1',
            'Meilleur score écologique',
            Colors.green,
          ),
          const Divider(),
          _buildAlternativeItem(
            'Alternative 2',
            'Meilleur rapport qualité/prix',
            Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primaryColor),
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
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildNutritionItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildEcoScore(int score, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score.toString(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const Text(
                'Score écologique',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEcoDetail(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Icon(Icons.check_circle, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthScore(int score, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score.toString(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.orange,
                ),
              ),
              const Text(
                'Score santé',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHealthDetail(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Icon(Icons.info_outline, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEthicsScore(int score, String label) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            score.toString(),
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const Text(
                'Score éthique',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEthicsDetail(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Row(
            children: [
              Icon(Icons.verified, color: color, size: 16),
              const SizedBox(width: 4),
              Text(
                value,
                style: TextStyle(color: color),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAlternativeItem(String name, String description, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(Icons.shopping_bag, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.arrow_forward_ios, size: 16),
            onPressed: () {
              // Navigation vers le détail de l'alternative
            },
          ),
        ],
      ),
    );
  }

  Widget _buildShopButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          // Redirection vers la boutique en ligne
          // À implémenter avec l'URL de la boutique
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Redirection vers la boutique en ligne...'),
              duration: Duration(seconds: 2),
            ),
          );
        },
        icon: const Icon(Icons.shopping_cart),
        label: const Text('Acheter ce produit'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  Widget _buildProviderNote() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey[600], size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Les fournisseurs seront contactés ultérieurement pour établir des partenariats commerciaux.',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _startScanning() {
    setState(() {
      _isScanning = true;
    });
    // Simuler un scan réussi après 2 secondes
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isScanning = false;
        _productData = {
          'name': 'Produit exemple',
          'brand': 'Marque exemple',
          'nutrition': {
            'calories': '150 kcal',
            'proteins': '5g',
            'carbs': '20g',
            'fats': '3g',
            'fiber': '2g',
          },
          'ecoScore': 85,
          'healthScore': 75,
          'ethicsScore': 90,
        };
      });
    });
  }
} 