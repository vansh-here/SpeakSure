// Question Model for Interview Questions

class QuestionModel {
  final String id;
  final String text;
  final String category;
  final String difficulty;

  QuestionModel({
    required this.id,
    required this.text,
    required this.category,
    required this.difficulty,
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String? ?? '',
      text: json['text'] as String? ?? '',
      category: json['category'] as String? ?? '',
      difficulty: json['difficulty'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'difficulty': difficulty,
    };
  }
}
