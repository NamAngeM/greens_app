import 'package:flutter/material.dart';
import '../models/environmental_profile.dart';

class EnvironmentalQuestionnaireScreen extends StatefulWidget {
  final EnvironmentalProfile? initialProfile;
  final Function(EnvironmentalProfile) onComplete;

  const EnvironmentalQuestionnaireScreen({
    Key? key,
    this.initialProfile,
    required this.onComplete,
  }) : super(key: key);

  @override
  State<EnvironmentalQuestionnaireScreen> createState() => _EnvironmentalQuestionnaireScreenState();
}

class _EnvironmentalQuestionnaireScreenState extends State<EnvironmentalQuestionnaireScreen> {
  late PageController _pageController;
  late EnvironmentalProfile _profile;
  int _currentPage = 0;
  final int _totalPages = 4; // Transport, Alimentation, Numérique, Pollution sonore

  // Questions numériques
  double _streamingHoursPerDay = 2.0;
  double _socialMediaHoursPerDay = 2.0;
  double _videoCallsHoursPerWeek = 2.0;
  double _cloudStorageGB = 50.0;
  int _emailsPerDay = 20;
  bool _cleanInbox = false;
  int _smartphonesOwnedLast5Years = 2;
  int _computersOwnedLast5Years = 1;
  bool _usesEcoSearchEngine = false;
  bool _darkModeEnabled = false;
  bool _lowDataModeEnabled = false;

  // Questions pollution sonore
  int _headphonesUseHoursPerDay = 2;
  double _averageVolumeLevel = 60;
  bool _usesNoiseCancellation = false;
  int _exposureToLoudEnvironmentsHoursPerWeek = 5;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _profile = widget.initialProfile ?? EnvironmentalProfile.empty();
    
