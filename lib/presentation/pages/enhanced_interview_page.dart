import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:record/record.dart';
import 'package:path_provider/path_provider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:dio/dio.dart';
import '../../core/services/interview_service.dart';
import '../../core/di/providers.dart';
import '../widgets/animated_avatar.dart';

class EnhancedInterviewPage extends ConsumerStatefulWidget {
  const EnhancedInterviewPage({super.key});

  @override
  ConsumerState<EnhancedInterviewPage> createState() => _EnhancedInterviewPageState();
}

class _EnhancedInterviewPageState extends ConsumerState<EnhancedInterviewPage>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _avatarController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  
  // Audio components
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  // Interview state
  String? _conversationId;
  String _currentQuestion = '';
  int _currentQuestionIndex = 0;
  bool _isPlayingQuestion = false;
  bool _isListening = false;
  bool _isProcessing = false;
  bool _isInterviewComplete = false;
  String? _recordingPath;
  Timer? _silenceTimer;
  Timer? _recordingTimer;
  
  // Avatar emotion
  AvatarEmotion _currentEmotion = AvatarEmotion.neutral;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeAudio();
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
  Future<void> _startInterview() async {
    try {
      final interviewService = await ref.read(interviewServiceProvider.future);
      final response = await interviewService.startInterview();
      
      setState(() {
        _conversationId = response.conversationId;
        _currentQuestion = response.firstQuestion ?? 'Welcome to your interview!';
        _currentQuestionIndex = 1;
      });
      
      _avatarController.forward();
      
      // Wait for avatar animation then start playing question
      await Future.delayed(const Duration(milliseconds: 500));
      
      _playQuestionAudio();
      
    } catch (e) {
      setState(() {
        _currentQuestion = 'Error starting interview. Please try again.';
      });
    }
  }

  Future<void> _playQuestionAudio() async {
    if (_conversationId == null) return;
    
    setState(() {
      _isPlayingQuestion = true;
      _currentEmotion = AvatarEmotion.speaking;
    });
    
    try {
      final interviewService = await ref.read(interviewServiceProvider.future);
      final audioBytes = await interviewService.getAudio(_conversationId!);
      
      if (audioBytes.isNotEmpty) {
        // Save audio to temporary file
        final directory = await getTemporaryDirectory();
        final audioFile = File('${directory.path}/question_${DateTime.now().millisecondsSinceEpoch}.mp3');
        
        await audioFile.writeAsBytes(Uint8List.fromList(audioBytes));
        
        // Play the audio file
        await _audioPlayer.play(DeviceFileSource(audioFile.path));
      } else {
        // Fallback: show question text only
        setState(() {
          _isPlayingQuestion = false;
          _currentEmotion = AvatarEmotion.neutral;
        });
        
        // Auto-start listening after 2 seconds
        Future.delayed(const Duration(seconds: 2), () {
          _startListening();
        });
      }
    } catch (e) {
      print('Error playing question audio: $e');
      // Fallback: show question text and start listening
      setState(() {
        _isPlayingQuestion = false;
        _currentEmotion = AvatarEmotion.neutral;
      });
      
      Future.delayed(const Duration(seconds: 2), () {
        _startListening();
      });
    }
  }

  Future<void> _startListening() async {
    if (_conversationId == null || _isInterviewComplete) return;
    
    setState(() {
      _isListening = true;
      _currentEmotion = AvatarEmotion.listening;
    });
    
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        _recordingPath = '${directory.path}/answer_${DateTime.now().millisecondsSinceEpoch}.wav';
        
        await _audioRecorder.start(
          const RecordConfig(
            encoder: AudioEncoder.wav,
            sampleRate: 16000,
            bitRate: 128000,
          ),
          path: _recordingPath!,
        );
        
        // Auto-stop recording after 60 seconds (max answer time)
        _recordingTimer = Timer(const Duration(seconds: 60), () {
          _stopListening();
        });
        
        // Start silence detection timer (4-5 seconds of silence)
        _startSilenceDetection();
      }
    } catch (e) {
      print('Error starting recording: $e');
      setState(() {
        _isListening = false;
        _currentEmotion = AvatarEmotion.neutral;
      });
    }
  }
  
  void _startSilenceDetection() {
    // Reset silence timer every time this is called
    _silenceTimer?.cancel();
    
    // Start new silence timer for 4 seconds
    _silenceTimer = Timer(const Duration(seconds: 4), () {
      if (_isListening) {
        _stopListening();
      }
    });
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
      await _audioRecorder.stop();
      
      if (_recordingPath != null && _conversationId != null) {
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
    if (_conversationId == null || _recordingPath == null) return;
    
    try {
      final interviewService = await ref.read(interviewServiceProvider.future);
      final audioFile = File(_recordingPath!);
      
      final response = await interviewService.provideAnswer(_conversationId!, audioFile);
      
      setState(() {
        _isProcessing = false;
        _currentQuestionIndex++;
      });
      
      if (response.isComplete) {
        _completeInterview();
      } else if (response.nextQuestion != null) {
        setState(() {
          _currentQuestion = response.nextQuestion!;
          _currentEmotion = AvatarEmotion.satisfied;
        });
        
        // Wait a moment then play next question
        await Future.delayed(const Duration(seconds: 2));
        _playQuestionAudio();
      }
      
    } catch (e) {
      setState(() {
        _isProcessing = false;
        _currentEmotion = AvatarEmotion.disappointed;
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

  @override
  void dispose() {
    _fadeController.dispose();
    _avatarController.dispose();
    _silenceTimer?.cancel();
    _recordingTimer?.cancel();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SafeArea(
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
              Expanded(
                flex: 2,
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
              
              // Question Display
              Expanded(
                flex: 1,
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
                          const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 8),
                              Text(
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
                        
                        Text(
                          _currentQuestion,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
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
  }
}
