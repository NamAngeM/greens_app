import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/views/questions/question_3_view.dart';

import '../../utils/app_router.dart';

class Question2View extends StatefulWidget {
  const Question2View({Key? key}) : super(key: key);

  @override
  State<Question2View> createState() => _Question2ViewState();
}

class _Question2ViewState extends State<Question2View> {
  String? _selectedOption;
  final double _progressValue = 0.4; // 2/5 questions

  final List<String> _options = [
    'Réduire mon empreinte carbone',
    'Apprendre à recycler correctement',
    'Découvrir des alternatives écologiques',
    'Participer à des initiatives locales',
    'Autre'
  ];

  void _selectOption(String option) {
    setState(() {
      _selectedOption = option;
    });
    
    // Enregistrer la réponse (à implémenter avec un service)
    _saveAnswer(option);
    
    // Naviguer vers la question suivante
    Navigator.pushNamed(context, AppRoutes.question3);
  }

  void _saveAnswer(String answer) {
    // TODO: Implémenter la sauvegarde de la réponse
    // Cela pourrait être fait avec SharedPreferences, Firebase, ou un autre service
    print('Réponse à la question 2: $answer');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1E3246), // Couleur de fond bleu foncé
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec l'icône et le texte "Hello"
              Row(
                children: [
                  Image.asset(
                    'assets/images/logo/green_minds_logo.png',
                    height: 28,
                    width: 28,
                    color: const Color(0xFF4CAF50), // Vert
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Hello,',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'RethinkSans',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 16),
              
              // Question principale
              Text(
                'Quel est votre objectif principal en utilisant GreenMinds ?',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'RethinkSans',
                  height: 1.2,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Barre de progression
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progressValue,
                  backgroundColor: Colors.white,
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4CAF50)),
                  minHeight: 8,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Options
              Expanded(
                child: ListView.builder(
                  itemCount: _options.length,
                  itemBuilder: (context, index) {
                    final bool isSelected = _selectedOption == _options[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: ElevatedButton(
                        onPressed: () => _selectOption(_options[index]),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isSelected ? const Color(0xFF34D399) : Colors.white,
                          foregroundColor: isSelected ? Colors.white : Colors.black87,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                        ),
                        child: Text(
                          _options[index],
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'RethinkSans',
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    );
                  },
                ),
              ),
              
              // Texte d'explication en bas
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  'Répondez à quelques questions pour personnaliser votre expérience Green Minds et commencer.',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                    fontFamily: 'RethinkSans',
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}