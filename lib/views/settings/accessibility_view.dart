import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/accessibility_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common/section_title.dart';

class AccessibilityView extends StatelessWidget {
  const AccessibilityView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accessibilityService = Provider.of<AccessibilityService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibilité'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
          tooltip: 'Retour',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section d'aide
            Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 24),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline, color: theme.colorScheme.primary),
                        const SizedBox(width: 8),
                        Text(
                          'Paramètres d\'accessibilité',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Personnalisez l\'application pour améliorer votre expérience utilisateur. Ces paramètres vous permettent d\'ajuster l\'interface selon vos besoins.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),

            // Taille du texte
            const SectionTitle(title: 'Taille du texte'),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Ajuster la taille du texte',
                      style: theme.textTheme.titleSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('A', style: theme.textTheme.bodySmall),
                        Expanded(
                          child: Slider(
                            value: accessibilityService.textScaleFactor,
                            min: 0.8,
                            max: 1.5,
                            divisions: 7,
                            label: accessibilityService.textScaleFactor.toStringAsFixed(1),
                            onChanged: (value) {
                              accessibilityService.setTextScaleFactor(value);
                            },
                          ),
                        ),
                        Text('A', style: theme.textTheme.headlineSmall),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Exemple de texte avec la taille sélectionnée',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: accessibilityService.getAdaptiveTextSize(14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Contraste élevé
            const SectionTitle(title: 'Apparence'),
            SwitchListTile(
              title: const Text('Mode contraste élevé'),
              subtitle: const Text(
                'Améliore la lisibilité avec des contrastes plus prononcés',
              ),
              value: accessibilityService.isHighContrastEnabled,
              onChanged: (_) => accessibilityService.toggleHighContrast(),
            ),
            const SizedBox(height: 16),

            // Lecteur d'écran
            const SectionTitle(title: 'Lecteur d\'écran'),
            SwitchListTile(
              title: const Text('Activer le support du lecteur d\'écran'),
              subtitle: const Text(
                'Optimise l\'application pour les lecteurs d\'écran',
              ),
              value: accessibilityService.isScreenReaderEnabled,
              onChanged: (_) => accessibilityService.toggleScreenReader(),
            ),
            const SizedBox(height: 24),

            // Bouton de réinitialisation
            Center(
              child: ElevatedButton.icon(
                onPressed: () => _showResetConfirmationDialog(context, accessibilityService),
                icon: const Icon(Icons.refresh),
                label: const Text('Réinitialiser les paramètres'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  void _showResetConfirmationDialog(BuildContext context, AccessibilityService service) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Réinitialiser les paramètres?'),
        content: const Text(
          'Tous les paramètres d\'accessibilité seront réinitialisés à leurs valeurs par défaut. Voulez-vous continuer?'
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              service.resetToDefaults();
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Paramètres réinitialisés'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            child: const Text('Réinitialiser'),
          ),
        ],
      ),
    );
  }
} 