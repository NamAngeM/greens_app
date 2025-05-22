import 'package:flutter/material.dart';
import 'package:greens_app/services/local_chatbot_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final chatbot = LocalChatbotService.instance;
  await chatbot.initialize();
  
  final testQuestions = [
    "Qu'est-ce que l'écologie ?",
    "Comment réduire ma consommation d'énergie ?",
    "Qu'est-ce que le réchauffement climatique ?",
    "Comment recycler correctement ?",
  ];
  
  for (final question in testQuestions) {
    print('\nQuestion: $question');
    final response = await chatbot.sendMessage(question);
    print('Réponse: $response');
  }
} 