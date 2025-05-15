import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/services/accessibility_service.dart';

class AccessibilitySettingsScreen extends StatefulWidget {
  const AccessibilitySettingsScreen({Key? key}) : super(key: key);

  @override
  State<AccessibilitySettingsScreen> createState() => _AccessibilitySettingsScreenState();
}

class _AccessibilitySettingsScreenState extends State<AccessibilitySettingsScreen> {
  double _textScaleFactor = 1.0;
  bool _highContrast = false;
  bool _reduceAnimations = false;
  bool _screenReader = false;
  String _selectedLanguage = 'Français';
  
  final List<String> _availableLanguages = [
    'Français',
    'English',
    'Español',
    'Deutsch',
    'Italiano',
    'Nederlands',
    'Português',
  ];
  
  @override
  void initState() {
    super.initState();
    _loadSettings();
  }
  
  Future<void> _loadSettings() async {
    final accessibilityService = Provider.of<AccessibilityService>(context, listen: false);
    
    setState(() {
      _textScaleFactor = accessibilityService.textScaleFactor;
      _highContrast = accessibilityService.highContrast;
      _reduceAnimations = accessibilityService.reduceAnimations;
      _screenReader = accessibilityService.screenReader;
      _selectedLanguage = accessibilityService.currentLanguage;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final accessibilityService = Provider.of<AccessibilityService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accessibilité'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Paramètres d\'accessibilité',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Personnalisez l\'application pour l\'adapter à vos besoins d\'accessibilité',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Taille du texte
            _buildSection(
              title: 'Taille du texte',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ajustez la taille du texte dans toute l\'application',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('A', style: TextStyle(fontSize: 14)),
                      Expanded(
                        child: Slider(
                          value: _textScaleFactor,
                          min: 0.8,
                          max: 1.6,
                          divisions: 4,
                          label: _getTextScaleLabel(_textScaleFactor),
                          onChanged: (value) {
                            setState(() => _textScaleFactor = value);
                          },
                          onChangeEnd: (value) {
                            accessibilityService.setTextScaleFactor(value);
                          },
                        ),
                      ),
                      const Text('A', style: TextStyle(fontSize: 24)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Text(
                      'Exemple de texte',
                      style: TextStyle(
                        fontSize: 16 * _textScaleFactor,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Contraste élevé
            _buildSection(
              title: 'Options visuelles',
              child: Column(
                children: [
                  SwitchListTile(
                    title: const Text('Mode contraste élevé'),
                    subtitle: const Text('Améliore la lisibilité avec des contrastes plus prononcés'),
                    value: _highContrast,
                    onChanged: (value) {
                      setState(() => _highContrast = value);
                      accessibilityService.setHighContrast(value);
                    },
                    secondary: const Icon(Icons.contrast),
                  ),
                  SwitchListTile(
                    title: const Text('Réduire les animations'),
                    subtitle: const Text('Réduit ou désactive les animations et effets visuels'),
                    value: _reduceAnimations,
                    onChanged: (value) {
                      setState(() => _reduceAnimations = value);
                      accessibilityService.setReduceAnimations(value);
                    },
                    secondary: const Icon(Icons.animation),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Options de lecteur d'écran
            _buildSection(
              title: 'Options d\'assistance',
              child: SwitchListTile(
                title: const Text('Optimiser pour lecteur d\'écran'),
                subtitle: const Text('Améliore la compatibilité avec TalkBack et VoiceOver'),
                value: _screenReader,
                onChanged: (value) {
                  setState(() => _screenReader = value);
                  accessibilityService.setScreenReader(value);
                },
                secondary: const Icon(Icons.record_voice_over),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Sélection de la langue
            _buildSection(
              title: 'Langue',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Choisissez la langue de l\'application',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<String>(
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    value: _selectedLanguage,
                    items: _availableLanguages.map((language) {
                      return DropdownMenuItem<String>(
                        value: language,
                        child: Text(language),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _selectedLanguage = value);
                        accessibilityService.setLanguage(value);
                        
                        // Simuler un changement de langue
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Langue changée en $value'),
                            backgroundColor: AppColors.primaryColor,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Section d'aide
            _buildSection(
              title: 'Aide à l\'accessibilité',
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.help_outline),
                    title: const Text('Guide d\'accessibilité'),
                    subtitle: const Text('Comment utiliser les fonctionnalités d\'accessibilité'),
                    onTap: () {
                      // Naviguer vers le guide d'accessibilité
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Guide d\'accessibilité - Fonctionnalité à venir'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.feedback_outlined),
                    title: const Text('Envoyer un retour sur l\'accessibilité'),
                    subtitle: const Text('Aidez-nous à améliorer l\'accessibilité de l\'application'),
                    onTap: () {
                      // Ouvrir le formulaire de feedback
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Formulaire de retour - Fonctionnalité à venir'),
                          backgroundColor: Colors.blue,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 32),
            
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  // Réinitialiser les paramètres d'accessibilité
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Réinitialiser les paramètres'),
                      content: const Text('Tous les paramètres d\'accessibilité seront réinitialisés à leurs valeurs par défaut. Voulez-vous continuer ?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Annuler'),
                        ),
                        TextButton(
                          onPressed: () {
                            accessibilityService.resetSettings();
                            _loadSettings();
                            Navigator.pop(context);
                            
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Paramètres réinitialisés'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          },
                          child: const Text('Réinitialiser'),
                        ),
                      ],
                    ),
                  );
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réinitialiser les paramètres'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey[200],
                  foregroundColor: Colors.black87,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSection({required String title, required Widget child}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
  
  String _getTextScaleLabel(double scale) {
    if (scale <= 0.8) return 'Très petit';
    if (scale <= 0.9) return 'Petit';
    if (scale <= 1.1) return 'Normal';
    if (scale <= 1.3) return 'Grand';
    return 'Très grand';
  }
} 