    // Initialiser les valeurs à partir du profil si disponible
    if (widget.initialProfile != null) {
      final digital = widget.initialProfile!.digitalProfile;
      _streamingHoursPerDay = digital.streamingHoursPerDay;
      _socialMediaHoursPerDay = digital.socialMediaHoursPerDay;
      _videoCallsHoursPerWeek = digital.videoCallsHoursPerWeek;
      _cloudStorageGB = digital.cloudStorageGB;
      _emailsPerDay = digital.emailsPerDay;
      _cleanInbox = digital.cleanInbox;
      _smartphonesOwnedLast5Years = digital.smartphonesOwnedLast5Years;
      _computersOwnedLast5Years = digital.computersOwnedLast5Years;
      _usesEcoSearchEngine = digital.usesEcoSearchEngine;
      _darkModeEnabled = digital.darkModeEnabled;
      _lowDataModeEnabled = digital.lowDataModeEnabled;
      
      _headphonesUseHoursPerDay = digital.headphonesUseHoursPerDay;
      _averageVolumeLevel = digital.averageVolumeLevel;
      _usesNoiseCancellation = digital.usesNoiseCancellation;
      _exposureToLoudEnvironmentsHoursPerWeek = digital.exposureToLoudEnvironmentsHoursPerWeek;
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _totalPages - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishQuestionnaire();
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishQuestionnaire() {
    // Créer le profil numérique
    final digitalProfile = DigitalProfile(
      streamingHoursPerDay: _streamingHoursPerDay,
      socialMediaHoursPerDay: _socialMediaHoursPerDay,
      videoCallsHoursPerWeek: _videoCallsHoursPerWeek,
      cloudStorageGB: _cloudStorageGB,
      emailsPerDay: _emailsPerDay,
      cleanInbox: _cleanInbox,
      smartphonesOwnedLast5Years: _smartphonesOwnedLast5Years,
      computersOwnedLast5Years: _computersOwnedLast5Years,
      usesEcoSearchEngine: _usesEcoSearchEngine,
      darkModeEnabled: _darkModeEnabled,
      lowDataModeEnabled: _lowDataModeEnabled,
      headphonesUseHoursPerDay: _headphonesUseHoursPerDay,
      averageVolumeLevel: _averageVolumeLevel,
      usesNoiseCancellation: _usesNoiseCancellation,
      exposureToLoudEnvironmentsHoursPerWeek: _exposureToLoudEnvironmentsHoursPerWeek,
    );

    // Mettre à jour le profil
    final updatedProfile = _profile.copyWith(
      digitalProfile: digitalProfile,
    );

    // Calculer les empreintes
    final carbonFootprint = updatedProfile.calculateTotalCarbonFootprint();
    final finalProfile = updatedProfile.copyWith(
      carbonFootprint: carbonFootprint,
    );

    // Afficher le résultat
    showDialog(
      context: context,
      builder: (context) => _buildResultDialog(finalProfile),
    ).then((_) {
      // Retourner le profil mis à jour
      widget.onComplete(finalProfile);
    });
  }

  Widget _buildResultDialog(EnvironmentalProfile profile) {
    final digitalCarbonFootprint = profile.digitalProfile.calculateCarbonFootprint() * 1000; // en kg
    final soundImpact = profile.digitalProfile.calculateSoundHealthImpact();
    
    return AlertDialog(
      title: const Text('Résultats du questionnaire'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Votre empreinte écologique numérique',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 12),
            
            // Empreinte carbone numérique
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.cloud_outlined, color: _getCarbonColor(digitalCarbonFootprint)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Empreinte carbone numérique: ${digitalCarbonFootprint.toStringAsFixed(1)} kg CO₂e/an',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getCarbonColor(digitalCarbonFootprint),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: _getCarbonScore(digitalCarbonFootprint),
                      color: _getCarbonColor(digitalCarbonFootprint),
                      backgroundColor: Colors.grey[200],
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    Text(_getCarbonFeedback(digitalCarbonFootprint)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Impact de la pollution sonore
            Card(
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.volume_up_outlined, color: _getSoundColor(soundImpact)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Impact sonore sur la santé: ${soundImpact.toStringAsFixed(0)}/100',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _getSoundColor(soundImpact),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: soundImpact / 100,
                      color: _getSoundColor(soundImpact),
                      backgroundColor: Colors.grey[200],
                      minHeight: 8,
                    ),
                    const SizedBox(height: 12),
                    Text(_getSoundFeedback(soundImpact)),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Score total
            const Text(
              'Votre empreinte carbone globale',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${profile.carbonFootprint.toStringAsFixed(2)} tonnes CO₂e par an',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            
            // Conseils
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.eco, color: Colors.green[700]),
                      const SizedBox(width: 8),
                      Text(
                        'Recommandations',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.green[700],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getOverallRecommendation(profile),
                    style: TextStyle(color: Colors.green[800]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          child: const Text('Fermer'),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  Color _getCarbonColor(double carbonKg) {
    if (carbonKg < 200) return Colors.green;
    if (carbonKg < 400) return Colors.amber;
    if (carbonKg < 600) return Colors.orange;
    return Colors.red;
  }

  double _getCarbonScore(double carbonKg) {
    // 1000 kg est considéré comme un maximum raisonnable
    double score = carbonKg / 1000;
    if (score > 1) return 1;
    return score;
  }

  String _getCarbonFeedback(double carbonKg) {
    if (carbonKg < 200) {
      return 'Votre empreinte numérique est faible. Continuez vos bonnes pratiques!';
    } else if (carbonKg < 400) {
      return 'Votre empreinte numérique est dans la moyenne. Quelques ajustements pourraient l\'améliorer.';
    } else if (carbonKg < 600) {
      return 'Votre empreinte numérique est élevée. Essayez de réduire votre consommation de données et prolongez la durée de vie de vos appareils.';
    } else {
      return 'Votre empreinte numérique est très élevée. Consultez nos conseils pour la réduire significativement.';
    }
  }

  Color _getSoundColor(double impact) {
    if (impact < 30) return Colors.green;
    if (impact < 60) return Colors.amber;
    if (impact < 80) return Colors.orange;
    return Colors.red;
  }

  String _getSoundFeedback(double impact) {
    if (impact < 30) {
      return 'Votre exposition au bruit est faible et respecte votre santé auditive.';
    } else if (impact < 60) {
      return 'Votre exposition au bruit est modérée. Pensez à faire des pauses régulières.';
    } else if (impact < 80) {
      return 'Votre exposition au bruit est élevée. Réduisez le volume et limitez les environnements bruyants.';
    } else {
      return 'Votre exposition au bruit est très élevée et présente des risques pour votre santé auditive. Prenez des mesures rapidement.';
    }
  }

  String _getOverallRecommendation(EnvironmentalProfile profile) {
    final List<String> recommendations = [];
    
    final digitalCarbonFootprint = profile.digitalProfile.calculateCarbonFootprint() * 1000;
    if (digitalCarbonFootprint > 400) {
      recommendations.add('Réduisez votre consommation de streaming et prolongez la durée de vie de vos appareils électroniques.');
    }
    
    final soundImpact = profile.digitalProfile.calculateSoundHealthImpact();
    if (soundImpact > 60) {
      recommendations.add('Limitez votre exposition aux environnements bruyants et baissez le volume de vos écouteurs.');
    }
    
    if (recommendations.isEmpty) {
      return 'Votre profil environnemental est bon. Continuez à maintenir de bonnes habitudes pour préserver la planète et votre santé!';
    } else {
      return recommendations.join('\n\n');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Questionnaire Environnemental'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Indicateur de progression
          LinearProgressIndicator(
            value: (_currentPage + 1) / _totalPages,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Theme.of(context).primaryColor),
          ),
          
          // Pages du questionnaire
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (int page) {
                setState(() {
                  _currentPage = page;
                });
              },
              children: [
                _buildTransportPage(),
                _buildFoodPage(),
                _buildDigitalPage(),
                _buildSoundPollutionPage(),
              ],
            ),
          ),
          
          // Navigation
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (_currentPage > 0)
                  ElevatedButton(
                    onPressed: _previousPage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[300],
                      foregroundColor: Colors.black87,
                    ),
                    child: const Text('Précédent'),
                  )
                else
                  const SizedBox.shrink(),
                
                ElevatedButton(
                  onPressed: _nextPage,
                  child: Text(_currentPage < _totalPages - 1 ? 'Suivant' : 'Terminer'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransportPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Transport',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Cette section sera complétée ultérieurement avec des questions sur vos habitudes de transport',
            style: TextStyle(fontSize: 16),
          ),
          
          // Placeholder pour les questions futures
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Widget _buildFoodPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Alimentation',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          
          const Text(
            'Cette section sera complétée ultérieurement avec des questions sur vos habitudes alimentaires',
            style: TextStyle(fontSize: 16),
          ),
          
          // Placeholder pour les questions futures
          const SizedBox(height: 200),
        ],
      ),
    );
  }

  Widget _buildDigitalPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pollution Numérique',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Répondez à ces questions pour évaluer votre empreinte numérique',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          
          // Usage quotidien
          _buildSectionTitle('Usage quotidien'),
          
          _buildSliderQuestion(
            'Combien d\'heures passez-vous à regarder des vidéos en streaming par jour ?',
            _streamingHoursPerDay,
            0,
            10,
            (value) => setState(() => _streamingHoursPerDay = value),
            suffix: 'h',
          ),
          
          _buildSliderQuestion(
            'Combien d\'heures passez-vous sur les réseaux sociaux par jour ?',
            _socialMediaHoursPerDay,
            0,
            10,
            (value) => setState(() => _socialMediaHoursPerDay = value),
            suffix: 'h',
          ),
          
          _buildSliderQuestion(
            'Combien d\'heures d\'appels vidéo faites-vous par semaine ?',
            _videoCallsHoursPerWeek,
            0,
            20,
            (value) => setState(() => _videoCallsHoursPerWeek = value),
            suffix: 'h',
          ),
          
          // Stockage et emails
          _buildSectionTitle('Stockage et communication'),
          
          _buildSliderQuestion(
            'Quel volume de stockage cloud utilisez-vous (en GB) ?',
            _cloudStorageGB,
            0,
            500,
            (value) => setState(() => _cloudStorageGB = value),
            suffix: 'GB',
            divisions: 50,
          ),
          
          _buildIntSliderQuestion(
            'Combien d\'emails envoyez-vous par jour en moyenne ?',
            _emailsPerDay,
            0,
            100,
            (value) => setState(() => _emailsPerDay = value),
          ),
          
          _buildSwitchQuestion(
            'Nettoyez-vous régulièrement votre boîte mail ?',
            _cleanInbox,
            (value) => setState(() => _cleanInbox = value),
          ),
          
          // Appareils
          _buildSectionTitle('Appareils électroniques'),
          
          _buildIntSliderQuestion(
            'Combien de smartphones avez-vous possédés ces 5 dernières années ?',
            _smartphonesOwnedLast5Years,
            0,
            10,
            (value) => setState(() => _smartphonesOwnedLast5Years = value),
          ),
          
          _buildIntSliderQuestion(
            'Combien d\'ordinateurs avez-vous possédés ces 5 dernières années ?',
            _computersOwnedLast5Years,
            0,
            5,
            (value) => setState(() => _computersOwnedLast5Years = value),
          ),
          
          // Bonnes pratiques
          _buildSectionTitle('Bonnes pratiques'),
          
          _buildSwitchQuestion(
            'Utilisez-vous un moteur de recherche écologique (Ecosia, Lilo...) ?',
            _usesEcoSearchEngine,
            (value) => setState(() => _usesEcoSearchEngine = value),
          ),
          
          _buildSwitchQuestion(
            'Utilisez-vous le mode sombre sur vos appareils ?',
            _darkModeEnabled,
            (value) => setState(() => _darkModeEnabled = value),
          ),
          
          _buildSwitchQuestion(
            'Activez-vous le mode économie de données sur vos appareils ?',
            _lowDataModeEnabled,
            (value) => setState(() => _lowDataModeEnabled = value),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundPollutionPage() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pollution Sonore',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Évaluez votre exposition aux nuisances sonores',
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          
          // Usage écouteurs
          _buildSectionTitle('Utilisation des écouteurs/casques'),
          
          _buildIntSliderQuestion(
            'Combien d\'heures par jour utilisez-vous des écouteurs/casque ?',
            _headphonesUseHoursPerDay,
            0,
            12,
            (value) => setState(() => _headphonesUseHoursPerDay = value),
            suffix: 'h',
          ),
          
          _buildSliderQuestion(
            'À quel niveau de volume écoutez-vous habituellement (0-100) ?',
            _averageVolumeLevel,
            0,
            100,
            (value) => setState(() => _averageVolumeLevel = value),
            suffix: '%',
            divisions: 10,
          ),
          
          _buildSwitchQuestion(
            'Utilisez-vous la réduction de bruit active ?',
            _usesNoiseCancellation,
            (value) => setState(() => _usesNoiseCancellation = value),
          ),
          
          // Environnement
          _buildSectionTitle('Exposition au bruit environnant'),
          
          _buildIntSliderQuestion(
            'Combien d\'heures par semaine êtes-vous exposé(e) à des environnements bruyants (concerts, travaux, circulation dense) ?',
            _exposureToLoudEnvironmentsHoursPerWeek,
            0,
            40,
            (value) => setState(() => _exposureToLoudEnvironmentsHoursPerWeek = value),
            suffix: 'h',
          ),
          
          const SizedBox(height: 24),
          
          // Conseils
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700]),
                    const SizedBox(width: 8),
                    Text(
                      'Le saviez-vous ?',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue[700],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Une exposition prolongée à un volume supérieur à 85 dB peut causer des dommages auditifs permanents. Pensez à limiter votre exposition et à utiliser la réduction de bruit pour réduire la fatigue auditive.',
                  style: TextStyle(color: Colors.blue[700]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
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
          const SizedBox(height: 4),
          Divider(color: Colors.grey[300], thickness: 2),
        ],
      ),
    );
  }

  Widget _buildSliderQuestion(
    String question,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    String suffix = '',
    int? divisions,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value,
                  min: min,
                  max: max,
                  divisions: divisions,
                  onChanged: onChanged,
                ),
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '${value.toStringAsFixed(1)}$suffix',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIntSliderQuestion(
    String question,
    int value,
    int min,
    int max,
    Function(int) onChanged, {
    String suffix = '',
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(question),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: Slider(
                  value: value.toDouble(),
                  min: min.toDouble(),
                  max: max.toDouble(),
                  divisions: max - min,
                  onChanged: (newValue) => onChanged(newValue.round()),
                ),
              ),
              Container(
                width: 60,
                alignment: Alignment.center,
                child: Text(
                  '$value$suffix',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchQuestion(
    String question,
    bool value,
    Function(bool) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(question)),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Theme.of(context).primaryColor,
          ),
        ],
      ),
    );
  }
} 