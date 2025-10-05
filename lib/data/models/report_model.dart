
class ReportModel {
  final String id;
  final String interviewId;
  final String userId;
  final double overallScore;
  final List<CategoryScore> categoryScores;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final DateTime generatedAt;
  final ReportStatus status;

  ReportModel({
    required this.id,
    required this.interviewId,
    required this.userId,
    required this.overallScore,
    required this.categoryScores,
    required this.strengths,
    required this.weaknesses,
    required this.recommendations,
    required this.generatedAt,
    this.status = ReportStatus.generated,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['id'] as String,
      interviewId: json['interview_id'] as String,
      userId: json['user_id'] as String,
      overallScore: json['overall_score'] as double,
      categoryScores: (json['category_scores'] as List)
          .map((c) => CategoryScore.fromJson(c as Map<String, dynamic>))
          .toList(),
      strengths: List<String>.from(json['strengths'] as List),
      weaknesses: List<String>.from(json['weaknesses'] as List),
      recommendations: List<String>.from(json['recommendations'] as List),
      generatedAt: DateTime.parse(json['generated_at'] as String),
      status: ReportStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => ReportStatus.generated,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'interview_id': interviewId,
      'user_id': userId,
      'overall_score': overallScore,
      'category_scores': categoryScores.map((c) => c.toJson()).toList(),
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recommendations': recommendations,
      'generated_at': generatedAt.toIso8601String(),
      'status': status.name,
    };
  }
}

class CategoryScore {
  final String category;
  final double score;
  final String description;

  CategoryScore({
    required this.category,
    required this.score,
    required this.description,
  });

  factory CategoryScore.fromJson(Map<String, dynamic> json) {
    return CategoryScore(
      category: json['category'] as String,
      score: json['score'] as double,
      description: json['description'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'score': score,
      'description': description,
    };
  }
}

enum ReportStatus {
  generating,
  generated,
  failed,
}
