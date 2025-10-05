import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_recognition_error.dart';

enum VoiceState {
  idle,
  speaking,
  listening,
  processing,
}

class EnhancedVoiceService {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _stt = stt.SpeechToText();

  bool _sttAvailable = false;
  final ValueNotifier<VoiceState> voiceState = ValueNotifier(VoiceState.idle);
  final ValueNotifier<bool> isListening = ValueNotifier(false);
  final ValueNotifier<String> transcript = ValueNotifier('');
  final ValueNotifier<double> confidence = ValueNotifier(0.0);
  final ValueNotifier<bool> isVoiceActive = ValueNotifier(false);

  // Timing configurations
  static const Duration _silenceThreshold = Duration(seconds: 3);
  static const Duration _minAnswerTime = Duration(seconds: 4);
  static const Duration _maxAnswerTime = Duration(minutes: 3);

  Timer? _silenceTimer;
  Timer? _voiceActivityTimer;
  DateTime _lastVoiceActivity = DateTime.now();
  bool _isQuestionBeingSpoken = false;

  /// Initialize TTS and STT with enhanced settings
  Future<void> init() async {
    await _initTts();
    _sttAvailable = await _stt.initialize(
      onStatus: _handleSttStatus,
      onError: _handleSttError,
    );
  }

  /// Configure TTS with natural speech patterns
  Future<void> _initTts() async {
    try {
      // More natural speech rate for interview questions
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);

      // Set language for better pronunciation
      await _tts.setLanguage("en-US");

      if (defaultTargetPlatform == TargetPlatform.iOS) {
        await _tts.setSharedInstance(true);
      }

      // Set completion handler
      _tts.setCompletionHandler(() {
        _isQuestionBeingSpoken = false;
        if (voiceState.value == VoiceState.speaking) {
          _transitionToListening();
        }
      });
    } catch (e) {
      if (kDebugMode) print('TTS Init Error: $e');
    }
  }

  /// Speak question with natural pacing
  Future<void> speakQuestion(String question) async {
    _isQuestionBeingSpoken = true;
    voiceState.value = VoiceState.speaking;

    try {
      await stopTts();

      // Add natural pauses in longer questions
      final processedQuestion = _addNaturalPauses(question);

      await _tts.speak(processedQuestion);

      // Start listening after a brief pause
      Timer(const Duration(milliseconds: 500), () {
        if (_isQuestionBeingSpoken) {
          _transitionToListening();
        }
      });
    } catch (e) {
      if (kDebugMode) print('TTS Speak Error: $e');
      _transitionToListening();
    }
  }

  /// Add natural pauses to make speech more conversational
  String _addNaturalPauses(String text) {
    // Add pauses after commas and periods for more natural speech
    return text
        .replaceAll(',', ',<break time="500ms"/>')
        .replaceAll('.', '.<break time="800ms"/>')
        .replaceAll('?', '?<break time="1s"/>');
  }

  /// Transition to listening state
  void _transitionToListening() {
    if (!_isQuestionBeingSpoken) {
      voiceState.value = VoiceState.listening;
      _startListening();
    }
  }

  /// Start enhanced listening with voice activity detection
  Future<void> _startListening() async {
    if (!_sttAvailable) {
      _sttAvailable = await _stt.initialize();
      if (!_sttAvailable) return;
    }

    transcript.value = '';
    isListening.value = true;
    voiceState.value = VoiceState.listening;

    try {
      await _stt.listen(
        localeId: 'en_US',
        onResult: _handleSttResult,
        listenFor: _maxAnswerTime,
        pauseFor: _silenceThreshold,
        listenOptions: stt.SpeechListenOptions(
          listenMode: stt.ListenMode.dictation,
          partialResults: true,
        ),
      );

      _startVoiceActivityDetection();
    } catch (e) {
      isListening.value = false;
      voiceState.value = VoiceState.idle;
      if (kDebugMode) print('STT Listen Error: $e');
    }
  }

  /// Handle STT results with confidence tracking
  void _handleSttResult(SpeechRecognitionResult result) {
    transcript.value = result.recognizedWords;
    confidence.value = result.confidence;

    // Update voice activity
    if (result.recognizedWords.isNotEmpty) {
      _lastVoiceActivity = DateTime.now();
      isVoiceActive.value = true;
    }
  }

  /// Start voice activity detection
  void _startVoiceActivityDetection() {
    _voiceActivityTimer?.cancel();
    _voiceActivityTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      final timeSinceLastActivity = DateTime.now().difference(_lastVoiceActivity);

      if (timeSinceLastActivity > _silenceThreshold && isVoiceActive.value) {
        isVoiceActive.value = false;
        _onSilenceDetected();
      }
    });
  }

  /// Handle silence detection
  void _onSilenceDetected() {
    if (transcript.value.trim().isNotEmpty) {
      // User has provided an answer, stop listening
      _stopListening();
    }
  }

  /// Stop listening and process answer
  Future<void> _stopListening() async {
    try {
      await _stt.stop();
    } catch (_) {}

    isListening.value = false;
    voiceState.value = VoiceState.processing;
    _voiceActivityTimer?.cancel();

    // Wait a moment before processing
    await Future.delayed(const Duration(milliseconds: 500));
    voiceState.value = VoiceState.idle;
  }

  /// Handle STT status changes
  void _handleSttStatus(String status) {
    switch (status) {
      case 'listening':
        isListening.value = true;
        voiceState.value = VoiceState.listening;
        break;
      case 'notListening':
      case 'done':
        isListening.value = false;
        if (voiceState.value == VoiceState.listening) {
          voiceState.value = VoiceState.idle;
        }
        break;
    }
  }

  /// Handle STT errors
  void _handleSttError(SpeechRecognitionError error) {
    isListening.value = false;
    voiceState.value = VoiceState.idle;
    if (kDebugMode) {
      print('STT Error: ${error.errorMsg}');
    }
  }

  /// Stop TTS
  Future<void> stopTts() async {
    try {
      await _tts.stop();
      _isQuestionBeingSpoken = false;
    } catch (_) {}
  }

  /// Stop listening manually
  Future<void> stopListening() async {
    await _stopListening();
  }

  /// Cancel all voice operations
  Future<void> cancelAll() async {
    _voiceActivityTimer?.cancel();
    _silenceTimer?.cancel();
    await _stt.cancel();
    await stopTts();
    isListening.value = false;
    voiceState.value = VoiceState.idle;
  }

  /// Get current transcript
  String getCurrentTranscript() => transcript.value;

  /// Check if user is currently speaking
  bool get isUserSpeaking => isVoiceActive.value;

  /// Get speech confidence
  double get speechConfidence => confidence.value;

  /// Check if enough time has passed for user to start answering
  bool get canStartAnswering {
    if (_isQuestionBeingSpoken) return false;
    final timeSinceQuestion = DateTime.now().difference(_lastVoiceActivity);
    return timeSinceQuestion >= _minAnswerTime;
  }

  /// Dispose resources
  void dispose() {
    _voiceActivityTimer?.cancel();
    _silenceTimer?.cancel();
    _tts.stop();
    _stt.cancel();
    voiceState.dispose();
    isListening.dispose();
    transcript.dispose();
    confidence.dispose();
    isVoiceActive.dispose();
  }
}
