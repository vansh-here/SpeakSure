import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/di/providers.dart';
import '../../core/services/interview_service.dart';
import '../../data/models/interview_model.dart';
import '../../data/models/question_model.dart';

// Interview state
class InterviewState {
  final bool isLoading;
  final InterviewModel? currentInterview;
  final List<InterviewModel> interviewHistory;
  final QuestionModel? currentQuestion;
  final int currentQuestionIndex;
  final String? error;

  const InterviewState({
    this.isLoading = false,
    this.currentInterview,
    this.interviewHistory = const [],
    this.currentQuestion,
    this.currentQuestionIndex = 0,
    this.error,
  });

  InterviewState copyWith({
    bool? isLoading,
    InterviewModel? currentInterview,
    List<InterviewModel>? interviewHistory,
    QuestionModel? currentQuestion,
    int? currentQuestionIndex,
    String? error,
  }) {
    return InterviewState(
      isLoading: isLoading ?? this.isLoading,
      currentInterview: currentInterview ?? this.currentInterview,
      interviewHistory: interviewHistory ?? this.interviewHistory,
      currentQuestion: currentQuestion ?? this.currentQuestion,
      currentQuestionIndex: currentQuestionIndex ?? this.currentQuestionIndex,
      error: error,
    );
  }
}

// Interview notifier
class InterviewNotifier extends StateNotifier<InterviewState> {
  final InterviewService _interviewService;

  InterviewNotifier(this._interviewService) : super(const InterviewState());

  Future<void> startInterview(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Backend POST /Interview/start doesn't accept any parameters
      final sessionResponse = await _interviewService.startInterview();

      // Store conversation ID for later use
      final conversationId = sessionResponse.conversationId;
      
      // Create a simple interview model for state
      final interview = InterviewModel(
        id: conversationId,
        userId: userId,
        questions: sessionResponse.firstQuestion != null 
            ? [QuestionModel(
                id: 'q1',
                text: sessionResponse.firstQuestion!,
                category: 'Interview',
                difficulty: 'Medium',
              )]
            : [],
        answers: const [],
        startedAt: DateTime.now(),
        status: InterviewStatus.inProgress,
      );

      state = state.copyWith(
        isLoading: false,
        currentInterview: interview,
        currentQuestion: sessionResponse.firstQuestion != null 
            ? QuestionModel(
                id: 'q1',
                text: sessionResponse.firstQuestion!,
                category: 'Interview',
                difficulty: 'Medium',
              )
            : null,
        currentQuestionIndex: 0,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> submitAnswer(File audioFile) async {
    if (state.currentInterview == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Backend expects audio file, not text answer
      final response = await _interviewService.provideAnswer(
        state.currentInterview!.id,
        audioFile,
      );

      if (response.isComplete) {
        // Interview completed
        await completeInterview();
      } else if (response.nextQuestion != null) {
        // Move to next question
        final nextQuestion = QuestionModel(
          id: 'q${state.currentQuestionIndex + 2}',
          text: response.nextQuestion!,
          category: 'Interview',
          difficulty: 'Medium',
        );
        
        state = state.copyWith(
          isLoading: false,
          currentQuestion: nextQuestion,
          currentQuestionIndex: state.currentQuestionIndex + 1,
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> completeInterview() async {
    if (state.currentInterview == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Interview is completed when we get isComplete from provideAnswer
      final completedInterview = state.currentInterview!.copyWith(
        status: InterviewStatus.completed,
        completedAt: DateTime.now(),
      );

      state = state.copyWith(
        isLoading: false,
        currentInterview: completedInterview,
        currentQuestion: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> loadInterviewHistory(String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Get user analytics which includes interview history
      final analytics = await _interviewService.getUserAnalytics();
      // Convert analytics to interview history format
      final history = analytics.recentInterviews?.map((interview) {
        return InterviewModel(
          id: interview['id'] as String? ?? '',
          userId: userId,
          questions: const [],
          answers: const [],
          startedAt: DateTime.parse(interview['started_at'] as String? ?? DateTime.now().toIso8601String()),
          completedAt: interview['completed_at'] != null 
              ? DateTime.parse(interview['completed_at'] as String)
              : null,
          status: InterviewStatus.values.firstWhere(
            (e) => e.name == (interview['status'] as String? ?? 'completed'),
            orElse: () => InterviewStatus.completed,
          ),
        );
      }).toList() ?? [];
      
      state = state.copyWith(
        isLoading: false,
        interviewHistory: history,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> resumeInterview(String conversationId, String userId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      // Get interview status
      final status = await _interviewService.getInterviewStatus(conversationId);
      
      // Extract current question from details if available
      String? currentQuestionText;
      if (status.details != null && status.details!['current_question'] != null) {
        currentQuestionText = status.details!['current_question'] as String;
      }
      
      final interview = InterviewModel(
        id: conversationId,
        userId: userId,
        questions: currentQuestionText != null 
            ? [QuestionModel(
                id: 'q${status.questionsAnswered + 1}',
                text: currentQuestionText,
                category: 'Interview',
                difficulty: 'Medium',
              )]
            : [],
        answers: const [],
        startedAt: DateTime.now(),
        status: status.status == 'completed' ? InterviewStatus.completed : InterviewStatus.inProgress,
      );
      
      state = state.copyWith(
        isLoading: false,
        currentInterview: interview,
        currentQuestion: currentQuestionText != null 
            ? QuestionModel(
                id: 'q${status.questionsAnswered + 1}',
                text: currentQuestionText,
                category: 'Interview',
                difficulty: 'Medium',
              )
            : null,
        currentQuestionIndex: status.questionsAnswered,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> abandonInterview() async {
    if (state.currentInterview == null) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      // Clear current interview state
      state = const InterviewState();
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void resetInterview() {
    state = const InterviewState();
  }
}

// Provider
final interviewProvider = StateNotifierProvider<InterviewNotifier, InterviewState>((ref) {
  final interviewService = ref.watch(interviewServiceProvider).value;
  if (interviewService == null) {
    throw Exception('InterviewService not available');
  }
  return InterviewNotifier(interviewService);
});
