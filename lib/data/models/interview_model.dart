import 'question_model.dart';

class InterviewModel {
  final String id;
  final String userId;
  final List<QuestionModel> questions;
  final List<AnswerModel> answers;
  final DateTime startedAt;
  final DateTime? completedAt;
  final InterviewStatus status;
  final int currentQuestionIndex;

  InterviewModel({
    required this.id,
    required this.userId,
    required this.questions,
    required this.answers,
    required this.startedAt,
    this.completedAt,
    this.status = InterviewStatus.inProgress,
    this.currentQuestionIndex = 0,
  });

  factory InterviewModel.fromJson(Map<String, dynamic> json) {
    return InterviewModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      questions: (json['questions'] as List)
          .map((q) => QuestionModel.fromJson(q as Map<String, dynamic>))
          .toList(),
      answers: (json['answers'] as List)
          .map((a) => AnswerModel.fromJson(a as Map<String, dynamic>))
          .toList(),
      startedAt: DateTime.parse(json['started_at'] as String),
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      status: InterviewStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => InterviewStatus.inProgress,
      ),
      currentQuestionIndex: json['current_question_index'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'questions': questions.map((q) => q.toJson()).toList(),
      'answers': answers.map((a) => a.toJson()).toList(),
      'started_at': startedAt.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'status': status.name,
      'current_question_index': currentQuestionIndex,
    };
  }

  InterviewModel copyWith({
    String? id,
    String? userId,
    List<QuestionModel>? questions,
    List<AnswerModel>? answers,
    DateTime? startedAt,
    DateTime? completedAt,
    InterviewStatus? status,
    int? currentQuestionIndex,
  }) {
    return InterviewModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      questions: questions ?? this.questions,
      answers: answers ?? this.answers,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      status: status ?? this.status,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
    );
  }
}

class AnswerModel {
  final String questionId;
  final String answer;
  final DateTime answeredAt;
  final int timeSpent; // in seconds
  final double? confidence; // 0.0 to 1.0

  AnswerModel({
    required this.questionId,
    required this.answer,
    required this.answeredAt,
    required this.timeSpent,
    this.confidence,
  });

  factory AnswerModel.fromJson(Map<String, dynamic> json) {
    return AnswerModel(
      questionId: json['question_id'] as String,
      answer: json['answer'] as String,
      answeredAt: DateTime.parse(json['answered_at'] as String),
      timeSpent: json['time_spent'] as int,
      confidence: json['confidence'] as double?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'question_id': questionId,
      'answer': answer,
      'answered_at': answeredAt.toIso8601String(),
      'time_spent': timeSpent,
      'confidence': confidence,
    };
  }
}

enum InterviewStatus {
  inProgress,
  completed,
  abandoned,
}


