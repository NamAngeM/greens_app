import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_styles.dart';
import 'package:greens_app/widgets/custom_button.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/carbon_footprint_controller.dart';

class DigitalFootprintQuestionnaire extends StatefulWidget {
  final Function(double) onDigitalScoreCalculated;

  const DigitalFootprintQuestionnaire({
    Key? key,
    required this.onDigitalScoreCalculated,
  }) : super(key: key);

  @override
  State<DigitalFootprintQuestionnaire> createState() => _DigitalFootprintQuestionnaireState();
}

class _DigitalFootprintQuestionnaireState extends State<DigitalFootprintQuestionnaire> {
  // Valeurs par défaut pour les sliders et les champs numériques
  double _hoursVideoSD = 1.0;
  double _hoursVideoHD = 1.0;
  double _hoursVideo4K = 0.0;
  double _hoursMusic = 2.0;
  double _hoursVideoCalls = 1.0;
  
  int _emailsSimple = 10;
  int _emailsWithAttachment = 2;
  int _spamEmails = 5;
  
  double _cloudStorageGB = 5.0;
  int _photosStored = 500;
  int _videoMinutesStored = 60;
  
  double _hoursSmartphone = 3.0;
  double _hoursLaptop = 2.0;
  double _hoursTablet = 0.5;
  double _hoursDesktop = 0.0;

