import 'package:flutter/material.dart';

enum MessageSender {
  user,
  bot
}

class ChatMessage {
  final String id;
  final String text;
  final MessageSender sender;
  final DateTime timestamp;
  final List<String>? actionSuggestions;
  final Map<String, dynamic>? additionalData;

  ChatMessage({
    required this.id,
    required this.text,
    required this.sender,
    DateTime? timestamp,
    this.actionSuggestions,
    this.additionalData,
  }) : timestamp = timestamp ?? DateTime.now();

  ChatMessage copyWith({
    String? id,
    String? text,
    MessageSender? sender,
    DateTime? timestamp,
    List<String>? actionSuggestions,
    Map<String, dynamic>? additionalData,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      sender: sender ?? this.sender,
      timestamp: timestamp ?? this.timestamp,
      actionSuggestions: actionSuggestions ?? this.actionSuggestions,
      additionalData: additionalData ?? this.additionalData,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'sender': sender.index,
      'timestamp': timestamp.millisecondsSinceEpoch,
      'actionSuggestions': actionSuggestions,
      'additionalData': additionalData,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      text: map['text'] ?? '',
      sender: MessageSender.values[map['sender'] ?? 0],
      timestamp: DateTime.fromMillisecondsSinceEpoch(map['timestamp'] ?? DateTime.now().millisecondsSinceEpoch),
      actionSuggestions: map['actionSuggestions'] != null ? List<String>.from(map['actionSuggestions']) : null,
      additionalData: map['additionalData'],
    );
  }
}

class EcobotSession {
  final String id;
  final String topic;
  final List<ChatMessage> messages;
  final DateTime createdAt;
  final DateTime lastUpdatedAt;

  EcobotSession({
    required this.id,
    required this.topic,
    required this.messages,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) : 
    createdAt = createdAt ?? DateTime.now(),
    lastUpdatedAt = lastUpdatedAt ?? DateTime.now();

  // Ajouter un message à la session
  EcobotSession addMessage(ChatMessage message) {
    final updatedMessages = List<ChatMessage>.from(messages)..add(message);
    return copyWith(
      messages: updatedMessages,
      lastUpdatedAt: DateTime.now(),
    );
  }

  // Méthode pour déterminer le sujet de conversation en fonction des messages
  String determineTopic() {
    if (messages.isEmpty) return 'Nouvelle conversation';
    
    // Extraire le premier message utilisateur
    final firstUserMessage = messages.firstWhere(
      (m) => m.sender == MessageSender.user,
      orElse: () => messages.first,
    );
    
    // Prendre les premiers mots (max 5) comme sujet
    final words = firstUserMessage.text.split(' ');
    String topic = words.take(5).join(' ');
    
    // Ajouter "..." si le texte est plus long
    if (words.length > 5) topic += '...';
    
    return topic;
  }

  EcobotSession copyWith({
    String? id,
    String? topic,
    List<ChatMessage>? messages,
    DateTime? createdAt,
    DateTime? lastUpdatedAt,
  }) {
    return EcobotSession(
      id: id ?? this.id,
      topic: topic ?? this.topic,
      messages: messages ?? this.messages,
      createdAt: createdAt ?? this.createdAt,
      lastUpdatedAt: lastUpdatedAt ?? this.lastUpdatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'topic': topic,
      'messages': messages.map((m) => m.toMap()).toList(),
      'createdAt': createdAt.millisecondsSinceEpoch,
      'lastUpdatedAt': lastUpdatedAt.millisecondsSinceEpoch,
    };
  }

  factory EcobotSession.fromMap(Map<String, dynamic> map) {
    return EcobotSession(
      id: map['id'] ?? '',
      topic: map['topic'] ?? '',
      messages: List<ChatMessage>.from(
        (map['messages'] ?? []).map((m) => ChatMessage.fromMap(m)),
      ),
      createdAt: DateTime.fromMillisecondsSinceEpoch(map['createdAt'] ?? DateTime.now().millisecondsSinceEpoch),
      lastUpdatedAt: DateTime.fromMillisecondsSinceEpoch(map['lastUpdatedAt'] ?? DateTime.now().millisecondsSinceEpoch),
    );
  }

  // Créer une nouvelle session avec un message de bienvenue
  factory EcobotSession.newSession() {
    final welcomeMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: 'Bonjour ! Je suis EcoBot, votre assistant écologique. Comment puis-je vous aider aujourd\'hui ? Je peux vous conseiller sur la réduction de votre empreinte carbone, le recyclage, la consommation responsable, et bien plus encore.',
      sender: MessageSender.bot,
      actionSuggestions: [
        'Comment réduire ma consommation d\'eau ?',
        'Puis-je recycler ce type de plastique ?',
        'Comment diminuer mon empreinte numérique ?',
        'Conseils pour réduire ma pollution sonore ?',
      ],
    );

    return EcobotSession(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      topic: 'Nouvelle conversation',
      messages: [welcomeMessage],
    );
  }
}

