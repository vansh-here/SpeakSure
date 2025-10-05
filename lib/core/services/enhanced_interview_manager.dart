// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/foundation.dart';
// import 'enhanced_voice_service.dart';
// import 'interview_api_service.dart';
//
// enum InterviewState {
//   notStarted,
//   starting,
//   inProgress,
//   waitingForAnswer,
//   processingAnswer,
//   completed,
//   error,
// }
//
// class InterviewSession {
//   final String conversationId;
//   final String currentQuestion;
//   final int questionNumber;
//   final List<String> questions;
//   final List<String> answers;
//   final DateTime startedAt;
//   final InterviewState state;
//
//   InterviewSession({
//     required this.conversationId,
//     required this.currentQuestion,
//     required this.questionNumber,
//     required this.questions,
//     required this.answers,
//     required this.startedAt,
//     this.state = InterviewState.notStarted,
//   });
//
//   InterviewSession copyWith({
//     String? conversationId,
//     String? currentQuestion,
//     int? questionNumber,
//     List<String>? questions,
//     List<String>? answers,
//     DateTime? startedAt,
//     InterviewState? state,
//   }) {
//     return InterviewSession(
//       conversationId: conversationId ?? this.conversationId,
//       currentQuestion: currentQuestion ?? this.currentQuestion,
//       questionNumber: questionNumber ?? this.questionNumber,
//       questions: questions ?? this.questions,
//       answers: answers ?? this.answers,
//       startedAt: startedAt ?? this.startedAt,
//       state: state ?? this.state,
//     );
//   }
// }
//
// class EnhancedInterviewManager {
//   final EnhancedVoiceService _voiceService = EnhancedVoiceService();
//   final InterviewApiService _apiService = InterviewApiService();
//
//   final ValueNotifier<InterviewState> interviewState = ValueNotifier(InterviewState.notStarted);
//   final ValueNotifier<InterviewSession?> currentSession = ValueNotifier(null);
//   final ValueNotifier<String> currentQuestion = ValueNotifier('');
//   final ValueNotifier<String> currentAnswer = ValueNotifier('');
//   final ValueNotifier<List<String>> allAnswers = ValueNotifier([]);
//   final ValueNotifier<bool> isProcessing = ValueNotifier(false);
//   final ValueNotifier<String> errorMessage = ValueNotifier('');
//
//   Timer? _answerTimer;
//   Timer? _silenceTimer;
//   DateTime _lastVoiceActivity = DateTime.now();
//   String _userName = '';
//
//   /// Initialize the interview manager
//   Future<void> initialize() async {
//     try {
//       await _voiceService.init();
//       _setupVoiceListeners();
//       interviewState.value = InterviewState.notStarted;
//     } catch (e) {
//       _handleError('Failed to initialize interview manager: $e');
//     }
//   }
//
//   void _setupVoiceListeners() {
//     _voiceService.voiceState.addListener(_onVoiceStateChanged);
//     _voiceService.transcript.addListener(_onTranscriptChanged);
//     _voiceService.isVoiceActive.addListener(_onVoiceActivityChanged);
//   }
//
//   void _onVoiceStateChanged() {
//     if (interviewState.value == InterviewState.inProgress) {
//       switch (_voiceService.voiceState.value) {
//         case VoiceState.speaking:
//           // Avatar should show speaking state
//           break;
//         case VoiceState.listening:
//           interviewState.value = InterviewState.waitingForAnswer;
//           _startAnswerTimer();
//           break;
//         case VoiceState.processing:
//           interviewState.value = InterviewState.processingAnswer;
//           break;
//         default:
//           break;
//       }
//     }
//   }
//
//   void _onTranscriptChanged() {
//     currentAnswer.value = _voiceService.transcript.value;
//   }
//
//   void _onVoiceActivityChanged() {
//     if (_voiceService.isVoiceActive.value) {
//       _lastVoiceActivity = DateTime.now();
//       _resetSilenceTimer();
//     }
//   }
//
//   void _startAnswerTimer() {
//     _answerTimer?.cancel();
//     _answerTimer = Timer(const Duration(seconds: 4), () {
//       if (interviewState.value == InterviewState.waitingForAnswer) {
//         // Give user more time to start answering
//         _startSilenceDetection();
//       }
//     });
//   }
//
//   void _startSilenceDetection() {
//     _silenceTimer?.cancel();
//     _silenceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       final timeSinceLastActivity = DateTime.now().difference(_lastVoiceActivity);
//
//       if (timeSinceLastActivity > const Duration(seconds: 3)) {
//         // User has been silent for 3 seconds, process the answer
//         _processCurrentAnswer();
//       }
//     });
//   }
//
//   void _resetSilenceTimer() {
//     _silenceTimer?.cancel();
//     _startSilenceDetection();
//   }
//
//   /// Start a new interview session
//   Future<void> startInterview({String? userName}) async {
//     try {
//       interviewState.value = InterviewState.starting;
//       isProcessing.value = true;
//       errorMessage.value = '';
//
//       // Create user if name provided
//       if (userName != null && userName.isNotEmpty) {
//         _userName = userName;
//         await _apiService.createUser(userName);
//       }
//
//       // Start interview session
//       final response = await _apiService.startInterview();
//
//       if (response.containsKey('conversation_id') && response.containsKey('question')) {
//         final session = InterviewSession(
//           conversationId: response['conversation_id'],
//           currentQuestion: response['question'],
//           questionNumber: 1,
//           questions: [response['question']],
//           answers: [],
//           startedAt: DateTime.now(),
//           state: InterviewState.inProgress,
//         );
//
//         currentSession.value = session;
//         currentQuestion.value = response['question'];
//         interviewState.value = InterviewState.inProgress;
//
//         // Start speaking the question
//         await _voiceService.speakQuestion(response['question']);
//       } else {
//         throw Exception('Invalid response from start interview API');
//       }
//     } catch (e) {
//       _handleError('Failed to start interview: $e');
//     } finally {
//       isProcessing.value = false;
//     }
//   }
//
//   /// Process the current answer and get next question
//   Future<void> _processCurrentAnswer() async {
//     if (currentSession.value == null || currentAnswer.value.trim().isEmpty) {
//       return;
//     }
//
//     try {
//       interviewState.value = InterviewState.processingAnswer;
//       isProcessing.value = true;
//
//       // Create audio file from current transcript (you might want to record actual audio)
//       final audioFile = await _createAudioFromTranscript(currentAnswer.value);
//
//       // Submit answer to API
//       final response = await _apiService.submitAnswer(
//         currentSession.value!.conversationId,
//         audioFile,
//       );
//
//       if (response.containsKey('question')) {
//         // Update session with new question
//         final updatedSession = currentSession.value!.copyWith(
//           currentQuestion: response['question'],
//           questionNumber: currentSession.value!.questionNumber + 1,
//           questions: [...currentSession.value!.questions, response['question']],
//           answers: [...currentSession.value!.answers, currentAnswer.value],
//           state: InterviewState.inProgress,
//         );
//
//         currentSession.value = updatedSession;
//         currentQuestion.value = response['question'];
//
//         // Add current answer to the list
//         final updatedAnswers = [...allAnswers.value, currentAnswer.value];
//         allAnswers.value = updatedAnswers;
//         currentAnswer.value = '';
//
//         // Speak the next question
//         await _voiceService.speakQuestion(response['question']);
//       } else {
//         // Interview completed
//         _completeInterview();
//       }
//     } catch (e) {
//       _handleError('Failed to process answer: $e');
//     } finally {
//       isProcessing.value = false;
//     }
//   }
//
//   /// Manually process current answer (when user clicks next)
//   Future<void> processCurrentAnswer() async {
//     await _processCurrentAnswer();
//   }
//
//   /// Complete the interview
//   void _completeInterview() {
//     // Add final answer to the list
//     if (currentAnswer.value.isNotEmpty) {
//       final updatedAnswers = [...allAnswers.value, currentAnswer.value];
//       allAnswers.value = updatedAnswers;
//     }
//
//     interviewState.value = InterviewState.completed;
//     _voiceService.cancelAll();
//     _answerTimer?.cancel();
//     _silenceTimer?.cancel();
//   }
//
//   /// Get interview analytics
//   Future<Map<String, dynamic>?> getAnalytics() async {
//     try {
//       return await _apiService.getAnalytics();
//     } catch (e) {
//       _handleError('Failed to get analytics: $e');
//       return null;
//     }
//   }
//
//   /// Get interview details
//   Future<Map<String, dynamic>?> getInterviewDetails() async {
//     if (currentSession.value == null) return null;
//
//     try {
//       return await _apiService.getInterviewDetails(currentSession.value!.conversationId);
//     } catch (e) {
//       _handleError('Failed to get interview details: $e');
//       return null;
//     }
//   }
//
//   /// Get round-wise report
//   Future<Map<String, dynamic>?> getRoundWiseReport(int roundNumber) async {
//     try {
//       return await _apiService.getRoundWiseReport(roundNumber);
//     } catch (e) {
//       _handleError('Failed to get round report: $e');
//       return null;
//     }
//   }
//
//   /// Create audio file from transcript (placeholder implementation)
//   Future<File> _createAudioFromTranscript(String transcript) async {
//     // This is a placeholder - in a real implementation, you would:
//     // 1. Record actual audio during the interview
//     // 2. Convert the audio to the required format
//     // 3. Return the audio file
//
//     // For now, we'll create a dummy file
//     final directory = Directory.systemTemp;
//     final file = File('${directory.path}/audio_${DateTime.now().millisecondsSinceEpoch}.wav');
//     await file.writeAsString(transcript); // This is just for demo
//     return file;
//   }
//
//   /// Handle errors
//   void _handleError(String message) {
//     if (kDebugMode) {
//       print('InterviewManager Error: $message');
//     }
//     errorMessage.value = message;
//     interviewState.value = InterviewState.error;
//     isProcessing.value = false;
//   }
//
//   /// Reset the interview
//   void reset() {
//     _voiceService.cancelAll();
//     _answerTimer?.cancel();
//     _silenceTimer?.cancel();
//
//     interviewState.value = InterviewState.notStarted;
//     currentSession.value = null;
//     currentQuestion.value = '';
//     currentAnswer.value = '';
//     isProcessing.value = false;
//     errorMessage.value = '';
//   }
//
//   /// Dispose resources
//   void dispose() {
//     _voiceService.dispose();
//     _answerTimer?.cancel();
//     _silenceTimer?.cancel();
//     interviewState.dispose();
//     currentSession.dispose();
//     currentQuestion.dispose();
//     currentAnswer.dispose();
//     allAnswers.dispose();
//     isProcessing.dispose();
//     errorMessage.dispose();
//   }
// }
