import 'dart:async';
import 'dart:io';
import '../../core/network/api_client.dart';
import '../../core/constants/app_constants.dart';
import '../models/interview_model.dart';
import '../models/question_model.dart';
import '../models/api_models.dart';
import '../../domain/repositories/interview_repository.dart';
import 'package:dio/dio.dart';

class InterviewRepositoryImpl implements InterviewRepository {
  final ApiClient apiClient;

  InterviewRepositoryImpl({required this.apiClient});

  @override
  Future<List<QuestionModel>> fetchQuestions({required String userId}) async {
    // This endpoint doesn't exist in FastAPI backend
    // Return empty list or throw unsupported error
    throw UnimplementedError('fetchQuestions is not supported by the backend');
  }

  @override
  Future<InterviewModel> startInterview({required String userId, required List<QuestionModel> questions}) async {
    // Use the actual FastAPI endpoint: POST /Interview/start
    final response = await apiClient.handleApiCall(
      () => apiClient.post(AppConstants.startInterview),
    );
    
    final startResponse = StartInterviewResponse.fromJson(response as Map<String, dynamic>);
    
    // Create InterviewModel from response
    return InterviewModel(
      id: startResponse.conversationId,
      userId: userId,
      questions: startResponse.firstQuestion != null
          ? [
              QuestionModel(
                id: '1',
                text: startResponse.firstQuestion!,
                category: 'Interview',
                difficulty: 'Medium',
              )
            ]
          : [],
      answers: const [],
      startedAt: DateTime.now(),
      status: InterviewStatus.inProgress,
    );
  }

  @override
  Future<InterviewModel> submitAnswer({required String interviewId, required AnswerModel answer}) async {
    // This uses a different pattern - the backend expects audio file
    // This method signature doesn't match the backend, so we throw unsupported
    throw UnimplementedError('submitAnswer with AnswerModel is not supported. Use provideAnswer with audio file instead.');
  }

  @override
  Future<InterviewModel> completeInterview({required String interviewId}) async {
    // This endpoint doesn't exist in FastAPI backend
    throw UnimplementedError('completeInterview is not supported by the backend');
  }

  // FastAPI-compatible methods
  Future<StartInterviewResponse> startInterviewSession() async {
    final response = await apiClient.handleApiCall(
      () => apiClient.post(AppConstants.startInterview),
    );
    return StartInterviewResponse.fromJson(response as Map<String, dynamic>);
  }

  Future<ProvideAnswerResponse> provideAnswer(String conversationId, File audioFile) async {
    final fileName = audioFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(audioFile.path, filename: fileName),
    });

    final path = AppConstants.provideAnswer.replaceAll('{conversation_id}', conversationId);
    final response = await apiClient.handleApiCall(
      () => apiClient.post(path, data: formData),
    );
    
    return ProvideAnswerResponse.fromJson(response as Map<String, dynamic>);
  }

  Future<InterviewStatusResponse> getInterviewStatus(String conversationId) async {
    final response = await apiClient.handleApiCall(
      () => apiClient.get(AppConstants.getInterviewStatus, query: {
        'conversation_id': conversationId,
      }),
    );
    return InterviewStatusResponse.fromJson(response as Map<String, dynamic>);
  }
}





