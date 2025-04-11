import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'dart:io';

class ProductScannerScreen extends StatefulWidget {
  const ProductScannerScreen({Key? key}) : super(key: key);

  @override
  _ProductScannerScreenState createState() => _ProductScannerScreenState();
}

class _ProductScannerScreenState extends State<ProductScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool isScanning = true;
  String? lastScannedCode;

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller?.pauseCamera();
    } else if (Platform.isIOS) {
      controller?.resumeCamera();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scanner de Produits'),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 5,
            child: _buildScanner(),
          ),
          Expanded(
            flex: 3,
            child: _buildProductInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildScanner() {
    return Stack(
      children: [
        QRView(
          key: qrKey,
          onQRViewCreated: _onQRViewCreated,
          overlay: QrScannerOverlayShape(
            borderColor: Theme.of(context).primaryColor,
            borderRadius: 10,
            borderLength: 30,
            borderWidth: 10,
            cutOutSize: MediaQuery.of(context).size.width * 0.8,
          ),
        ),
        Positioned(
          bottom: 16,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    isScanning = !isScanning;
                    if (isScanning) {
                      controller?.resumeCamera();
                    } else {
                      controller?.pauseCamera();
                    }
                  });
                },
                icon: Icon(isScanning ? Icons.pause : Icons.play_arrow),
                label: Text(isScanning ? 'Pause' : 'Reprendre'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProductInfo() {
    if (lastScannedCode == null) {
      return const Center(
        child: Text('Scannez un produit pour voir ses informations'),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Code produit: $lastScannedCode',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          _buildEcoRating(),
          const SizedBox(height: 16),
          _buildLocalAlternatives(),
          const SizedBox(height: 16),
          _buildCertifications(),
        ],
      ),
    );
  }

  Widget _buildEcoRating() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Note Écologique',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.eco, color: Colors.green),
                const SizedBox(width: 8),
                Text(
                  '8.5/10',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Text(
              'Ce produit a un impact environnemental modéré. '
              'Sa production utilise des matériaux recyclés et '
              'respecte les normes environnementales.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocalAlternatives() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alternatives Locales',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Boutique Bio du Centre'),
              subtitle: const Text('2.5 km - Prix similaire'),
              trailing: ElevatedButton(
                onPressed: () {
                  // TODO: Implémenter la navigation vers la boutique
                },
                child: const Text('Voir'),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.store),
              title: const Text('Marché Local'),
              subtitle: const Text('1.8 km - Prix inférieur'),
              trailing: ElevatedButton(
                onPressed: () {
                  // TODO: Implémenter la navigation vers le marché
                },
                child: const Text('Voir'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertifications() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Certifications',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildCertificationChip('Bio'),
                _buildCertificationChip('Équitable'),
                _buildCertificationChip('Recyclé'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCertificationChip(String label) {
    return Chip(
      label: Text(label),
      backgroundColor: Colors.green[100],
      labelStyle: const TextStyle(color: Colors.green),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) {
      if (scanData.code != null && scanData.code != lastScannedCode) {
        setState(() {
          lastScannedCode = scanData.code;
        });
        // TODO: Implémenter la recherche des informations du produit
      }
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
} 