import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/services/accessibility_service.dart';
import 'package:greens_app/widgets/accessibility_widgets.dart';

class AccessibilitySettingsView extends StatefulWidget {
  const AccessibilitySettingsView({Key? key}) : super(key: key);

  @override
  State<AccessibilitySettingsView> createState() => _AccessibilitySettingsViewState();
}

class _AccessibilitySettingsViewState extends State<AccessibilitySettingsView> {
  double _textScaleFactor = 1.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final accessibilityService = Provider.of<AccessibilityService>(context, listen: false);
      setState(() {
        _textScaleFactor = accessibilityService.textScaleFactor;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final accessibilityService = Provider.of<AccessibilityService>(context);
    final bool highContrastEnabled = accessibilityService.isHighContrastEnabled;
    final bool largeTextEnabled = accessibilityService.isLargeTextEnabled;

    return Scaffold(
      backgroundColor: accessibilityService.getAdaptiveColor(
        Colors.white,
        const Color(0xFF121212), // Fond très foncé pour contraste élevé
      ),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: accessibilityService.getAdaptiveColor(
          Colors.white,
          const Color(0xFF121212),
        ),
        iconTheme: IconThemeData(
          color: accessibilityService.getAdaptiveColor(
            Colors.black87,
            Colors.white,
          ),
        ),
        title: Semantics(
          header: true,
          child: AccessibleText(
            'Paramètres d\'accessibilité',
            style: TextStyle(
              color: accessibilityService.getAdaptiveColor(
                Colors.black87,
                Colors.white,
              ),
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section d'information
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: accessibilityService.getAdaptiveColor(
                  Colors.green.withOpacity(0.1),
                  const Color(0xFF1E3246),
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: accessibilityService.getAdaptiveColor(
                    Colors.green.withOpacity(0.3),
                    Colors.green,
                  ),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: accessibilityService.getAdaptiveColor(
                      Colors.green,
                      Colors.lightGreen,
                    ),
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AccessibleText(
                      'Ces paramètres vous permettent d\'adapter l\'application à vos besoins visuels.',
                      style: TextStyle(
                        color: accessibilityService.getAdaptiveColor(
                          Colors.black87,
                          Colors.white,
                        ),
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Section Contraste élevé
            Semantics(
              container: true,
              label: 'Section contraste élevé',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AccessibleText(
                    'Contraste élevé',
                    style: TextStyle(
                      color: accessibilityService.getAdaptiveColor(
                        Colors.black87,
                        Colors.white,
                      ),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AccessibleText(
                    'Augmente le contraste des couleurs pour améliorer la lisibilité.',
                    style: TextStyle(
                      color: accessibilityService.getAdaptiveColor(
                        Colors.grey.shade700,
                        Colors.grey.shade300,
                      ),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    toggled: highContrastEnabled,
                    label: 'Activer le mode contraste élevé',
                    child: SwitchListTile(
                      title: AccessibleText(
                        'Activer le mode contraste élevé',
                        style: TextStyle(
                          color: accessibilityService.getAdaptiveColor(
                            Colors.black87,
                            Colors.white,
                          ),
                          fontSize: 16,
                        ),
                      ),
                      value: highContrastEnabled,
                      onChanged: (bool value) async {
                        await accessibilityService.toggleHighContrast();
                      },
                      activeColor: Colors.green,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Section Taille du texte
            Semantics(
              container: true,
              label: 'Section taille du texte',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AccessibleText(
                    'Taille du texte',
                    style: TextStyle(
                      color: accessibilityService.getAdaptiveColor(
                        Colors.black87,
                        Colors.white,
                      ),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AccessibleText(
                    'Ajustez la taille du texte pour une meilleure lisibilité.',
                    style: TextStyle(
                      color: accessibilityService.getAdaptiveColor(
                        Colors.grey.shade700,
                        Colors.grey.shade300,
                      ),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    toggled: largeTextEnabled,
                    label: 'Activer le texte large',
                    child: SwitchListTile(
                      title: AccessibleText(
                        'Activer le texte large',
                        style: TextStyle(
                          color: accessibilityService.getAdaptiveColor(
                            Colors.black87,
                            Colors.white,
                          ),
                          fontSize: 16,
                        ),
                      ),
                      value: largeTextEnabled,
                      onChanged: (bool value) async {
                        await accessibilityService.toggleLargeText();
                        setState(() {
                          _textScaleFactor = accessibilityService.textScaleFactor;
                        });
                      },
                      activeColor: Colors.green,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 0),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Semantics(
                    slider: true,
                    value: '${(_textScaleFactor * 100).toInt()}% de la taille normale',
                    increasedValue: 'Augmenter la taille du texte',
                    decreasedValue: 'Diminuer la taille du texte',
                    hint: 'Faites glisser pour ajuster la taille du texte',
                    child: Row(
                      children: [
                        const Icon(Icons.text_format, size: 16),
                        Expanded(
                          child: Slider(
                            value: _textScaleFactor,
                            min: 0.8,
                            max: 2.5,
                            divisions: 17,
                            label: '${(_textScaleFactor * 100).toInt()}%',
                            onChanged: (double value) {
                              setState(() {
                                _textScaleFactor = value;
                              });
                            },
                            onChangeEnd: (double value) async {
                              await accessibilityService.setTextScaleFactor(value);
                            },
                          ),
                        ),
                        const Icon(Icons.text_format, size: 24),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Exemple de texte
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: accessibilityService.getAdaptiveColor(
                        Colors.grey.shade100,
                        Colors.grey.shade900,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: AccessibleText(
                      'Ceci est un exemple de texte pour vous aider à choisir la taille qui vous convient le mieux.',
                      style: TextStyle(
                        fontSize: 16 * _textScaleFactor,
                        color: accessibilityService.getAdaptiveColor(
                          Colors.black87,
                          Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Section Informations sur le lecteur d'écran
            Semantics(
              container: true,
              label: 'Section lecteur d\'écran',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AccessibleText(
                    'Lecteur d\'écran',
                    style: TextStyle(
                      color: accessibilityService.getAdaptiveColor(
                        Colors.black87,
                        Colors.white,
                      ),
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AccessibleText(
                    'Cette application est compatible avec les lecteurs d\'écran. Pour l\'activer, veuillez modifier les paramètres d\'accessibilité de votre appareil.',
                    style: TextStyle(
                      color: accessibilityService.getAdaptiveColor(
                        Colors.grey.shade700,
                        Colors.grey.shade300,
                      ),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 16),
                  AccessibleButton(
                    semanticLabel: 'Ouvrir les paramètres d\'accessibilité du système',
                    onPressed: () {
                      // Tentative d'ouverture des paramètres d'accessibilité du système
                      // Cette fonctionnalité peut nécessiter des packages supplémentaires selon la plateforme
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: AccessibleText(
                            'Pour activer le lecteur d\'écran, veuillez ouvrir les paramètres d\'accessibilité de votre appareil.',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.settings),
                        const SizedBox(width: 8),
                        AccessibleText(
                          'Paramètres système',
                          style: const TextStyle(
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Bouton pour restaurer les paramètres par défaut
            Center(
              child: AccessibleButton(
                semanticLabel: 'Restaurer les paramètres par défaut',
                onPressed: () async {
                  // Confirmation avant de restaurer
                  final bool confirm = await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        backgroundColor: accessibilityService.getAdaptiveColor(
                          Colors.white,
                          const Color(0xFF252525),
                        ),
                        title: AccessibleText(
                          'Restaurer les paramètres',
                          style: TextStyle(
                            color: accessibilityService.getAdaptiveColor(
                              Colors.black87,
                              Colors.white,
                            ),
                          ),
                        ),
                        content: AccessibleText(
                          'Souhaitez-vous restaurer tous les paramètres d\'accessibilité à leurs valeurs par défaut ?',
                          style: TextStyle(
                            color: accessibilityService.getAdaptiveColor(
                              Colors.black87,
                              Colors.white,
                            ),
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(false),
                            child: AccessibleText(
                              'Annuler',
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(true),
                            child: AccessibleText(
                              'Restaurer',
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        ],
                      );
                    },
                  ) ?? false;
                  
                  if (confirm) {
                    // Restaurer les paramètres par défaut
                    if (accessibilityService.isHighContrastEnabled) {
                      await accessibilityService.toggleHighContrast();
                    }
                    
                    await accessibilityService.setTextScaleFactor(1.0);
                    setState(() {
                      _textScaleFactor = 1.0;
                    });
                    
                    // Feedback
                    if(mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: AccessibleText(
                            'Paramètres restaurés',
                            style: const TextStyle(color: Colors.white),
                          ),
                          backgroundColor: Colors.green,
                        ),
                      );
                    }
                  }
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    accessibilityService.getAdaptiveColor(
                      Colors.red.shade100,
                      Colors.red.shade900,
                    ),
                  ),
                  foregroundColor: MaterialStateProperty.all(
                    accessibilityService.getAdaptiveColor(
                      Colors.red.shade900,
                      Colors.white,
                    ),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.restore,
                        color: accessibilityService.getAdaptiveColor(
                          Colors.red.shade900,
                          Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      AccessibleText(
                        'Restaurer les paramètres par défaut',
                        style: TextStyle(
                          color: accessibilityService.getAdaptiveColor(
                            Colors.red.shade900,
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 