// Modèle pour les suggestions rapides d'EcoBot
class QuickSuggestion {
  final String id;
  final String text;
  final IconData icon;
  final String category;

  const QuickSuggestion({
    required this.id,
    required this.text,
    required this.icon,
    required this.category,
  });

  // Liste de suggestions prédéfinies
  static List<QuickSuggestion> getDefaultSuggestions() {
    return [
      // Suggestions de réduction d'empreinte carbone
      QuickSuggestion(
        id: 'carbon_food',
        text: 'Comment réduire l\'impact carbone de mon alimentation ?',
        icon: Icons.restaurant,
        category: 'carbon',
      ),
      QuickSuggestion(
        id: 'carbon_transport',
        text: 'Quels sont les moyens de transport les plus écologiques ?',
        icon: Icons.directions_car,
        category: 'carbon',
      ),
      
      // Suggestions sur le recyclage
      QuickSuggestion(
        id: 'recycling_plastics',
        text: 'Comment recycler correctement les différents types de plastique ?',
        icon: Icons.recycling,
        category: 'recycling',
      ),
      QuickSuggestion(
        id: 'recycling_electronics',
        text: 'Où puis-je recycler mes appareils électroniques ?',
        icon: Icons.devices,
        category: 'recycling',
      ),
      
      // Suggestions sur la pollution numérique
      QuickSuggestion(
        id: 'digital_footprint',
        text: 'Comment réduire mon empreinte numérique ?',
        icon: Icons.cloud_outlined,
        category: 'digital',
      ),
      QuickSuggestion(
        id: 'digital_devices',
        text: 'Combien de temps dois-je garder mes appareils électroniques ?',
        icon: Icons.smartphone,
        category: 'digital',
      ),
      
      // Suggestions sur la pollution sonore
      QuickSuggestion(
        id: 'noise_health',
        text: 'Quels sont les effets du bruit sur ma santé ?',
        icon: Icons.hearing,
        category: 'noise',
      ),
      QuickSuggestion(
        id: 'noise_reduction',
        text: 'Comment réduire la pollution sonore chez moi ?',
        icon: Icons.volume_up,
        category: 'noise',
      ),
      
      // Suggestions générales
      QuickSuggestion(
        id: 'general_tips',
        text: 'Donnez-moi 5 gestes écologiques simples à adopter au quotidien',
        icon: Icons.eco,
        category: 'general',
      ),
      QuickSuggestion(
        id: 'scan_product',
        text: 'Comment scanner un produit pour connaître son impact ?',
        icon: Icons.qr_code_scanner,
        category: 'general',
      ),
    ];
  }

  // Obtenir des suggestions filtrées par catégorie
  static List<QuickSuggestion> getSuggestionsByCategory(String category) {
    return getDefaultSuggestions()
        .where((suggestion) => suggestion.category == category)
        .toList();
  }
} 