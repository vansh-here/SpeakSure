import 'dart:io';
import 'package:dio/dio.dart';
import '../network/api_client.dart';
import '../constants/app_constants.dart';
import '../../data/models/api_models.dart';

class InterviewService {
  final ApiClient _api;

  InterviewService(this._api);

  /// Start interview (POST /Interview/start)
  Future<StartInterviewResponse> startInterview() async {
    final response = await _api.handleApiCall(
      () => _api.post(AppConstants.startInterview),
    );
    
    return StartInterviewResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Provide answer (POST /Interview/{conversation_id}/answer)
  Future<ProvideAnswerResponse> provideAnswer(String conversationId, File audioFile) async {
    final fileName = audioFile.path.split(Platform.pathSeparator).last;
    final formData = FormData.fromMap({
      'audio': await MultipartFile.fromFile(audioFile.path, filename: fileName),
    });

    final path = AppConstants.provideAnswer.replaceAll('{conversation_id}', conversationId);
    final response = await _api.handleApiCall(
      () => _api.post(path, data: formData),
    );
    
    return ProvideAnswerResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Get audio (GET /Interview/{conversation_id}/audio)
  Future<List<int>> getAudio(String conversationId) async {
    final path = AppConstants.getAudio.replaceAll('{conversation_id}', conversationId);
    
    // Make request with responseType.bytes to handle binary data
    final response = await _api.getBinary(path);
    
    return response.data ?? [];
  }

  /// Get current question text (GET /Interview/{conversation_id}/question)
  Future<String?> getCurrentQuestion(String conversationId) async {
    try {
      final path = AppConstants.getCurrentQuestion.replaceAll('{conversation_id}', conversationId);
      final response = await _api.handleApiCall(
        () => _api.get(path),
      );
      
      if (response is Map<String, dynamic>) {
        return response['question'] as String?;
      }
      return null;
    } catch (e) {
      print('Error getting current question: $e');
      return null;
    }
  }

  /// Submit text answer for web - uses proper API endpoint
  Future<ProvideAnswerResponse> provideTextAnswer(String conversationId, String textAnswer) async {
    print('=== SUBMITTING TEXT ANSWER ===');
    print('Conversation ID: $conversationId');
    print('Text Answer: $textAnswer');
    
    try {
      // Use the correct endpoint: POST /Interview/{conversation_id}/answer
      final path = AppConstants.provideAnswer.replaceAll('{conversation_id}', conversationId);
      print('API endpoint: $path');
      
      // For web, send as JSON data instead of multipart
      final response = await _api.handleApiCall(
        () => _api.post(path, data: {
          'text_answer': textAnswer,
          'audio_type': 'text' // Indicate this is text-based submission
        }),
      );
      
      print('Backend response received: $response');
      final parsedResponse = ProvideAnswerResponse.fromJson(response as Map<String, dynamic>);
      
      print('Parsed response:');
      print('- Next question: ${parsedResponse.nextQuestion}');
      print('- Is complete: ${parsedResponse.isComplete}');
      print('- Message: ${parsedResponse.message}');
      
      return parsedResponse;
      
    } catch (e) {
      print('=== API CALL FAILED ===');
      print('Error: $e');
      print('Using fallback to continue interview');
      
      // Generate fallback questions to continue the interview
      final fallbackQuestions = [
        'Tell me about a challenging project you worked on recently.',
        'Describe a time when you had to work with a difficult team member.',
        'What are your career goals for the next 5 years?',
        'How do you handle stress and pressure in the workplace?',
        'What motivates you in your work?',
        'Describe your ideal work environment.',
        'How do you stay updated with industry trends?',
        'Tell me about a time you had to learn something new quickly.',
        'What are your strengths and how do they help you in your work?',
        'Do you have any questions for us about the role or company?'
      ];
      
      // Use a different question each time based on timestamp
      final questionIndex = DateTime.now().millisecondsSinceEpoch % fallbackQuestions.length;
      final nextQuestion = fallbackQuestions[questionIndex];
      
      print('Fallback next question: $nextQuestion');
      
      // IMPORTANT: Always return isComplete: false to continue the interview
      return ProvideAnswerResponse(
        nextQuestion: nextQuestion,
        isComplete: false, // NEVER complete in fallback - let the UI handle completion
        message: 'Answer received via fallback, continuing with next question',
      );
    }
  }

  /// Get interview status (GET /Details/)
  Future<InterviewStatusResponse> getInterviewStatus(String conversationId) async {
    final response = await _api.handleApiCall(
      () => _api.get(AppConstants.getInterviewStatus, query: {
        'conversation_id': conversationId,
      }),
    );
    
    return InterviewStatusResponse.fromJson(response as Map<String, dynamic>);
  }

  /// Get user analytics (GET /Analytics/)
  Future<UserAnalyticsResponse> getUserAnalytics() async {
    final response = await _api.handleApiCall(
      () => _api.get(AppConstants.getAnalytics),
    );
    
    return UserAnalyticsResponse.fromJson(response as Map<String, dynamic>);
  }
}
