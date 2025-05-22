class QAModel {
  final int? id;
  final String question;
  final String answer;
  final List<String> keywords;
  final String? category;
  final int? usageCount;
  final DateTime? lastUsed;
  final DateTime? createdAt;

  QAModel({
    this.id,
    required this.question,
    required this.answer,
    required this.keywords,
    this.category,
    this.usageCount,
    this.lastUsed,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
      'keywords': keywords.join(','),
      'category': category,
      'usage_count': usageCount,
      'last_used': lastUsed?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  factory QAModel.fromMap(Map<String, dynamic> map) {
    return QAModel(
      id: map['id'] as int?,
      question: map['question'] as String,
      answer: map['answer'] as String,
      keywords: (map['keywords'] as String).split(','),
      category: map['category'] as String?,
      usageCount: map['usage_count'] as int?,
      lastUsed: map['last_used'] != null 
          ? DateTime.parse(map['last_used'] as String)
          : null,
      createdAt: map['created_at'] != null 
          ? DateTime.parse(map['created_at'] as String)
          : null,
    );
  }

  QAModel copyWith({
    int? id,
    String? question,
    String? answer,
    List<String>? keywords,
    String? category,
    int? usageCount,
    DateTime? lastUsed,
    DateTime? createdAt,
  }) {
    return QAModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      keywords: keywords ?? this.keywords,
      category: category ?? this.category,
      usageCount: usageCount ?? this.usageCount,
      lastUsed: lastUsed ?? this.lastUsed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
} 