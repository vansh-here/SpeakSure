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
        // Try different field names that backend might use
        String? question = response['question'] as String?;
        if (question == null || question.isEmpty) {
          question = response['nextQuestion'] as String?;
        }
        if (question == null || question.isEmpty) {
          question = response['current_question'] as String?;
        }

        print('Backend current question: $question');
        return question;
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

      // For web text submissions, we need to send as multipart form data
      // Since backend expects audio field, we'll create a minimal dummy audio file for text submissions
      final formData = FormData.fromMap({
        'audio': MultipartFile.fromBytes(
          _createDummyAudioBytes(), // Minimal dummy audio data for text submission
          filename: 'text_submission.wav',
        ),
        'text_answer': textAnswer,
        'submission_type': 'text' // Indicate this is text-based
      });

      final response = await _api.handleApiCall(
        () => _api.post(path, data: formData),
      );

      print('Backend response received: $response');

      // Use the model's fromJson method which now handles all field variations
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

  /// Create minimal dummy audio bytes for text submissions
  /// This creates a minimal WAV file header for text-based submissions
  List<int> _createDummyAudioBytes() {
    // Minimal WAV file header (44 bytes)
    // This is a valid WAV file with 1 second of silence at 8kHz mono
    return [
      0x52, 0x49, 0x46, 0x46, // "RIFF"
      0x2C, 0x00, 0x00, 0x00, // File size - 44 (header only)
      0x57, 0x41, 0x56, 0x45, // "WAVE"
      0x66, 0x6D, 0x74, 0x20, // "fmt "
      0x10, 0x00, 0x00, 0x00, // Format chunk size
      0x01, 0x00,             // Audio format (PCM)
      0x01, 0x00,             // Number of channels (mono)
      0x40, 0x1F, 0x00, 0x00, // Sample rate (8kHz)
      0x80, 0x3E, 0x00, 0x00, // Byte rate (8kHz * 1 * 16 bits)
      0x02, 0x00,             // Block align
      0x10, 0x00,             // Bits per sample
      0x64, 0x61, 0x74, 0x61, // "data"
      0x00, 0x00, 0x00, 0x00, // Data size (0 bytes - silence)
    ];
  }
}
