import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/app_theme.dart';
import '../../core/services/auth_service.dart';
import '../../core/di/providers.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LandingPage extends ConsumerStatefulWidget {
  const LandingPage({super.key});

  @override
  ConsumerState<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends ConsumerState<LandingPage>
    with TickerProviderStateMixin {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _goalController = TextEditingController();

  String? _resumePath;
  File? _resumeFile;
  bool _isLoading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _pickResume() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
      );

      if (result != null) {
        setState(() {
          if (kIsWeb) {
            _resumePath = result.files.single.name;
          } else {
            _resumePath = result.files.single.path;
            _resumeFile = File(result.files.single.path!);
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking file: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitForm() async {
    if (_nameController.text.trim().isEmpty) {
      _showError('Please enter your full name');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final authService = await ref.read(authServiceProvider.future);

      // First, create user with name
      final userResponse = await authService.createUser(
        name: _nameController.text.trim(),
        goal: _goalController.text.trim().isNotEmpty ? _goalController.text.trim() : null,
      );
      
      // Then upload resume if provided (this stores resume in RAM after user creation)
      if (_resumeFile != null) {
        await authService.uploadResume(
          filePath: _resumeFile!.path,
          fileName: _resumePath!.split('/').last,
          fileType: _resumePath!.split('.').last,
        );
      }

      if (mounted) {
        // Navigate to dashboard page
        context.go('/dashboard');
      }
    } catch (e) {
      _showError('Error: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red,
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2D3748), // Dark blue-gray background
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1200),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      bool isWide = constraints.maxWidth > 800;
                      return isWide
                          ? Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Expanded(flex: 1, child: _buildForm()),
                                const SizedBox(width: 60),
                                Expanded(flex: 1, child: _buildIllustration()),
                              ],
                            )
                          : Column(
                              children: [
                                _buildForm(),
                                const SizedBox(height: 40),
                                _buildIllustration(),
                              ],
                            );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Form fields
        _buildTextField(
          _nameController,
          'Full Name',
          Icons.person,
          textColor: Colors.white,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          _emailController,
          'Email',
          Icons.email,
          textColor: Colors.white,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          _ageController,
          'Age',
          Icons.cake,
          textColor: Colors.white,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          _goalController,
          'Career Goal',
          Icons.work,
          textColor: Colors.white,
          maxLines: 2,
        ),
        const SizedBox(height: 30),
        
        // Resume upload
        _buildResumeUpload(),
        const SizedBox(height: 40),
        
        // Submit button
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _submitForm,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6366F1), // Purple color
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Submit',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      ],
    );
  }


  Widget _buildTextField(
    TextEditingController controller,
    String label,
    IconData icon, {
    required Color textColor,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: Colors.grey[400]),
        filled: true,
        fillColor: const Color(0xFF374151), // Darker gray
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }

  Widget _buildResumeUpload() {
    return InkWell(
      onTap: _pickResume,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: const Color(0xFF374151), // Darker gray
          border: _resumePath != null
              ? Border.all(color: const Color(0xFF10B981), width: 2) // Green border when uploaded
              : null,
        ),
        child: Row(
          children: [
            Icon(
              _resumePath != null ? Icons.check_circle : Icons.upload_file,
              color: _resumePath != null ? const Color(0xFF10B981) : Colors.grey[400],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _resumePath != null
                    ? 'Resume uploaded: ${_resumePath!.split('/').last}'
                    : 'Tap to upload your resume (PDF, DOC, DOCX)',
                style: TextStyle(
                  fontWeight: _resumePath != null ? FontWeight.w500 : FontWeight.normal,
                  color: _resumePath != null ? const Color(0xFF10B981) : Colors.grey[400],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIllustration() {
    return Container(
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Image.asset(
          'assets/images/Interview.png',
          fit: BoxFit.contain,
          errorBuilder: (context, error, stackTrace) {
            // Fallback illustration if image not found
            return Container(
              decoration: BoxDecoration(
                color: const Color(0xFF374151),
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.mic,
                      size: 80,
                      color: Color(0xFF6366F1),
                    ),
                    SizedBox(height: 16),
                    Text(
                      'SpeakSure',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'AI-Powered Interview Practice',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
