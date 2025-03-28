import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:greens_app/controllers/carbon_footprint_controller.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/widgets/custom_button.dart';
import 'package:greens_app/widgets/custom_text_field.dart';
import 'package:greens_app/views/carbon/carbon_results_view.dart';

import '../../controllers/carbon_footprint_controller.dart';
import '../../utils/app_colors.dart';
import 'carbon_results_view.dart';

class CarbonCalculatorView extends StatefulWidget {
  const CarbonCalculatorView({Key? key}) : super(key: key);

  @override
  State<CarbonCalculatorView> createState() => _CarbonCalculatorViewState();
}
class _CarbonCalculatorViewState extends State<CarbonCalculatorView> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  final List<Map<String, dynamic>> _answers = [];
  
  final List<Map<String, dynamic>> _questions = [
    {
      'question': 'Quel est votre mode de transport principal ?',
      'options': [
        {'text': 'Voiture individuelle', 'value': 5, 'icon': Icons.directions_car},
        {'text': 'Transports en commun', 'value': 2, 'icon': Icons.directions_bus},
        {'text': 'Vélo ou marche', 'value': 0, 'icon': Icons.directions_bike},
        {'text': 'Covoiturage', 'value': 3, 'icon': Icons.people},
        {'text': 'Moto ou scooter', 'value': 4, 'icon': Icons.motorcycle},
      ],
    },
    {
      'question': 'Quelle est votre consommation de viande ?',
      'options': [
        {'text': 'Tous les jours', 'value': 5, 'icon': Icons.restaurant},
        {'text': '3-5 fois par semaine', 'value': 3, 'icon': Icons.restaurant},
        {'text': '1-2 fois par semaine', 'value': 2, 'icon': Icons.restaurant},
        {'text': 'Rarement', 'value': 1, 'icon': Icons.restaurant_outlined},
        {'text': 'Jamais (végétarien/végétalien)', 'value': 0, 'icon': Icons.grass},
      ],
    },
    {
      'question': 'Comment gérez-vous vos déchets ?',
      'options': [
        {'text': 'Je trie systématiquement', 'value': 1, 'icon': Icons.recycling},
        {'text': 'Je trie partiellement', 'value': 3, 'icon': Icons.delete_outline},
        {'text': 'Je ne trie pas', 'value': 5, 'icon': Icons.delete},
        {'text': 'Je pratique le zéro déchet', 'value': 0, 'icon': Icons.eco},
      ],
    },
    {
      'question': 'Quelle est votre consommation d\'énergie à domicile ?',
      'options': [
        {'text': 'Très économe (LED, appareils A+++)', 'value': 1, 'icon': Icons.lightbulb_outline},
        {'text': 'Modérée', 'value': 3, 'icon': Icons.lightbulb},
        {'text': 'Élevée', 'value': 5, 'icon': Icons.power},
        {'text': 'J\'utilise des énergies renouvelables', 'value': 0, 'icon': Icons.solar_power},
      ],
    },
    {
      'question': 'Combien de fois prenez-vous l\'avion par an ?',
      'options': [
        {'text': 'Jamais', 'value': 0, 'icon': Icons.airplanemode_inactive},
        {'text': '1-2 fois', 'value': 3, 'icon': Icons.airplanemode_active},
        {'text': '3-5 fois', 'value': 4, 'icon': Icons.airplanemode_active},
        {'text': 'Plus de 5 fois', 'value': 5, 'icon': Icons.airplanemode_active},
      ],
    },
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _questions.length) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _calculateResults();
    }
  }

  void _previousPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _selectOption(Map<String, dynamic> option, int questionIndex) {
    if (_answers.length > questionIndex) {
      _answers[questionIndex] = option;
    } else {
      _answers.add(option);
    }
    
    // Passer à la question suivante après un court délai
    Future.delayed(const Duration(milliseconds: 300), () {
      _nextPage();
    });
  }

  void _calculateResults() {
    final carbonFootprintController = Provider.of<CarbonFootprintController>(context, listen: false);
    
    // Calculer le score total
    int totalScore = 0;
    for (var answer in _answers) {
      totalScore += answer['value'] as int;
    }
    
    // Enregistrer le résultat
    carbonFootprintController.saveCarbonFootprint(totalScore.toDouble());
    
    // Naviguer vers la page de résultats
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CarbonResultsView(
          score: totalScore,
          answers: _answers,
          questions: _questions,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Calculateur d\'empreinte carbone'),
        backgroundColor: AppColors.primaryColor,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (_currentPage > 0) {
              _previousPage();
            } else {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          // Indicateur de progression
          LinearProgressIndicator(
            value: (_currentPage + 1) / (_questions.length + 1),
            backgroundColor: Colors.grey.withOpacity(0.2),
            color: AppColors.secondaryColor,
          ),
          
          // Questions
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              onPageChanged: (index) {
                setState(() {
                  _currentPage = index;
                });
              },
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionPage(index);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionPage(int index) {
    final question = _questions[index];
    final options = question['options'] as List<Map<String, dynamic>>;
    
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Numéro de question
          Text(
            'Question ${index + 1}/${_questions.length}',
            style: const TextStyle(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          
          // Question
          Text(
            question['question'] as String,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textColor,
            ),
          ),
          const SizedBox(height: 32),
          
          // Options
          Expanded(
            child: ListView.builder(
              itemCount: options.length,
              itemBuilder: (context, optionIndex) {
                final option = options[optionIndex];
                final bool isSelected = _answers.isNotEmpty && 
                                       _answers.length > index && 
                                       _answers[index] == option;
                
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: InkWell(
                    onTap: () => _selectOption(option, index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primaryColor : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: isSelected 
                                  ? Colors.white.withOpacity(0.2) 
                                  : AppColors.primaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              option['icon'] as IconData,
                              color: isSelected 
                                  ? Colors.white 
                                  : AppColors.primaryColor,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Text(
                              option['text'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: isSelected 
                                    ? Colors.white 
                                    : AppColors.textColor,
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 24,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
