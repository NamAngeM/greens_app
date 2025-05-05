import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';

class N8nChatbotService {
  static final N8nChatbotService _instance = N8nChatbotService._internal();
  factory N8nChatbotService() => _instance;
  static N8nChatbotService get instance => _instance;

  String? _webhookUrl;
  bool _isInitialized = false;
  
  bool get isInitialized => _isInitialized;

  N8nChatbotService._internal();

  Future<void> initialize({required String webhookUrl}) async {
    _webhookUrl = webhookUrl;
    _isInitialized = true;
  }

  Future<String> sendMessage(String message) async {
    try {
      // Simulation d'une réponse pour le moment
      return 'Réponse du chatbot: $message';
    } catch (e) {
      return 'Erreur: $e';
    }
  }
  
  Future<String> getResponse(String text, {BuildContext? context}) async {
    if (!_isInitialized) {
      return "Service chatbot non initialisé";
    }
    
    try {
      // Simulation de réponse pour le moment
      await Future.delayed(const Duration(seconds: 1));
      return "Voici ma réponse à: $text";
    } catch (e) {
      return "Erreur: $e";
    }
  }
}
