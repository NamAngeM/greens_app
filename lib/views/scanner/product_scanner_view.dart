import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/product_scan_controller.dart';
import 'package:greens_app/controllers/auth_controller.dart';
import 'package:greens_app/controllers/product_controller.dart';
import 'package:greens_app/models/product_scan_model.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/widgets/custom_button.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:intl/intl.dart';

class ProductScannerView extends StatefulWidget {
  const ProductScannerView({Key? key}) : super(key: key);

  @override
  State<ProductScannerView> createState() => _ProductScannerViewState();
}

class _ProductScannerViewState extends State<ProductScannerView> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    
    // Initialiser les contrôleurs
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authController = Provider.of<AuthController>(context, listen: false);
      final scanController = Provider.of<ProductScanController>(context, listen: false);
      
      if (authController.currentUser != null) {
        scanController.getUserScanHistory(authController.currentUser!.uid);
      }
    });
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final scanController = Provider.of<ProductScanController>(context);
    
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Scanner de produits'),
        backgroundColor: AppColors.primaryColor,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(text: 'Scanner'),
            Tab(text: 'Historique'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Onglet Scanner
          _buildScannerTab(scanController, authController),
          
          // Onglet Historique
          _buildHistoryTab(scanController),
        ],
      ),
    );
  }

  Widget _buildScannerTab(ProductScanController controller, AuthController authController) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (controller.isScanning)
            const CircularProgressIndicator()
          else if (controller.lastScan != null)
            _buildLastScanResult(controller.lastScan!)
          else
            Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.qr_code_scanner,
                    size: 80,
                    color: AppColors.primaryColor,
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Scannez un produit pour connaître\nson impact environnemental',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          const SizedBox(height: 32),
          CustomButton(
            text: 'Scanner un code-barres',
            icon: Icons.qr_code_scanner,
            onPressed: () => _scanBarcode(context, controller, authController),
            backgroundColor: AppColors.primaryColor,
            width: 250,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryTab(ProductScanController controller) {
    if (controller.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    
    if (controller.scanHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucun historique de scan',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
    
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.scanHistory.length,
      itemBuilder: (context, index) {
        final scan = controller.scanHistory[index];
        return _buildScanHistoryItem(scan, controller);
      },
    );
  }

  Widget _buildScanHistoryItem(ProductScan scan, ProductScanController controller) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () => _showScanDetails(context, scan),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Image du produit
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  scan.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Informations du produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scan.brand,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: scan.getRatingColor().withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            scan.getRatingText(),
                            style: TextStyle(
                              color: scan.getRatingColor(),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          DateFormat('dd/MM/yyyy').format(scan.scannedAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              
              // Icône pour voir plus
              const Icon(
                Icons.chevron_right,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLastScanResult(ProductScan scan) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Image du produit
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  scan.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 40,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Informations du produit
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scan.productName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scan.brand,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: scan.getRatingColor().withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Impact: ${scan.getRatingText()}',
                        style: TextStyle(
                          color: scan.getRatingColor(),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Impact environnemental',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            scan.ecoImpact,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
            ),
          ),
          if (scan.ecoTips.isNotEmpty) ...[
            const SizedBox(height: 16),
            const Text(
              'Conseils écologiques',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            ...scan.ecoTips.map((tip) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.eco_outlined,
                    color: AppColors.secondaryColor,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            )),
          ],
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              OutlinedButton.icon(
                onPressed: () => _showAlternatives(context, scan),
                icon: const Icon(Icons.swap_horiz),
                label: const Text('Alternatives'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primaryColor,
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _scanBarcode(
                  context,
                  Provider.of<ProductScanController>(context, listen: false),
                  Provider.of<AuthController>(context, listen: false),
                ),
                icon: const Icon(Icons.qr_code_scanner),
                label: const Text('Nouveau scan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _scanBarcode(BuildContext context, ProductScanController controller, AuthController authController) async {
    if (authController.currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous devez être connecté pour scanner des produits'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    try {
      String barcode = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666',
        'Annuler',
        true,
        ScanMode.BARCODE,
      );
      
      if (barcode == '-1') {
        // L'utilisateur a annulé le scan
        return;
      }
      
      final scan = await controller.scanBarcode(barcode, authController.currentUser!.uid);
      
      if (scan == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Produit non trouvé dans notre base de données'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      print('Error scanning barcode: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du scan du code-barres'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showScanDetails(BuildContext context, ProductScan scan) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    // Image du produit
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        scan.imageUrl,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 100,
                            height: 100,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Informations du produit
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            scan.productName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            scan.brand,
                            style: const TextStyle(
                              color: Colors.grey,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: scan.getRatingColor().withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  'Impact: ${scan.getRatingText()}',
                                  style: TextStyle(
                                    color: scan.getRatingColor(),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const Spacer(),
                              Text(
                                DateFormat('dd/MM/yyyy').format(scan.scannedAt),
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Code-barres',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  scan.barcode,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Impact environnemental',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  scan.ecoImpact,
                  style: TextStyle(
                    color: Colors.grey[700],
                    fontSize: 14,
                  ),
                ),
                if (scan.ecoTips.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  const Text(
                    'Conseils écologiques',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...scan.ecoTips.map((tip) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.eco_outlined,
                          color: AppColors.secondaryColor,
                          size: 16,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            tip,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () => _showAlternatives(context, scan),
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Alternatives'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryColor,
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: () {
                        final controller = Provider.of<ProductScanController>(context, listen: false);
                        controller.deleteScan(scan.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Supprimer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showAlternatives(BuildContext context, ProductScan scan) {
    if (scan.alternativeProductIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune alternative disponible pour ce produit'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    
    final controller = Provider.of<ProductScanController>(context, listen: false);
    final productController = Provider.of<ProductController>(context, listen: false);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Alternatives écologiques'),
        content: SizedBox(
          width: double.maxFinite,
          child: FutureBuilder(
            future: controller.getAlternativeProducts(scan.alternativeProductIds),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (snapshot.hasError) {
                return const Center(
                  child: Text('Erreur lors du chargement des alternatives'),
                );
              }
              
              final alternatives = snapshot.data ?? [];
              
              if (alternatives.isEmpty) {
                return const Center(
                  child: Text('Aucune alternative disponible'),
                );
              }
              
              return ListView.builder(
                shrinkWrap: true,
                itemCount: alternatives.length,
                itemBuilder: (context, index) {
                  final product = alternatives[index];
                  return ListTile(
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 50,
                                height: 50,
                                color: Colors.grey[300],
                                child: const Icon(
                                  Icons.image_not_supported_outlined,
                                  color: Colors.grey,
                                  size: 24,
                                ),
                              );
                            },
                          )
                        : Container(
                            width: 50,
                            height: 50,
                            color: Colors.grey[300],
                            child: const Icon(
                              Icons.image_not_supported_outlined,
                              color: Colors.grey,
                              size: 24,
                            ),
                          ),
                    ),
                    title: Text(product.name),
                    subtitle: Text(product.brand),
                    trailing: Text(
                      '${product.price.toStringAsFixed(2)} €',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    onTap: () {
                      Navigator.pop(context);
                      productController.selectProduct(product);
                      Navigator.pushNamed(context, '/products');
                    },
                  );
                },
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}