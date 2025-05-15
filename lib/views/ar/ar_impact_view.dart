import 'package:flutter/material.dart';
import 'package:greens_app/services/ar_impact_service.dart';
import 'package:greens_app/widgets/app_bar_with_back_button.dart';
import 'package:greens_app/utils/app_colors.dart';

/// Vue qui permet de visualiser l'impact écologique en réalité augmentée
class ARImpactView extends StatefulWidget {
  const ARImpactView({Key? key}) : super(key: key);

  @override
  State<ARImpactView> createState() => _ARImpactViewState();
}

class _ARImpactViewState extends State<ARImpactView> {
  final ARImpactService _arService = ARImpactService.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeARService();
  }

  Future<void> _initializeARService() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _arService.initialize();
    } catch (e) {
      // Gérer l'erreur
      print('Erreur lors de l\'initialisation du service AR: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppBarWithBackButton(
        title: 'Visualisation AR',
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.view_in_ar,
                    size: 100,
                    color: AppColors.primaryColor,
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Visualisez l\'impact écologique en réalité augmentée',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      'Scannez un produit pour voir son impact environnemental en réalité augmentée.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 32),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.qr_code_scanner),
                    label: const Text('Scanner un produit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {
                      // Naviguer vers la vue de scan
                      Navigator.pushNamed(context, '/scanner');
                    },
                  ),
                ],
              ),
            ),
    );
  }
} 