class EcoQAModel {
  final int? id;
  final String question;
  final String answer;

  EcoQAModel({
    this.id,
    required this.question,
    required this.answer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'question': question,
      'answer': answer,
    };
  }

  factory EcoQAModel.fromMap(Map<String, dynamic> map) {
    return EcoQAModel(
      id: map['id'],
      question: map['question'],
      answer: map['answer'],
    );
  }
} 