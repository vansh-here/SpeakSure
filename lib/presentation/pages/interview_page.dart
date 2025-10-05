import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import '../../core/services/interview_service.dart';
import '../../core/di/providers.dart';
import '../../data/models/api_models.dart';
import '../widgets/voice_visualizer.dart';

class InterviewPage extends ConsumerStatefulWidget {
  const InterviewPage({super.key});

  @override
  ConsumerState<InterviewPage> createState() => _InterviewPageState();
}

class _InterviewPageState extends ConsumerState<InterviewPage>
    with TickerProviderStateMixin {
  
  // Animation controllers
  late AnimationController _fadeController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;
  
  // Audio services
  final AudioPlayer _audioPlayer = AudioPlayer();
  final AudioRecorder _audioRecorder = AudioRecorder();
  
  // State variables
  String? _conversationId;
  String? _currentQuestion;
  bool _isLoading = false;
  bool _isPlayingQuestion = false;
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _recordingPath;
  String? _error;
  int _questionNumber = 1;
  bool _interviewCompleted = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startInterview();
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _pulseController.repeat(reverse: true);
  }

  Future<void> _startInterview() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final interviewService = await ref.read(interviewServiceProvider.future);
      final response = await interviewService.startInterview();
      
      setState(() {
        _conversationId = response.conversationId;
        _currentQuestion = response.firstQuestion;
        _isLoading = false;
      });

      // Play the first question if available
      if (_currentQuestion != null) {
        await _playQuestionAudio();
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _playQuestionAudio() async {
    if (_conversationId == null) return;

    setState(() {
      _isPlayingQuestion = true;
    });

    try {
      final interviewService = await ref.read(interviewServiceProvider.future);
      final audioBytes = await interviewService.getAudio(_conversationId!);
      
      if (audioBytes.isNotEmpty) {
        // Save audio to temporary file and play it
        final directory = await getTemporaryDirectory();
        final audioFile = File('${directory.path}/question_${DateTime.now().millisecondsSinceEpoch}.mp3');
        await audioFile.writeAsBytes(Uint8List.fromList(audioBytes));
        
        // TODO: Implement actual audio playback using audioplayers package
        // For now, simulate playback duration
        await Future.delayed(const Duration(seconds: 3));
      } else {
        // Fallback: use text-to-speech
        await Future.delayed(const Duration(seconds: 3));
      }
      
      setState(() {
        _isPlayingQuestion = false;
      });
    } catch (e) {
      setState(() {
        _isPlayingQuestion = false;
      });
      // Continue without audio if it fails
    }
  }

  Future<void> _startRecording() async {
    try {
      if (await _audioRecorder.hasPermission()) {
        final directory = await getTemporaryDirectory();
        _recordingPath = '${directory.path}/answer_${DateTime.now().millisecondsSinceEpoch}.m4a';
        
        await _audioRecorder.start(
          const RecordConfig(),
          path: _recordingPath!,
        );
        
        setState(() {
          _isRecording = true;
        });
      }
    } catch (e) {
      _showError('Failed to start recording: $e');
    }
  }

  Future<void> _stopRecording() async {
    try {
      await _audioRecorder.stop();
      setState(() {
        _isRecording = false;
      });
      
      if (_recordingPath != null) {
        await _submitAnswer();
      }
    } catch (e) {
      _showError('Failed to stop recording: $e');
    }
  }

  Future<void> _submitAnswer() async {
    if (_conversationId == null || _recordingPath == null) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      final interviewService = await ref.read(interviewServiceProvider.future);
      final audioFile = File(_recordingPath!);
      
      final response = await interviewService.provideAnswer(_conversationId!, audioFile);
      
      setState(() {
        _questionNumber++;
        _isProcessing = false;
      });

      if (response.isComplete) {
        // Interview completed
        setState(() {
          _interviewCompleted = true;
        });
        _showCompletionDialog();
      } else if (response.nextQuestion != null) {
        // Next question available
        setState(() {
          _currentQuestion = response.nextQuestion;
        });
        await _playQuestionAudio();
      }
    } catch (e) {
      setState(() {
        _isProcessing = false;
      });
      _showError('Failed to submit answer: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF374151),
        title: const Text(
          'Interview Completed!',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Thank you for completing the interview. Your responses are being analyzed.',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/report');
            },
            child: const Text('View Report'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _audioPlayer.dispose();
    _audioRecorder.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3748),
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                _buildHeader(),
                const SizedBox(height: 40),
                Expanded(
                  child: _buildContent(),
                ),
                _buildControls(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
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
              'Question $_questionNumber',
              style: TextStyle(
                color: Colors.grey[400],
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(width: 48), // Balance the back button
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF6366F1)),
            SizedBox(height: 16),
            Text(
              'Starting your interview...',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text(
              'Error: $_error',
              style: const TextStyle(color: Colors.white, fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _startInterview,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6366F1),
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Question display
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF374151),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPlayingQuestion 
                ? const Color(0xFF6366F1) 
                : Colors.transparent,
              width: 2,
            ),
          ),
          child: Column(
            children: [
              if (_isPlayingQuestion)
                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.volume_up, color: Color(0xFF6366F1)),
                    SizedBox(width: 8),
                    Text(
                      'Playing question...',
                      style: TextStyle(
                        color: Color(0xFF6366F1),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              if (_currentQuestion != null) ...[
                const SizedBox(height: 16),
                Text(
                  _currentQuestion!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        
        const SizedBox(height: 40),
        
        // Voice visualizer
        if (_isRecording)
          ScaleTransition(
            scale: _pulseAnimation,
            child: const VoiceVisualizer(
              isActive: true,
              isListening: true,
            ),
          ),
        
        if (_isProcessing)
          const Column(
            children: [
              CircularProgressIndicator(color: Color(0xFF6366F1)),
              SizedBox(height: 16),
              Text(
                'Processing your answer...',
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildControls() {
    return Column(
      children: [
        if (!_isPlayingQuestion && !_isProcessing && _currentQuestion != null)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Record button
              GestureDetector(
                onTapDown: (_) => _startRecording(),
                onTapUp: (_) => _stopRecording(),
                onTapCancel: () => _stopRecording(),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: _isRecording 
                      ? Colors.red 
                      : const Color(0xFF6366F1),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (_isRecording ? Colors.red : const Color(0xFF6366F1))
                            .withOpacity(0.3),
                        blurRadius: 20,
                        spreadRadius: 5,
                      ),
                    ],
                  ),
                  child: Icon(
                    _isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
              ),
            ],
          ),
        
        const SizedBox(height: 16),
        
        Text(
          _isRecording 
            ? 'Release to stop recording'
            : _isPlayingQuestion
              ? 'Listen to the question...'
              : _isProcessing
                ? 'Processing your answer...'
                : 'Hold to record your answer',
          style: TextStyle(
            color: Colors.grey[400],
            fontSize: 14,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
