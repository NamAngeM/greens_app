import 'package:flutter/material.dart';
import 'package:greens_app/models/product_scan_model.dart';

class CarbonFootprintDetailView extends StatelessWidget {
  final ProductScan scan;
  
  const CarbonFootprintDetailView({
    Key? key,
    required this.scan,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails Empreinte Carbone'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Produit: ${scan.productName}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Empreinte carbone: ${scan.carbonFootprint} kg CO2 eq',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            // Contenu à développer
          ],
        ),
      ),
    );
  }
} 