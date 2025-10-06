import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/services/interview_service.dart';
import '../../core/di/providers.dart';
import '../widgets/animated_avatar.dart';

class WebInterviewPage extends ConsumerStatefulWidget {
  const WebInterviewPage({super.key});

  @override
  ConsumerState<WebInterviewPage> createState() => _WebInterviewPageState();
}

class _WebInterviewPageState extends ConsumerState<WebInterviewPage>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _avatarController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Audio components
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterTts _flutterTts = FlutterTts();
  late stt.SpeechToText _speechToText;
  
  // Interview state
  String? _conversationId;
  String _currentQuestion = '';
  List<String> _questionWords = [];
  int _currentWordIndex = 0;
  int _currentQuestionIndex = 0;
  bool _isPlayingQuestion = false;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isInterviewComplete = false;
  Timer? _silenceTimer;
  Timer? _wordHighlightTimer;
  Timer? _noInputTimer;
  Timer? _uiUpdateTimer;
  
  // Speech recognition
  String _transcribedText = '';
  bool _speechEnabled = false;
  DateTime? _lastSpeechTime;
  bool _hasReceivedInput = false;
  int _silenceCountdown = 0;
  int _noInputCountdown = 0;
  
  // Avatar emotion
  AvatarEmotion _currentEmotion = AvatarEmotion.happy;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAudio();
    _initializeSpeechToText();
    _startInterview();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    
    _avatarController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _avatarController, curve: Curves.elasticOut),
    );

    _fadeController.forward();
  }

  Future<void> _initializeAudio() async {
    // Setup TTS
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(0.5);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
    
    _flutterTts.setCompletionHandler(() {
      setState(() {
        _isPlayingQuestion = false;
        _currentEmotion = AvatarEmotion.happy;
        _currentWordIndex = 0;
      });
      // Start listening after question completes
      Future.delayed(const Duration(milliseconds: 500), () {
        _startListening();
      });
    });

    // Setup audio player completion handler
    _audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        _isPlayingQuestion = false;
        _currentEmotion = AvatarEmotion.neutral;
      });
      // Start listening after question audio completes
      Future.delayed(const Duration(milliseconds: 500), () {
        _startListening();
      });
    });
  }

  Future<void> _initializeSpeechToText() async {
    _speechToText = stt.SpeechToText();
    _speechEnabled = await _speechToText.initialize(
      onStatus: (status) {
        print('Speech status: $status');
        if (status == 'done' || status == 'notListening') {
          // Speech recognition has stopped, handle accordingly
          if (_isListening && _hasReceivedInput) {
            _stopListening();
          }
        }
      },
      onError: (error) {
        print('Speech recognition error: $error');
        setState(() {
          _transcribedText = 'Speech recognition error. Please try again.';
        });
      },
      debugLogging: true,
    );
    print('Speech recognition initialized: $_speechEnabled');
  }

  Future<void> _startInterview() async {
    try {
      final interviewService = await ref.read(interviewServiceProvider.future);
      final response = await interviewService.startInterview();
      
      setState(() {
        _conversationId = response.conversationId;
        _currentQuestion = response.firstQuestion ?? 'Welcome to your interview! Let\'s begin with our first question.';
        _currentQuestionIndex = 1;
        _questionWords = _currentQuestion.split(' ');
      });
      
      _avatarController.forward();
      
      // Wait for avatar animation then start playing question
      await Future.delayed(const Duration(milliseconds: 500));
      
      _playQuestionWithHighlighting();
      
    } catch (e) {
      setState(() {
        _currentQuestion = 'Error starting interview. Please try again.';
        _questionWords = _currentQuestion.split(' ');
      });
    }
  }

  Future<void> _playQuestionWithHighlighting() async {
    setState(() {
      _isPlayingQuestion = true;
      _currentEmotion = AvatarEmotion.speaking;
      _currentWordIndex = 0;
    });

    print('=== PLAYING QUESTION WITH HIGHLIGHTING ===');
    print('Question to play: $_currentQuestion');

    // Try to play audio from backend first
    bool audioPlayed = await _tryPlayBackendAudio();
    
    if (!audioPlayed) {
      print('Backend audio failed or unavailable, using TTS for: $_currentQuestion');
      // Fallback to TTS with word highlighting
      await _playQuestionWithTTS();
    } else {
      print('Successfully played backend audio for: $_currentQuestion');
    }
  }

  Future<bool> _tryPlayBackendAudio() async {
    if (_conversationId == null) return false;
    
    // TEMPORARY FIX: Only use backend audio for first question
    // Backend audio state is not updating for subsequent questions
    if (_currentQuestionIndex > 1) {
      print('=== SKIPPING BACKEND AUDIO ===');
      print('Backend audio is stuck on first question, using TTS instead');
      print('Question index: $_currentQuestionIndex');
      return false; // This will trigger TTS fallback
    }
    
    try {
      final interviewService = await ref.read(interviewServiceProvider.future);
      
      print('=== USING BACKEND AUDIO FOR FIRST QUESTION ===');
      print('Conversation ID: $_conversationId');
      print('Current question on screen: $_currentQuestion');
      
      // Get the audio for the first question only
      print('Fetching audio for first question: $_currentQuestion');
      final audioBytes = await interviewService.getAudio(_conversationId!);
      
      if (audioBytes != null && audioBytes.isNotEmpty) {
        print('Audio received: ${audioBytes.length} bytes');
        print('Playing backend audio for first question: $_currentQuestion');
        
        // Start word highlighting while playing audio
        _startWordHighlighting();
        
        // For web, play audio from bytes directly
        await _audioPlayer.play(BytesSource(Uint8List.fromList(audioBytes)));
        return true;
      } else {
        print('No audio bytes received from backend');
      }
    } catch (e) {
      print('Error playing backend audio: $e');
    }
    
    return false;
  }

  Future<void> _playQuestionWithTTS() async {
    // Start word highlighting
    _startWordHighlighting();
    
    // Use TTS to speak the question
    await _flutterTts.speak(_currentQuestion);
  }

  void _startWordHighlighting() {
    _wordHighlightTimer?.cancel();
    _currentWordIndex = 0;
    
    // Calculate timing based on question length (roughly 150 words per minute)
    final wordsPerSecond = 2.5;
    final intervalMs = (1000 / wordsPerSecond).round();
    
    _wordHighlightTimer = Timer.periodic(Duration(milliseconds: intervalMs), (timer) {
      if (_currentWordIndex < _questionWords.length - 1) {
        setState(() {
          _currentWordIndex++;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _startListening() async {
    if (!_speechEnabled || _isListening) return;
    
    setState(() {
      _isListening = true;
      _currentEmotion = AvatarEmotion.listening;
      _transcribedText = 'Listening... Start speaking now';
      _hasReceivedInput = false;
      _silenceCountdown = 0;
      _noInputCountdown = 10; // Start with 10 seconds
    });
    
    // Start no-input timer (10 seconds)
    _startNoInputTimer();
    
    try {
      // Start speech recognition for real-time transcription
      if (await _speechToText.hasPermission) {
        await _speechToText.listen(
          onResult: (result) {
            print('Speech result: ${result.recognizedWords}');
            
            if (result.recognizedWords.isNotEmpty) {
              _hasReceivedInput = true;
              _lastSpeechTime = DateTime.now();
              _silenceCountdown = 0;
              
              // Cancel no-input timer since we got input
              _noInputTimer?.cancel();
              _uiUpdateTimer?.cancel();
              
              setState(() {
                _transcribedText = result.recognizedWords;
                _noInputCountdown = 0;
              });
              
              // Start silence detection timer (6 seconds)
              _startSilenceDetection();
            }
          },
          listenFor: const Duration(minutes: 5), // Extended listening time
          pauseFor: const Duration(seconds: 6), // 6 second pause detection
          partialResults: true,
          localeId: 'en_US',
          cancelOnError: false,
        );
      }
    } catch (e) {
      print('Error starting speech recognition: $e');
      setState(() {
        _isListening = false;
        _transcribedText = 'Error starting speech recognition: $e';
      });
    }
  }

  void _startNoInputTimer() {
    _noInputTimer?.cancel();
    _uiUpdateTimer?.cancel();
    _noInputCountdown = 10;
    
    // Start UI update timer for countdown
    _uiUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isListening && !_hasReceivedInput) {
        setState(() {
          _noInputCountdown--;
        });
        
        if (_noInputCountdown <= 0) {
          timer.cancel();
          print('No input received for 10 seconds, stopping listening');
          _stopListening();
        }
      } else {
        timer.cancel();
      }
    });
  }
  
  void _startSilenceDetection() {
    _silenceTimer?.cancel();
    _uiUpdateTimer?.cancel(); // Cancel no-input timer UI updates
    _silenceCountdown = 6;
    
    _silenceTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_lastSpeechTime != null) {
        final silenceDuration = DateTime.now().difference(_lastSpeechTime!);
        setState(() {
          _silenceCountdown = 6 - silenceDuration.inSeconds;
        });
        
        if (_silenceCountdown <= 0 && _isListening && _hasReceivedInput) {
          print('6 seconds of silence detected, stopping listening');
          timer.cancel();
          _stopListening();
        }
      }
    });
  }

  Future<void> _stopListening() async {
    _silenceTimer?.cancel();
    _noInputTimer?.cancel();
    _uiUpdateTimer?.cancel();
    
    setState(() {
      _isListening = false;
      _isProcessing = true;
      _currentEmotion = AvatarEmotion.thinking;
      _silenceCountdown = 0;
      _noInputCountdown = 0;
    });
    
    try {
      await _speechToText.stop();
      
      if (_conversationId != null) {
        await _submitAnswer();
      }
    } catch (e) {
      print('Error stopping speech recognition: $e');
      setState(() {
        _isProcessing = false;
        _currentEmotion = AvatarEmotion.neutral;
      });
    }
  }

  Future<void> _submitAnswer() async {
    if (_conversationId == null) return;
    
    try {
      // For web, use transcribed text directly
      print('Web: Using transcribed text: $_transcribedText');
      final hasValidInput = _transcribedText.isNotEmpty &&
          !_transcribedText.contains('Listening') &&
          !_transcribedText.contains('Error') &&
          !_transcribedText.contains('Click');

      if (hasValidInput) {
        await _submitAnswerToBackend();
      } else {
        await _submitAnswerToBackend(
          answerOverride: 'No response provided.',
        );
        if (mounted) {
          setState(() {
            _transcribedText = 'No input detected. Moving to the next question.';
          });
        }
      }
      
    } catch (e) {
      print('Error submitting answer: $e');
      setState(() {
        _isProcessing = false;
        _currentEmotion = AvatarEmotion.disappointed;
        _transcribedText = 'Error submitting answer: $e';
      });
    }
  }

  Future<void> _submitAnswerToBackend({String? answerOverride}) async {
    if (_conversationId == null) return;
    
    try {
      final interviewService = await ref.read(interviewServiceProvider.future);
      
      setState(() {
        _isProcessing = true;
        _currentEmotion = AvatarEmotion.thinking;
      });
      
      print('=== SUBMITTING ANSWER TO BACKEND ===');
      print('Current conversation ID: $_conversationId');
      print('Current question index: $_currentQuestionIndex');
      var answerText = (answerOverride ?? _transcribedText).trim();
      if (answerText.isEmpty) {
        answerText = 'No response provided.';
      }
      print('Transcribed text: $answerText');
      print('Answer override used: ${answerOverride != null}');
      
      // Submit the transcribed text as answer
      final response = await interviewService.provideTextAnswer(_conversationId!, answerText);
      
      print('=== RESPONSE ANALYSIS ===');
      print('Response message: ${response.message}');
      print('Is complete: ${response.isComplete}');
      print('Next question: ${response.nextQuestion}');
      
      setState(() {
        _isProcessing = false;
        _currentQuestionIndex++;
      });
      
      // CRITICAL: Only complete if backend explicitly says so AND we've had enough questions
      final minQuestions = 5; // Minimum questions before allowing completion
      
      if (response.isComplete == true && _currentQuestionIndex >= minQuestions) {
        print('=== INTERVIEW COMPLETE ===');
        print('Backend marked interview as complete after $_currentQuestionIndex questions');
        _completeInterview();
        return;
      } else if (response.isComplete == true && _currentQuestionIndex < minQuestions) {
        print('=== BACKEND WANTS TO COMPLETE TOO EARLY ===');
        print('Backend wants to complete after only $_currentQuestionIndex questions');
        print('Forcing continuation to reach minimum of $minQuestions questions');
        // Override backend decision and continue
      }
      
      // Continue with next question (either from backend response or fallback)
      String nextQuestion;
      
      if (response.nextQuestion != null && response.nextQuestion!.isNotEmpty) {
        nextQuestion = response.nextQuestion!;
        print('=== USING BACKEND NEXT QUESTION ===');
      } else {
        // Get the next question from backend to ensure sync
        final backendQuestion = await interviewService.getCurrentQuestion(_conversationId!);
        if (backendQuestion != null && backendQuestion.isNotEmpty) {
          nextQuestion = backendQuestion;
          print('=== USING BACKEND CURRENT QUESTION ===');
        } else {
          // Generate a fallback question if backend doesn't provide one
          final fallbackQuestions = [
            'Tell me about a challenging project you worked on recently.',
            'Describe a time when you had to work with a difficult team member.',
            'What are your career goals for the next 5 years?',
            'How do you handle stress and pressure in the workplace?',
            'What motivates you in your work?',
            'Describe your ideal work environment.',
            'How do you stay updated with industry trends?',
            'Tell me about a time you had to learn something new quickly.',
            'What are your strengths and weaknesses?',
            'Do you have any questions for us?'
          ];
          
          final questionIndex = (_currentQuestionIndex - 1) % fallbackQuestions.length;
          nextQuestion = fallbackQuestions[questionIndex];
          print('=== USING FALLBACK QUESTION ===');
          print('Question index: $questionIndex');
        }
      }
      
      print('=== CONTINUING INTERVIEW ===');
      print('Setting next question: $nextQuestion');
      print('Current question count: $_currentQuestionIndex');
      
      setState(() {
        _currentQuestion = nextQuestion;
        _questionWords = _currentQuestion.split(' ');
        _currentEmotion = AvatarEmotion.satisfied;
        _transcribedText = '';
      });
      
      print('Question updated in state');
      print('New current question: $_currentQuestion');
      
      // Only complete if we've reached the maximum questions (safety net)
      if (_currentQuestionIndex >= 10) {
        print('=== REACHED MAXIMUM QUESTIONS ===');
        print('Completed $_currentQuestionIndex questions, ending interview');
        await Future.delayed(const Duration(seconds: 2));
        _completeInterview();
        return;
      }
      
      // Wait a bit longer to ensure backend has updated its state
      // This ensures the audio we fetch matches the question we just set
      await Future.delayed(const Duration(seconds: 2));
      
      print('=== ABOUT TO PLAY NEXT QUESTION ===');
      print('Question to play: $_currentQuestion');
      
      // CRITICAL: Ensure backend knows about the current question before getting audio
      // The issue is that backend audio endpoint might not be synced with the new question
      try {
        // First, verify what question the backend thinks is current
        final backendCurrentQuestion = await interviewService.getCurrentQuestion(_conversationId!);
        print('=== BACKEND QUESTION CHECK ===');
        print('UI Question: $_currentQuestion');
        print('Backend Question: $backendCurrentQuestion');
        
        if (backendCurrentQuestion != null && backendCurrentQuestion != _currentQuestion) {
          print('=== BACKEND OUT OF SYNC ===');
          print('Backend has different question than UI');
          print('This explains why audio is wrong!');
          
          // Update UI to match backend (backend is the source of truth for audio)
          setState(() {
            _currentQuestion = backendCurrentQuestion;
            _questionWords = _currentQuestion.split(' ');
          });
          
          print('Updated UI to match backend: $backendCurrentQuestion');
        }
      } catch (e) {
        print('Error checking backend question: $e');
      }
      
      _playQuestionWithHighlighting();
      
    } catch (e) {
      print('Error submitting answer to backend: $e');
      setState(() {
        _isProcessing = false;
        _currentEmotion = AvatarEmotion.disappointed;
        _transcribedText = 'Error processing your answer. Please try again.';
      });
    }
  }

  void _completeInterview() {
    setState(() {
      _isInterviewComplete = true;
      _currentEmotion = AvatarEmotion.happy;
    });
    
    // Show completion message then navigate to report
    _showCompletionDialog();
  }
  
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF16213E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Interview Complete!',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Great job! Your interview has been completed successfully. Let\'s review your performance.',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/report?conversation_id=$_conversationId');
            },
            child: const Text(
              'View Report',
              style: TextStyle(color: Color(0xFF3282B8), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHighlightedQuestion() {
    return RichText(
      textAlign: TextAlign.center,
      text: TextSpan(
        children: _questionWords.asMap().entries.map((entry) {
          final index = entry.key;
          final word = entry.value;
          final isHighlighted = index <= _currentWordIndex && _isPlayingQuestion;
          
          return TextSpan(
            text: '$word ',
            style: TextStyle(
              color: isHighlighted ? const Color(0xFF3282B8) : Colors.white,
              fontSize: 16,
              fontWeight: isHighlighted ? FontWeight.bold : FontWeight.w500,
              height: 1.5,
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _avatarController.dispose();
    _silenceTimer?.cancel();
    _wordHighlightTimer?.cancel();
    _noInputTimer?.cancel();
    _uiUpdateTimer?.cancel();
    _audioPlayer.dispose();
    _flutterTts.stop();
    _speechToText.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        // Header
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              IconButton(
                                onPressed: () => context.pop(),
                                icon: const Icon(Icons.arrow_back, color: Colors.white),
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Interview in Progress',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Question $_currentQuestionIndex',
                                    style: TextStyle(
                                      color: Colors.grey[400],
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 48),
                            ],
                          ),
                        ),
                        
                        // Avatar
                        Container(
                          height: 250,
                          child: Center(
                            child: ScaleTransition(
                              scale: _scaleAnimation,
                              child: AnimatedAvatar(
                                emotion: _currentEmotion,
                                size: 200,
                              ),
                            ),
                          ),
                        ),
                        
                        // Question Display with Word Highlighting
                        Container(
                          constraints: BoxConstraints(minHeight: 120),
                          child: Container(
                            margin: const EdgeInsets.all(24),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: const Color(0xFF16213E),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: _isPlayingQuestion 
                                    ? const Color(0xFF0F4C75) 
                                    : _isListening
                                        ? const Color(0xFF3282B8)
                                        : Colors.transparent,
                                width: 2,
                              ),
                            ),
                            child: Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (_isPlayingQuestion)
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.volume_up, color: Color(0xFF0F4C75)),
                                        SizedBox(width: 8),
                                        Text(
                                          'Playing question...',
                                          style: TextStyle(
                                            color: Color(0xFF0F4C75),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  
                                  if (_isListening)
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 12,
                                          height: 12,
                                          decoration: const BoxDecoration(
                                            color: Color(0xFF3282B8),
                                            shape: BoxShape.circle,
                                          ),
                                          child: const CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Text(
                                          'Listening...',
                                          style: TextStyle(
                                            color: Color(0xFF3282B8),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  
                                  if (_isProcessing)
                                    const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFBBE1FA)),
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          'Processing...',
                                          style: TextStyle(
                                            color: Color(0xFFBBE1FA),
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  
                                  const SizedBox(height: 16),
                                  
                                  // Question with word highlighting
                                  _buildHighlightedQuestion(),
                                ],
                              ),
                            ),
                          ),
                        ),
                        
                        // Enhanced Transcription Display with Professional UI
                        if (_isListening || _transcribedText.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: _isListening 
                                    ? [const Color(0xFF0F3460), const Color(0xFF1A4B84)]
                                    : [const Color(0xFF16213E), const Color(0xFF0F3460)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: _isListening ? const Color(0xFF3282B8) : Colors.transparent, 
                                width: 2
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: _isListening 
                                      ? const Color(0xFF3282B8).withOpacity(0.3)
                                      : Colors.black.withOpacity(0.2),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: _isListening 
                                            ? Colors.red.withOpacity(0.2)
                                            : const Color(0xFF3282B8).withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Icon(
                                        _isListening ? Icons.mic : Icons.mic_off, 
                                        color: _isListening ? Colors.red : const Color(0xFF3282B8), 
                                        size: 20
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            _isListening ? 'Listening for your response...' : 'Your Response',
                                            style: TextStyle(
                                              color: _isListening ? Colors.red : const Color(0xFF3282B8),
                                              fontWeight: FontWeight.w600,
                                              fontSize: 16,
                                            ),
                                          ),
                                          if (_isListening && !_hasReceivedInput && _noInputCountdown > 0)
                                            Text(
                                              'Auto-stop in ${_noInputCountdown}s if no input',
                                              style: TextStyle(
                                                color: Colors.grey[400],
                                                fontSize: 12,
                                              ),
                                            ),
                                          if (_isListening && _hasReceivedInput && _silenceCountdown > 0)
                                            Text(
                                              'Auto-stop in ${_silenceCountdown}s of silence',
                                              style: TextStyle(
                                                color: Colors.orange[300],
                                                fontSize: 12,
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                          colors: [Color(0xFF10B981), Color(0xFF059669)],
                                        ),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: const Text(
                                        'AUTO MODE',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.3),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    _transcribedText.isEmpty 
                                        ? (_isListening 
                                            ? 'Start speaking... I\'m listening' 
                                            : 'Waiting for your response...')
                                        : _transcribedText,
                                    style: TextStyle(
                                      color: _transcribedText.isEmpty ? Colors.grey[400] : Colors.white,
                                      fontSize: 16,
                                      height: 1.4,
                                      fontStyle: _transcribedText.isEmpty ? FontStyle.italic : FontStyle.normal,
                                    ),
                                  ),
                                ),
                                if (_isListening)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 12),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Recording... Speak naturally',
                                          style: TextStyle(
                                            color: Colors.grey[300],
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        
                        // Professional Status Indicator
                        Container(
                          margin: const EdgeInsets.all(24.0),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF16213E), Color(0xFF0F3460)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: const Color(0xFF3282B8).withOpacity(0.3)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 16,
                                height: 16,
                                decoration: BoxDecoration(
                                  color: _isPlayingQuestion 
                                      ? const Color(0xFF0F4C75)
                                      : _isListening
                                          ? Colors.red
                                          : _isProcessing
                                              ? const Color(0xFFBBE1FA)
                                              : _isInterviewComplete
                                                  ? const Color(0xFF10B981)
                                                  : const Color(0xFF3282B8),
                                  shape: BoxShape.circle,
                                ),
                                child: _isPlayingQuestion || _isListening || _isProcessing
                                    ? const SizedBox(
                                        width: 12,
                                        height: 12,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 1.5,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : null,
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _isPlayingQuestion 
                                          ? '🎧 Listen carefully to the question'
                                          : _isListening
                                              ? '🎤 Speak your answer (Auto: 10s no input, 6s silence)'
                                              : _isProcessing
                                                  ? '🤔 Analyzing your response...'
                                                  : _isInterviewComplete
                                                      ? '🎉 Interview completed successfully!'
                                                      : '🚀 Ready for your interview',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      _isPlayingQuestion 
                                          ? 'Audio will play automatically, then listening will start'
                                          : _isListening
                                              ? 'Automatic detection - just speak naturally'
                                              : _isProcessing
                                                  ? 'Please wait while we process your answer'
                                                  : _isInterviewComplete
                                                      ? 'Great job! Check your detailed report'
                                                      : 'The interview will start automatically after the question',
                                      style: TextStyle(
                                        color: Colors.grey[400],
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        // Status Text
                        Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Text(
                            _isPlayingQuestion 
                                ? 'Listen carefully to the question...'
                                : _isListening
                                    ? 'Speak your answer now (will auto-stop after 4 seconds of silence)'
                                    : _isProcessing
                                        ? 'Analyzing your response...'
                                        : _isInterviewComplete
                                            ? 'Interview completed successfully!'
                                            : 'Get ready for your interview',
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
