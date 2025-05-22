import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../widgets/product_info_card.dart';

class ProductScannerScreen extends StatefulWidget {
  const ProductScannerScreen({Key? key}) : super(key: key);

  @override
  _ProductScannerScreenState createState() => _ProductScannerScreenState();
}

class _ProductScannerScreenState extends State<ProductScannerScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isScanning = true;
  String? _lastScannedCode;
  Map<String, dynamic>? _productInfo;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final String code = barcodes.first.rawValue ?? '';
    if (code == _lastScannedCode) return;

    setState(() {
      _lastScannedCode = code;
      _isScanning = false;
    });

    // Simuler la récupération des informations du produit
    _fetchProductInfo(code);
  }

  Future<void> _fetchProductInfo(String code) async {
    // TODO: Implémenter la récupération des informations du produit
    // Pour l'instant, on simule avec des données fictives
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _productInfo = {
        'name': 'Produit Écologique',
        'brand': 'Marque Verte',
        'ecoScore': 'A',
        'description': 'Un produit respectueux de l\'environnement',
        'impact': {
          'carbon': 'Faible',
          'water': 'Moyen',
          'waste': 'Faible',
        },
        'alternatives': [
          'Alternative 1',
          'Alternative 2',
        ],
      };
    });
  }

  void _resetScanner() {
    setState(() {
      _isScanning = true;
      _lastScannedCode = null;
      _productInfo = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de Produits'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on),
            onPressed: () => _controller.toggleTorch(),
          ),
          IconButton(
            icon: const Icon(Icons.switch_camera),
            onPressed: () => _controller.switchCamera(),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isScanning)
            Expanded(
              child: MobileScanner(
                controller: _controller,
                onDetect: _onDetect,
              ),
            )
          else if (_productInfo != null)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ProductInfoCard(
                  productInfo: _productInfo!,
                  onScanAgain: _resetScanner,
                ),
              ),
            ),
        ],
      ),
      floatingActionButton: !_isScanning
          ? FloatingActionButton(
              onPressed: _resetScanner,
              child: const Icon(Icons.refresh),
            )
          : null,
    );
  }
} 