  bool _isCalculating = false;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Votre empreinte numérique',
            style: AppStyles.heading2,
          ),
          const SizedBox(height: 16),
          Text(
            'Le numérique représente environ 4% des émissions mondiales de gaz à effet de serre. Répondez à ces questions pour évaluer votre impact.',
            style: AppStyles.bodyText,
          ),
          const SizedBox(height: 24),
          
          // Section Streaming
          _buildSectionHeader('Streaming et médias', Icons.play_circle_outline),
          _buildSliderQuestion(
            'Combien d\'heures par jour regardez-vous des vidéos en qualité standard (SD) ?',
            _hoursVideoSD,
            0,
            8,
            (value) => setState(() => _hoursVideoSD = value),
          ),
          _buildSliderQuestion(
            'Combien d\'heures par jour regardez-vous des vidéos en haute définition (HD) ?',
            _hoursVideoHD,
            0,
            8,
            (value) => setState(() => _hoursVideoHD = value),
          ),
          _buildSliderQuestion(
            'Combien d\'heures par jour regardez-vous des vidéos en 4K ?',
            _hoursVideo4K,
            0,
            8,
            (value) => setState(() => _hoursVideo4K = value),
          ),
          _buildSliderQuestion(
            'Combien d\'heures par jour écoutez-vous de la musique en streaming ?',
            _hoursMusic,
            0,
            12,
            (value) => setState(() => _hoursMusic = value),
          ),
          _buildSliderQuestion(
            'Combien d\'heures par jour passez-vous en visioconférence ?',
            _hoursVideoCalls,
            0,
            8,
            (value) => setState(() => _hoursVideoCalls = value),
          ),
          
          const SizedBox(height: 24),
          
          // Section Emails
          _buildSectionHeader('Emails', Icons.email_outlined),
          _buildNumberInputQuestion(
            'Combien d\'emails sans pièce jointe envoyez-vous par jour ?',
            _emailsSimple,
            (value) => setState(() => _emailsSimple = value),
          ),
          _buildNumberInputQuestion(
            'Combien d\'emails avec pièce jointe envoyez-vous par jour ?',
            _emailsWithAttachment,
            (value) => setState(() => _emailsWithAttachment = value),
          ),
          _buildNumberInputQuestion(
            'Combien de spams recevez-vous par jour ?',
            _spamEmails,
            (value) => setState(() => _spamEmails = value),
          ),
          
          const SizedBox(height: 24),
          
          // Section Stockage
          _buildSectionHeader('Stockage cloud', Icons.cloud_outlined),
          _buildSliderQuestion(
            'Combien de Go utilisez-vous pour votre stockage cloud ?',
            _cloudStorageGB,
            0,
            1000,
            (value) => setState(() => _cloudStorageGB = value),
            divisions: 100,
            suffix: ' Go',
          ),
          _buildNumberInputQuestion(
            'Combien de photos stockez-vous au total ?',
            _photosStored,
            (value) => setState(() => _photosStored = value),
            step: 100,
          ),
          _buildNumberInputQuestion(
            'Combien de minutes de vidéo stockez-vous au total ?',
            _videoMinutesStored,
            (value) => setState(() => _videoMinutesStored = value),
            step: 10,
          ),
          
          const SizedBox(height: 24),
          
          // Section Appareils
          _buildSectionHeader('Utilisation des appareils', Icons.devices_outlined),
          _buildSliderQuestion(
            'Combien d\'heures par jour utilisez-vous votre smartphone ?',
            _hoursSmartphone,
            0,
            12,
            (value) => setState(() => _hoursSmartphone = value),
          ),
          _buildSliderQuestion(
            'Combien d\'heures par jour utilisez-vous votre ordinateur portable ?',
            _hoursLaptop,
            0,
            12,
            (value) => setState(() => _hoursLaptop = value),
          ),
          _buildSliderQuestion(
            'Combien d\'heures par jour utilisez-vous votre tablette ?',
            _hoursTablet,
            0,
            12,
            (value) => setState(() => _hoursTablet = value),
          ),
          _buildSliderQuestion(
            'Combien d\'heures par jour utilisez-vous votre ordinateur de bureau ?',
            _hoursDesktop,
            0,
            12,
            (value) => setState(() => _hoursDesktop = value),
          ),
          
          const SizedBox(height: 32),
          
          // Bouton de calcul
          Center(
            child: CustomButton(
              text: 'Calculer mon empreinte numérique',
              onPressed: _calculateDigitalFootprint,
              isLoading: _isCalculating,
              color: AppColors.primaryColor,
              width: double.infinity,
              height: 50,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // Méthode pour calculer l'empreinte numérique
  void _calculateDigitalFootprint() {
    setState(() {
      _isCalculating = true;
    });

    // Utiliser le contrôleur pour calculer l'empreinte numérique
    final controller = Provider.of<CarbonFootprintController>(context, listen: false);
    
    controller.calculateDigitalFootprint(
      // Streaming
      hoursVideoSD: _hoursVideoSD,
      hoursVideoHD: _hoursVideoHD,
      hoursVideo4K: _hoursVideo4K,
      hoursMusic: _hoursMusic,
      hoursVideoCalls: _hoursVideoCalls,
      
      // Emails
      emailsSimple: _emailsSimple,
      emailsWithAttachment: _emailsWithAttachment,
      spamEmails: _spamEmails,
      
      // Stockage
      cloudStorageGB: _cloudStorageGB,
      photosStored: _photosStored,
      videoMinutesStored: _videoMinutesStored,
      
      // Utilisation des appareils
      hoursSmartphone: _hoursSmartphone,
      hoursLaptop: _hoursLaptop,
      hoursTablet: _hoursTablet,
      hoursDesktop: _hoursDesktop,
    ).then((digitalScore) {
      // Appeler le callback avec le score calculé
      widget.onDigitalScoreCalculated(digitalScore);
      
      setState(() {
        _isCalculating = false;
      });
    });
  }

  // Widget pour construire un en-tête de section
  Widget _buildSectionHeader(String title, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primaryColor, size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: AppStyles.heading3,
            ),
          ],
        ),
        const Divider(color: AppColors.primaryColor, thickness: 1),
        const SizedBox(height: 16),
      ],
    );
  }

  // Widget pour construire une question avec slider
  Widget _buildSliderQuestion(
    String question,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    int? divisions,
    String suffix = ' h',
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: AppStyles.bodyText),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Slider(
                value: value,
                min: min,
                max: max,
                divisions: divisions ?? (max - min).toInt() * 4,
                activeColor: AppColors.primaryColor,
                inactiveColor: AppColors.primaryColor.withOpacity(0.3),
                onChanged: onChanged,
              ),
            ),
            SizedBox(
              width: 60,
              child: Text(
                '${value.toStringAsFixed(1)}$suffix',
                style: AppStyles.bodyTextBold,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  // Widget pour construire une question avec champ numérique
  Widget _buildNumberInputQuestion(
    String question,
    int value,
    Function(int) onChanged, {
    int step = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(question, style: AppStyles.bodyText),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline),
              color: AppColors.primaryColor,
              onPressed: () {
                if (value > 0) {
                  onChanged(value - step);
                }
              },
            ),
            Expanded(
              child: Text(
                value.toString(),
                textAlign: TextAlign.center,
                style: AppStyles.bodyTextBold,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline),
              color: AppColors.primaryColor,
              onPressed: () {
                onChanged(value + step);
              },
            ),
          ],
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}
