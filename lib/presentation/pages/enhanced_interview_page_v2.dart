import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../../core/services/interview_service.dart';
import '../../core/di/providers.dart';
import '../widgets/animated_avatar.dart';

// Conditional import for path_provider
import 'package:path_provider/path_provider.dart' if (dart.library.html) 'dart:html' as path;

class EnhancedInterviewPageV2 extends ConsumerStatefulWidget {
  const EnhancedInterviewPageV2({super.key});

  @override
  ConsumerState<EnhancedInterviewPageV2> createState() => _EnhancedInterviewPageV2State();
}

class _EnhancedInterviewPageV2State extends ConsumerState<EnhancedInterviewPageV2>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _avatarController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Audio components
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
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
  String? _recordingPath;
  Timer? _silenceTimer;
  Timer? _recordingTimer;
  Timer? _wordHighlightTimer;
  
  // Speech recognition
  String _transcribedText = '';
  bool _speechEnabled = false;
  DateTime? _lastSpeechTime;
  
  // Avatar emotion
  AvatarEmotion _currentEmotion = AvatarEmotion.neutral;

  // Helper method to get temporary directory safely
  Future<String?> _getTemporaryPath() async {
    if (kIsWeb) {
      return null; // Web doesn't use file paths
    }
    try {
      final directory = await getTemporaryDirectory();
      return directory.path;
    } catch (e) {
      print('Error getting temporary directory: $e');
      return null;
    }
  }

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
        _currentEmotion = AvatarEmotion.neutral;
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
          _checkForSilence();
        }
      },
      onError: (error) {
        print('Speech recognition error: $error');
        setState(() {
          _transcribedText = 'Speech recognition error: $error';
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

    // Try to play audio from backend first
    bool audioPlayed = await _tryPlayBackendAudio();
    
    if (!audioPlayed) {
      // Fallback to TTS with word highlighting
      await _playQuestionWithTTS();
    }
  }

  Future<bool> _tryPlayBackendAudio() async {
    if (_conversationId == null) return false;
    
    try {
      final interviewService = await ref.read(interviewServiceProvider.future);
      final audioBytes = await interviewService.getAudio(_conversationId!);
      
      if (audioBytes.isNotEmpty) {
        // Start word highlighting while playing audio
        _startWordHighlighting();
        
        if (kIsWeb) {
          // For web, play audio from bytes directly
          await _audioPlayer.play(BytesSource(Uint8List.fromList(audioBytes)));
        } else {
          // For mobile/desktop, save to file and play
          final tempPath = await _getTemporaryPath();
          if (tempPath != null) {
            final audioFile = File('$tempPath/question_${DateTime.now().millisecondsSinceEpoch}.mp3');
            await audioFile.writeAsBytes(Uint8List.fromList(audioBytes));
            await _audioPlayer.play(DeviceFileSource(audioFile.path));
          } else {
            // Fallback to TTS if file operations fail
            await _playQuestionWithTTS();
            return true;
          }
        }
        return true;
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
    if (_conversationId == null || _isInterviewComplete) return;
    
    setState(() {
      _isListening = true;
      _currentEmotion = AvatarEmotion.listening;
      _transcribedText = 'Initializing microphone...';
    });
    
    try {
      // Start audio recording
      bool hasRecordingPermission = await _audioRecorder.hasPermission();
      print('Recording permission: $hasRecordingPermission');
      
      if (hasRecordingPermission) {
        if (kIsWeb) {
          // For web, we'll rely on speech-to-text only
          print('Web: Using speech recognition only');
        } else {
          // For mobile/desktop, use file path
          try {
            final tempPath = await _getTemporaryPath();
            if (tempPath != null) {
              _recordingPath = '$tempPath/answer_${DateTime.now().millisecondsSinceEpoch}.wav';
              
              await _audioRecorder.start(
                const RecordConfig(
                  encoder: AudioEncoder.wav,
                  sampleRate: 16000,
                  bitRate: 128000,
                ),
                path: _recordingPath!,
              );
              print('Recording started');
            } else {
              print('Could not get temporary directory for recording');
            }
          } catch (e) {
            print('Recording setup failed: $e');
          }
        }
        
        // Auto-stop recording after 60 seconds (max answer time)
        _recordingTimer = Timer(const Duration(seconds: 60), () {
          _stopListening();
        });
      } else {
        setState(() {
          _transcribedText = 'Microphone permission denied';
        });
      }

      // Start speech recognition for real-time transcription
      if (_speechEnabled) {
        setState(() {
          _transcribedText = 'Listening... Start speaking now';
        });
        
        await _speechToText.listen(
          onResult: (result) {
            print('Speech result: ${result.recognizedWords}');
            setState(() {
              _transcribedText = result.recognizedWords.isEmpty 
                  ? 'Listening... Start speaking now' 
                  : result.recognizedWords;
            });
            if (result.recognizedWords.isNotEmpty) {
              _lastSpeechTime = DateTime.now();
            }
          },
          listenFor: const Duration(seconds: 60),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
          localeId: 'en_US',
          cancelOnError: false,
          listenMode: stt.ListenMode.confirmation,
        );
      } else {
        setState(() {
          _transcribedText = 'Speech recognition not available. Please check microphone permissions.';
        });
      }
      
    } catch (e) {
      print('Error starting recording: $e');
      setState(() {
        _isListening = false;
        _currentEmotion = AvatarEmotion.neutral;
        _transcribedText = 'Error: $e';
      });
    }
  }

  void _checkForSilence() {
    if (_lastSpeechTime != null) {
      final silenceDuration = DateTime.now().difference(_lastSpeechTime!);
      if (silenceDuration.inSeconds >= 4 && _isListening) {
        _stopListening();
      }
    }
  }

  Future<void> _stopListening() async {
    _silenceTimer?.cancel();
    _recordingTimer?.cancel();
    
    setState(() {
      _isListening = false;
      _isProcessing = true;
      _currentEmotion = AvatarEmotion.thinking;
    });
    
    try {
      await _speechToText.stop();
      
      if (_conversationId != null) {
        await _submitAnswer();
      }
    } catch (e) {
      print('Error stopping recording: $e');
      setState(() {
        _isProcessing = false;
        _currentEmotion = AvatarEmotion.neutral;
      });
    }
  }

  Future<void> _submitAnswer() async {
    if (_conversationId == null) return;
    
    try {
      if (kIsWeb) {
        // For web, use transcribed text directly
        print('Web: Using transcribed text: $_transcribedText');
        if (_transcribedText.isNotEmpty && !_transcribedText.contains('Listening') && !_transcribedText.contains('Error')) {
          _simulateAnswerSubmission();
        } else {
          setState(() {
            _isProcessing = false;
            _currentEmotion = AvatarEmotion.neutral;
            _transcribedText = 'Please speak your answer and try again';
          });
        }
      } else {
        // For mobile/desktop, use recorded file
        final interviewService = await ref.read(interviewServiceProvider.future);
        if (_recordingPath != null) {
          await _audioRecorder.stop();
          final audioFile = File(_recordingPath!);
          final response = await interviewService.provideAnswer(_conversationId!, audioFile);
          _handleAnswerResponse(response);
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

  void _simulateAnswerSubmission() {
    // Simulate processing delay
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        _isProcessing = false;
        _currentQuestionIndex++;
        _currentQuestion = 'Thank you for your response. Here\'s your next question: Can you tell me about a challenging project you worked on?';
        _questionWords = _currentQuestion.split(' ');
        _currentEmotion = AvatarEmotion.satisfied;
        _transcribedText = '';
      });
      
      // Play next question
      Future.delayed(const Duration(seconds: 1), () {
        _playQuestionWithHighlighting();
      });
    });
  }

  void _handleAnswerResponse(response) {
    setState(() {
      _isProcessing = false;
      _currentQuestionIndex++;
    });
    
    if (response.isComplete) {
      _completeInterview();
    } else if (response.nextQuestion != null) {
      setState(() {
        _currentQuestion = response.nextQuestion!;
        _questionWords = _currentQuestion.split(' ');
        _currentEmotion = AvatarEmotion.satisfied;
        _transcribedText = '';
      });
      
      // Wait a moment then play next question
      Future.delayed(const Duration(seconds: 2), () {
        _playQuestionWithHighlighting();
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
    _recordingTimer?.cancel();
    _wordHighlightTimer?.cancel();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
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
              
              // Transcription Display
              if (_isListening || _transcribedText.isNotEmpty)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F3460),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFF3282B8), width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isListening ? Icons.mic : Icons.mic_off, 
                            color: _isListening ? Colors.red : const Color(0xFF3282B8), 
                            size: 16
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isListening ? 'Listening...' : 'Your Response:',
                            style: TextStyle(
                              color: _isListening ? Colors.red : const Color(0xFF3282B8),
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          if (kIsWeb)
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: Colors.orange.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'WEB MODE',
                                style: TextStyle(
                                  color: Colors.orange,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _transcribedText.isEmpty ? 'Click "Start Listening" and speak your answer...' : _transcribedText,
                        style: TextStyle(
                          color: _transcribedText.isEmpty ? Colors.grey[400] : Colors.white,
                          fontSize: 16,
                          height: 1.4,
                        ),
                      ),
                      if (_speechEnabled && kIsWeb)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            'Speech Recognition: ${_speechToText.isListening ? "Active" : "Inactive"}',
                            style: TextStyle(
                              color: _speechToText.isListening ? Colors.green : Colors.grey[500],
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              
              // Manual Controls (for testing)
              if (!_isPlayingQuestion && !_isProcessing)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (!_isListening)
                        ElevatedButton.icon(
                          onPressed: _startListening,
                          icon: const Icon(Icons.mic),
                          label: const Text('Start Listening'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF3282B8),
                            foregroundColor: Colors.white,
                          ),
                        ),
                      if (_isListening)
                        ElevatedButton.icon(
                          onPressed: _stopListening,
                          icon: const Icon(Icons.stop),
                          label: const Text('Stop Listening'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
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
