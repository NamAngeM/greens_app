import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../models/product_scan.dart';
import '../services/product_scan_service.dart';
import 'package:provider/provider.dart';

class ProductScanScreen extends StatefulWidget {
  @override
  _ProductScanScreenState createState() => _ProductScanScreenState();
}

class _ProductScanScreenState extends State<ProductScanScreen> {
  final ProductScanService _scanService = ProductScanService();
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isScanning = true;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Scanner de Produits'),
          bottom: TabBar(
            tabs: [
              Tab(text: 'Scanner'),
              Tab(text: 'Historique'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildScannerTab(),
            _buildHistoryTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildScannerTab() {
    return Column(
      children: [
        Expanded(
          child: _isScanning
              ? MobileScanner(
                  controller: _scannerController,
                  onDetect: (capture) {
                    final List<Barcode> barcodes = capture.barcodes;
                    for (final barcode in barcodes) {
                      _handleBarcode(barcode.rawValue);
                    }
                  },
                )
              : Center(
                  child: Text('Scanner désactivé'),
                ),
        ),
        Padding(
          padding: EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isScanning = !_isScanning;
                  });
                },
                icon: Icon(_isScanning ? Icons.stop : Icons.play_arrow),
                label: Text(_isScanning ? 'Arrêter' : 'Démarrer'),
              ),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement manual barcode entry
                },
                icon: Icon(Icons.edit),
                label: Text('Saisir manuellement'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryTab() {
    return StreamBuilder<List<ProductScan>>(
      stream: _scanService.getUserScanHistory('userId'),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Une erreur est survenue'));
        }

        if (!snapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }

        final scans = snapshot.data!;
        if (scans.isEmpty) {
          return Center(child: Text('Aucun scan enregistré'));
        }

        return ListView.builder(
          itemCount: scans.length,
          itemBuilder: (context, index) {
            final scan = scans[index];
            return Card(
              margin: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: _getScoreColor(scan.environmentalScore),
                  child: Text(
                    scan.environmentalScore.toStringAsFixed(0),
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                title: Text(scan.name),
                subtitle: Text(scan.brand),
                trailing: Icon(Icons.chevron_right),
                onTap: () => _showProductDetails(scan),
              ),
            );
          },
        );
      },
    );
  }

  void _handleBarcode(String? barcode) {
    if (barcode == null) return;

    _scanService.getProductByBarcode(barcode).then((product) {
      if (product != null) {
        _showProductDetails(product);
      } else {
        _showProductNotFoundDialog(barcode);
      }
    });
  }

  void _showProductDetails(ProductScan product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (context, scrollController) => SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.0),
                Text(
                  product.brand,
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 16.0),
                _buildScoreIndicator(product.environmentalScore),
                SizedBox(height: 16.0),
                _buildImpactDetails(product.impactDetails),
                SizedBox(height: 16.0),
                _buildRecyclingInstructions(product.recyclingInstructions),
                SizedBox(height: 16.0),
                _buildEcoAlternatives(product.ecoAlternatives),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildScoreIndicator(double score) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Score Environnemental',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: score / 100,
                  backgroundColor: Colors.grey[200],
                  color: _getScoreColor(score),
                ),
                Text(
                  score.toStringAsFixed(0),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImpactDetails(Map<String, dynamic> details) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Impact Environnemental',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            ...details.entries.map((entry) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(entry.key),
                      Text(
                        entry.value.toString(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildRecyclingInstructions(List<String> instructions) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Instructions de Recyclage',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            ...instructions.map((instruction) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.recycling, size: 20),
                      SizedBox(width: 8.0),
                      Expanded(child: Text(instruction)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  Widget _buildEcoAlternatives(List<String> alternatives) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alternatives Écologiques',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            ...alternatives.map((alternative) => Padding(
                  padding: EdgeInsets.symmetric(vertical: 4.0),
                  child: Row(
                    children: [
                      Icon(Icons.eco, size: 20),
                      SizedBox(width: 8.0),
                      Expanded(child: Text(alternative)),
                    ],
                  ),
                )),
          ],
        ),
      ),
    );
  }

  void _showProductNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Produit non trouvé'),
        content: Text('Le produit avec le code-barres $barcode n\'a pas été trouvé dans notre base de données.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }
} 