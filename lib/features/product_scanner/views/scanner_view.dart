import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/scanner_controller.dart';
import '../models/product_model.dart';
import '../widgets/product_details_card.dart';
import '../widgets/alternatives_list.dart';
import '../widgets/scan_button.dart';

class ScannerView extends StatelessWidget {
  const ScannerView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ScannerController(),
      child: const _ScannerViewContent(),
    );
  }
}

class _ScannerViewContent extends StatelessWidget {
  const _ScannerViewContent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Provider.of<ScannerController>(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de Produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showHistory(context),
          ),
        ],
      ),
      body: Container(
        padding: const EdgeInsets.all(16),
        child: controller.isLoading
            ? const Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Message d'erreur
                  if (controller.errorMessage != null)
                    Container(
                      padding: const EdgeInsets.all(8),
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.red[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        controller.errorMessage!,
                        style: TextStyle(color: Colors.red[800]),
                      ),
                    ),

                  // Zone principale - soit les instructions, soit les détails du produit
                  Expanded(
                    child: controller.scannedProduct == null
                        ? _buildInstructions(theme)
                        : _buildProductDetails(controller),
                  ),

                  // Boutons de scan
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ScanButton(
                        icon: Icons.qr_code_scanner,
                        label: 'Scanner Code',
                        onPressed: () => _scanBarcode(context),
                      ),
                      ScanButton(
                        icon: Icons.camera_alt,
                        label: 'Scanner Image',
                        onPressed: controller.scanImage,
                      ),
                    ],
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildInstructions(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_basket,
            size: 80,
            color: theme.primaryColor.withOpacity(0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'Scannez un produit',
            style: theme.textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Utilisez le scanner de code-barres ou prenez une photo du produit pour obtenir des informations sur son impact environnemental',
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductDetails(ScannerController controller) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Détails du produit scanné
          ProductDetailsCard(product: controller.scannedProduct!),
          
          const SizedBox(height: 24),
          
          // Alternatives plus écologiques
          if (controller.alternatives.isNotEmpty) ...[
            Text(
              'Alternatives plus écologiques',
              style: const TextStyle(
                fontSize: 18, 
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            AlternativesList(alternatives: controller.alternatives),
          ],
          
          // Bouton pour réinitialiser
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: controller.reset,
            icon: const Icon(Icons.refresh),
            label: const Text('Scanner un autre produit'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarcode(BuildContext context) async {
    // Dans une application réelle, cette partie utiliserait une bibliothèque
    // de scanner de codes-barres comme flutter_barcode_scanner
    // Pour cet exemple, simulons une entrée manuelle
    
    final controller = Provider.of<ScannerController>(context, listen: false);
    
    final TextEditingController textController = TextEditingController();
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Entrer code-barres'),
        content: TextField(
          controller: textController,
          decoration: const InputDecoration(
            hintText: 'Ex: 3456789012345',
          ),
          keyboardType: TextInputType.number,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              if (textController.text.isNotEmpty) {
                controller.scanBarcode(textController.text);
              }
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  void _showHistory(BuildContext context) {
    // Navigation vers l'historique de scan
    // Dans une application réelle, nous naviguerions vers une page d'historique complète
    final controller = Provider.of<ScannerController>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (context) => FutureBuilder<List<Product>>(
        future: controller.getScannedProductsHistory(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          
          final products = snapshot.data!;
          
          if (products.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text('Aucun produit scanné récemment'),
              ),
            );
          }
          
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: products.length,
            itemBuilder: (context, index) {
              final product = products[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.green[100],
                  child: Text(
                    product.ecoScore.toString(),
                    style: TextStyle(color: Colors.green[800]),
                  ),
                ),
                title: Text(product.name),
                subtitle: Text(product.brand),
                trailing: Text('${product.carbonFootprint} CO2'),
                onTap: () {
                  Navigator.pop(context);
                  controller.reset();
                  controller.scanBarcode(product.barcode);
                },
              );
            },
          );
        },
      ),
    );
  }
} 