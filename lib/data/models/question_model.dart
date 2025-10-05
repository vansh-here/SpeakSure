class QuestionModel {
  final String id;
  final String text;
  final String category;
  final String difficulty;
  final List<String>? followUpQuestions;
  final String? expectedAnswer;
  final int timeLimit; // in seconds

  QuestionModel({
    required this.id,
    required this.text,
    required this.category,
    required this.difficulty,
    this.followUpQuestions,
    this.expectedAnswer,
    this.timeLimit = 180, // 3 minutes default
  });

  factory QuestionModel.fromJson(Map<String, dynamic> json) {
    return QuestionModel(
      id: json['id'] as String,
      text: json['text'] as String,
      category: json['category'] as String,
      difficulty: json['difficulty'] as String,
      followUpQuestions: json['follow_up_questions'] != null
          ? List<String>.from(json['follow_up_questions'] as List)
          : null,
      expectedAnswer: json['expected_answer'] as String?,
      timeLimit: json['time_limit'] as int? ?? 180,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'category': category,
      'difficulty': difficulty,
      'follow_up_questions': followUpQuestions,
      'expected_answer': expectedAnswer,
      'time_limit': timeLimit,
    };
  }
}


