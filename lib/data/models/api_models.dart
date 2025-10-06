// API Request and Response Models for FastAPI Backend

/// Response from POST /user
class CreateUserResponse {
  final String userId;
  final String name;
  final String message;

  CreateUserResponse({
    required this.userId,
    required this.name,
    required this.message,
  });

  factory CreateUserResponse.fromJson(Map<String, dynamic> json) {
    return CreateUserResponse(
      userId: json['user_id'] as String? ?? json['userId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'name': name,
      'message': message,
    };
  }
}

/// Response from POST /upload_resume
class UploadResumeResponse {
  final String message;
  final String? filePath;
  final String? fileName;

  UploadResumeResponse({
    required this.message,
    this.filePath,
    this.fileName,
  });

  factory UploadResumeResponse.fromJson(Map<String, dynamic> json) {
    return UploadResumeResponse(
      message: json['message'] as String? ?? '',
      filePath: json['file_path'] as String? ?? json['filePath'] as String?,
      fileName: json['file_name'] as String? ?? json['fileName'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'file_path': filePath,
      'file_name': fileName,
    };
  }
}

/// Response from POST /Interview/start
class StartInterviewResponse {
  final String conversationId;
  final String? firstQuestion;
  final String message;

  StartInterviewResponse({
    required this.conversationId,
    this.firstQuestion,
    required this.message,
  });

  factory StartInterviewResponse.fromJson(Map<String, dynamic> json) {
    return StartInterviewResponse(
      conversationId: json['conversation_id'] as String? ?? json['conversationId'] as String? ?? '',
      firstQuestion: json['question'] as String? ?? json['first_question'] as String? ?? json['firstQuestion'] as String?,
      message: json['message'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'first_question': firstQuestion,
      'message': message,
    };
  }
}

/// Response from POST /Interview/{conversation_id}/answer
class ProvideAnswerResponse {
  final String? nextQuestion;
  final bool isComplete;
  final String message;
  final Map<String, dynamic>? feedback;

  ProvideAnswerResponse({
    this.nextQuestion,
    required this.isComplete,
    required this.message,
    this.feedback,
  });

  // Getter to access the question (whether it's in nextQuestion or question field)
  String? get question {
    return nextQuestion;
  }

  factory ProvideAnswerResponse.fromJson(Map<String, dynamic> json) {
    // Handle different field names that backend might use
    String? nextQuestion = json['next_question'] as String?;
    if (nextQuestion == null || nextQuestion.isEmpty) {
      nextQuestion = json['nextQuestion'] as String?;
    }
    if (nextQuestion == null || nextQuestion.isEmpty) {
      nextQuestion = json['question'] as String?; // Backend returns 'question' field
    }

    // Handle interview completion case
    bool isComplete = json['is_complete'] as bool? ?? json['isComplete'] as bool? ?? false;
    if (nextQuestion == "The interview is over." || json['status'] == "finished") {
      isComplete = true;
    }

    return ProvideAnswerResponse(
      nextQuestion: nextQuestion,
      isComplete: isComplete,
      message: json['message'] as String? ?? json['status'] as String? ?? '',
      feedback: json['feedback'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'next_question': nextQuestion,
      'is_complete': isComplete,
      'message': message,
      'feedback': feedback,
    };
  }
}

/// Response from GET /Analytics/
class UserAnalyticsResponse {
  final List<Map<String, dynamic>>? analytics;
  final List<String>? positivePoints;
  final List<String>? negativePoints;
  final List<String>? improvementSuggestions;
  final String? structuredThinkingAnalysis;
  final String? communicationAssessment;
  final String? productSenseAssessment;
  final List<String>? behavioralCompetencies;
  final String? confidenceAndComposureAnalysis;
  final String? storytellingEffectiveness;
  final String? engagementAndEnthusiasm;
  final List<String>? psychologicalImprovementTips;
  final int? rating;
  final String? summary;

  UserAnalyticsResponse({
    this.analytics,
    this.positivePoints,
    this.negativePoints,
    this.improvementSuggestions,
    this.structuredThinkingAnalysis,
    this.communicationAssessment,
    this.productSenseAssessment,
    this.behavioralCompetencies,
    this.confidenceAndComposureAnalysis,
    this.storytellingEffectiveness,
    this.engagementAndEnthusiasm,
    this.psychologicalImprovementTips,
    this.rating,
    this.summary,
  });

