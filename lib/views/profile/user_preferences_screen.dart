import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/services/user_preferences_service.dart';

class UserPreferencesScreen extends StatefulWidget {
  const UserPreferencesScreen({Key? key}) : super(key: key);

  @override
  State<UserPreferencesScreen> createState() => _UserPreferencesScreenState();
}

class _UserPreferencesScreenState extends State<UserPreferencesScreen> {
  // Catégories d'intérêts écologiques
  final List<String> _ecologicalInterests = [
    'Alimentation durable',
    'Mode éthique',
    'Zéro déchet',
    'Énergie renouvelable',
    'Transport écologique',
    'Biodiversité',
    'Jardinage bio',
    'Minimalisme',
    'Construction écologique',
    'Activisme environnemental'
  ];

  // Paramètres de l'application
  bool _darkMode = false;
  bool _notificationsEnabled = true;
  bool _dataCollectionOptIn = true;
  String _defaultView = 'Tableau de bord';
  
  final List<String> _viewOptions = [
    'Tableau de bord',
    'Conseils du jour',
    'Objectifs',
    'Scanner'
  ];

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = Provider.of<UserPreferencesService>(context, listen: false);
    
    setState(() {
      _darkMode = prefs.darkMode;
      _notificationsEnabled = prefs.notificationsEnabled;
      _dataCollectionOptIn = prefs.dataCollectionOptIn;
      _defaultView = prefs.defaultView;
    });
  }

  @override
  Widget build(BuildContext context) {
    final prefsService = Provider.of<UserPreferencesService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personnalisation'),
        backgroundColor: AppColors.primaryColor,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Section des intérêts écologiques
              _buildSectionTitle('Centres d\'intérêt écologiques'),
              const SizedBox(height: 8),
              _buildInterestsGrid(prefsService),
              const Divider(height: 32),
              
              // Section des paramètres de l'application
              _buildSectionTitle('Paramètres de l\'application'),
              const SizedBox(height: 16),
              
              // Mode sombre
              _buildSwitchTile(
                title: 'Mode sombre',
                subtitle: 'Économise la batterie et réduit la fatigue oculaire',
                value: _darkMode,
                onChanged: (value) {
                  setState(() => _darkMode = value);
                  prefsService.setDarkMode(value);
                },
                icon: Icons.dark_mode,
              ),
              
              // Notifications
              _buildSwitchTile(
                title: 'Notifications',
                subtitle: 'Recevoir des conseils, défis et rappels',
                value: _notificationsEnabled,
                onChanged: (value) {
                  setState(() => _notificationsEnabled = value);
                  prefsService.setNotificationsEnabled(value);
                },
                icon: Icons.notifications,
              ),
              
              // Collecte de données
              _buildSwitchTile(
                title: 'Collecte de données anonymes',
                subtitle: 'Nous aide à améliorer l\'application et l\'impact écologique',
                value: _dataCollectionOptIn,
                onChanged: (value) {
                  setState(() => _dataCollectionOptIn = value);
                  prefsService.setDataCollectionOptIn(value);
                },
                icon: Icons.analytics,
              ),
              
              // Vue par défaut
              _buildDropdownTile(
                title: 'Vue par défaut',
                subtitle: 'Écran affiché au démarrage de l\'application',
                value: _defaultView,
                options: _viewOptions,
                onChanged: (String? value) {
                  if (value != null) {
                    setState(() => _defaultView = value);
                    prefsService.setDefaultView(value);
                  }
                },
                icon: Icons.home,
              ),
              
              const Divider(height: 32),
              
              // Tableau de bord personnalisable
              _buildSectionTitle('Personnalisation du tableau de bord'),
              const SizedBox(height: 16),
              _buildDashboardCustomization(prefsService),
              
              const SizedBox(height: 40),
              
              // Bouton d'export des données
              Center(
                child: ElevatedButton.icon(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vos données ont été exportées'),
                        backgroundColor: AppColors.primaryColor,
                      ),
                    );
                  },
                  icon: const Icon(Icons.download),
                  label: const Text('Exporter mes données'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.secondaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildInterestsGrid(UserPreferencesService prefsService) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: _ecologicalInterests.length,
      itemBuilder: (context, index) {
        final interest = _ecologicalInterests[index];
        final isSelected = prefsService.interests.contains(interest);
        
        return InkWell(
          onTap: () {
            if (isSelected) {
              prefsService.removeInterest(interest);
            } else {
              prefsService.addInterest(interest);
            }
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primaryColor.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primaryColor : Colors.transparent,
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                interest,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isSelected ? AppColors.primaryColor : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required Function(bool) onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildDropdownTile({
    required String title,
    required String subtitle,
    required String value,
    required List<String> options,
    required Function(String?) onChanged,
    required IconData icon,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: DropdownButton<String>(
        value: value,
        underline: Container(),
        items: options.map((String option) {
          return DropdownMenuItem<String>(
            value: option,
            child: Text(option),
          );
        }).toList(),
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildDashboardCustomization(UserPreferencesService prefsService) {
    final widgets = [
      'Empreinte carbone',
      'Conseils du jour',
      'Défis en cours',
      'Derniers scans',
      'Badges récents',
      'Actualités écologiques',
      'Économies réalisées',
      'Impact communautaire'
    ];
    
    return Column(
      children: [
        const Text(
          'Faites glisser les widgets pour les réorganiser. Activez ou désactivez ceux que vous souhaitez voir sur votre tableau de bord.',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 16),
        ReorderableListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: widgets.length,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) {
                newIndex -= 1;
              }
              final item = widgets.removeAt(oldIndex);
              widgets.insert(newIndex, item);
              
              // Mettre à jour l'ordre dans le service
              prefsService.setDashboardWidgetsOrder(widgets);
            });
          },
          itemBuilder: (context, index) {
            return _buildDashboardWidgetTile(
              key: Key(widgets[index]),
              title: widgets[index],
              enabled: prefsService.enabledWidgets.contains(widgets[index]),
              onToggle: (value) {
                if (value) {
                  prefsService.enableWidget(widgets[index]);
                } else {
                  prefsService.disableWidget(widgets[index]);
                }
                setState(() {});
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildDashboardWidgetTile({
    required Key key,
    required String title,
    required bool enabled,
    required Function(bool) onToggle,
  }) {
    return ListTile(
      key: key,
      leading: const Icon(Icons.drag_indicator),
      title: Text(title),
      trailing: Switch(
        value: enabled,
        onChanged: onToggle,
        activeColor: AppColors.primaryColor,
      ),
    );
  }
} 