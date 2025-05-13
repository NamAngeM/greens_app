// lib/models/chatbot_message.dart
import 'package:flutter/foundation.dart';

/// Modèle pour représenter un message dans le chatbot
class ChatbotMessage {
  /// Identifiant unique du message
  final String id;
  
  /// Contenu du message
  final String text;
  
  /// Indique si le message vient de l'utilisateur (true) ou du chatbot (false)
  final bool isUser;
  
  /// Horodatage du message
  final DateTime timestamp;
  
  /// Actions suggérées associées au message (peut être vide)
  final List<String> suggestedActions;
  
  /// Données supplémentaires associées au message (arbitraires)
  final Map<String, dynamic>? metadata;

  /// Constructeur
  ChatbotMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.suggestedActions = const [],
    this.metadata,
  });

  /// Créer à partir d'un map JSON
  factory ChatbotMessage.fromJson(Map<String, dynamic> json) {
    return ChatbotMessage(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      suggestedActions: List<String>.from(json['suggestedActions'] ?? []),
      metadata: json['metadata'] as Map<String, dynamic>?,
    );
  }

  /// Convertir en map JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'suggestedActions': suggestedActions,
      'metadata': metadata,
    };
  }

  /// Clone ce message avec des modifications optionnelles
  ChatbotMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    DateTime? timestamp,
    List<String>? suggestedActions,
    Map<String, dynamic>? metadata,
  }) {
    return ChatbotMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      timestamp: timestamp ?? this.timestamp,
      suggestedActions: suggestedActions ?? this.suggestedActions,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  String toString() => 'ChatbotMessage(id: $id, isUser: $isUser, text: $text)';
}