  factory UserAnalyticsResponse.fromJson(Map<String, dynamic> json) {
    return UserAnalyticsResponse(
      analytics: (json['analytics'] as List?)?.cast<Map<String, dynamic>>(),
      positivePoints: (json['positive_points'] as List?)?.cast<String>(),
      negativePoints: (json['negative_points'] as List?)?.cast<String>(),
      improvementSuggestions: (json['improvement_suggestions'] as List?)?.cast<String>(),
      structuredThinkingAnalysis: json['structured_thinking_analysis'] as String?,
      communicationAssessment: json['communication_assessment'] as String?,
      productSenseAssessment: json['product_sense_assessment'] as String?,
      behavioralCompetencies: (json['behavioral_competencies'] as List?)?.cast<String>(),
      confidenceAndComposureAnalysis: json['confidence_and_composure_analysis'] as String?,
      storytellingEffectiveness: json['storytelling_effectiveness'] as String?,
      engagementAndEnthusiasm: json['engagement_and_enthusiasm'] as String?,
      psychologicalImprovementTips: (json['psychological_improvement_tips'] as List?)?.cast<String>(),
      rating: json['rating'] as int?,
      summary: json['summary'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'analytics': analytics,
      'positive_points': positivePoints,
      'negative_points': negativePoints,
      'improvement_suggestions': improvementSuggestions,
      'structured_thinking_analysis': structuredThinkingAnalysis,
      'communication_assessment': communicationAssessment,
      'product_sense_assessment': productSenseAssessment,
      'behavioral_competencies': behavioralCompetencies,
      'confidence_and_composure_analysis': confidenceAndComposureAnalysis,
      'storytelling_effectiveness': storytellingEffectiveness,
      'engagement_and_enthusiasm': engagementAndEnthusiasm,
      'psychological_improvement_tips': psychologicalImprovementTips,
      'rating': rating,
      'summary': summary,
    };
  }
}

/// Response from GET /Details/
class InterviewStatusResponse {
  final String conversationId;
  final String status;
  final int questionsAnswered;
  final int totalQuestions;
  final Map<String, dynamic>? details;

  InterviewStatusResponse({
    required this.conversationId,
    required this.status,
    required this.questionsAnswered,
    required this.totalQuestions,
    this.details,
  });

  factory InterviewStatusResponse.fromJson(Map<String, dynamic> json) {
    return InterviewStatusResponse(
      conversationId: json['conversation_id'] as String? ?? json['conversationId'] as String? ?? '',
      status: json['status'] as String? ?? '',
      questionsAnswered: json['questions_answered'] as int? ?? json['questionsAnswered'] as int? ?? 0,
      totalQuestions: json['total_questions'] as int? ?? json['totalQuestions'] as int? ?? 0,
      details: json['details'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'conversation_id': conversationId,
      'status': status,
      'questions_answered': questionsAnswered,
      'total_questions': totalQuestions,
      'details': details,
    };
  }
}

/// Response from GET /RoundWiseReport/{round_number}
class RoundWiseReportResponse {
  final int roundNumber;
  final double score;
  final String feedback;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> recommendations;
  final List<Map<String, dynamic>>? questions;
  final Map<String, dynamic>? metrics;

  RoundWiseReportResponse({
    required this.roundNumber,
    required this.score,
    required this.feedback,
    this.strengths = const [],
    this.weaknesses = const [],
    this.recommendations = const [],
    this.questions,
    this.metrics,
  });

  factory RoundWiseReportResponse.fromJson(Map<String, dynamic> json) {
    return RoundWiseReportResponse(
      roundNumber: json['round_number'] as int? ?? json['roundNumber'] as int? ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      feedback: json['feedback'] as String? ?? '',
      strengths: (json['strengths'] as List?)?.cast<String>() ?? [],
      weaknesses: (json['weaknesses'] as List?)?.cast<String>() ?? [],
      recommendations: (json['recommendations'] as List?)?.cast<String>() ?? [],
      questions: (json['questions'] as List?)?.cast<Map<String, dynamic>>(),
      metrics: json['metrics'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'round_number': roundNumber,
      'score': score,
      'feedback': feedback,
      'strengths': strengths,
      'weaknesses': weaknesses,
      'recommendations': recommendations,
      'questions': questions,
      'metrics': metrics,
    };
  }
}
