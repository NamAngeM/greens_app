import 'package:flutter/material.dart';
import 'package:greens_app/utils/app_colors.dart';
import 'package:greens_app/utils/app_router.dart';
import 'package:greens_app/views/home/home_view.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../utils/app_router.dart';

class Question5View extends StatefulWidget {
  const Question5View({Key? key}) : super(key: key);

  @override
  State<Question5View> createState() => _Question5ViewState();
}

class _Question5ViewState extends State<Question5View> {
  String? _selectedOption;
  final double _progressValue = 1.0; // 5/5 questions

  final List<String> _options = [
    'Je commence tout juste',
    'Je m\'implique de temps en temps',
    'Je suis régulièrement actif',
    'Je suis très engagé et militant',
    'Je suis un expert dans le domaine'
  ];

  void _selectOption(String option) async {
    setState(() {
      _selectedOption = option;
    });
    
    // Enregistrer la réponse (à implémenter avec un service)
    _saveAnswer(option);
    
    // Marquer les questions comme complétées
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_completed_questions', true);
    
    // Naviguer vers la page d'accueil en utilisant les routes nommées
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false, // Supprime toutes les routes précédentes
    );
  }

  void _saveAnswer(String answer) {
    // TODO: Implémenter la sauvegarde de la réponse
    // Cela pourrait être fait avec SharedPreferences, Firebase, ou un autre service
    print('Réponse à la question 5: $answer');
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
                'Quel est votre niveau d\'engagement dans l\'écologie ?',
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