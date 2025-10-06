import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../core/theme/app_theme.dart';

enum AvatarEmotion {
  neutral,
  happy,
  satisfied,
  thinking,
  listening,
  speaking,
  disappointed,
  encouraging,
}

class AnimatedAvatar extends StatefulWidget {
  final AvatarEmotion emotion;
  final double size;
  final bool isActive;
  final VoidCallback? onTap;

  const AnimatedAvatar({
    super.key,
    required this.emotion,
    this.size = 200.0,
    this.isActive = true,
    this.onTap,
  });

  @override
  State<AnimatedAvatar> createState() => _AnimatedAvatarState();
}

class _AnimatedAvatarState extends State<AnimatedAvatar>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _bounceController;
  late AnimationController _fadeController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _bounceAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    // Pulse animation for active state
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Bounce animation for interactions
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    // Fade animation for emotion changes
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));

    _fadeController.forward();
    if (widget.isActive) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(AnimatedAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
        _pulseController.reset();
      }
    }
    if (widget.emotion != oldWidget.emotion) {
      _fadeController.reset();
      _fadeController.forward();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _handleTap() {
    _bounceController.forward().then((_) {
      _bounceController.reverse();
    });
    widget.onTap?.call();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _pulseAnimation,
          _bounceAnimation,
          _fadeAnimation,
        ]),
        builder: (context, child) {
          return Transform.scale(
            scale: widget.isActive ? _pulseAnimation.value * _bounceAnimation.value : _bounceAnimation.value,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildAvatarContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAvatarContent() {
    return Container(
      width: widget.size,
      height: widget.size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: _getEmotionGradient(),
        boxShadow: [
          BoxShadow(
            color: _getEmotionColor().withOpacity(0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          _buildAvatarFace(),
          if (widget.isActive) _buildActiveIndicator(),
        ],
      ),
    );
  }

  Widget _buildAvatarFace() {
    return Container(
      width: widget.size * 0.8,
      height: widget.size * 0.8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.9),
      ),
      child: _getEmotionWidget(),
    );
  }

  Widget _buildActiveIndicator() {
    return Positioned(
      top: 10,
      right: 10,
      child: Container(
        width: 16,
        height: 16,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppTheme.successColor,
          boxShadow: [
            BoxShadow(
              color: AppTheme.successColor.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Icon(
          Icons.mic,
          color: Colors.white,
          size: 10,
        ),
      ),
    );
  }

  Widget _getEmotionWidget() {
    switch (widget.emotion) {
      case AvatarEmotion.happy:
        return _buildHappyFace();
      case AvatarEmotion.satisfied:
        return _buildSatisfiedFace();
      case AvatarEmotion.thinking:
        return _buildThinkingFace();
      case AvatarEmotion.listening:
        return _buildListeningFace();
      case AvatarEmotion.speaking:
        return _buildSpeakingFace();
      case AvatarEmotion.disappointed:
        return _buildDisappointedFace();
      case AvatarEmotion.encouraging:
        return _buildEncouragingFace();
      default:
        return _buildNeutralFace();
    }
  }

  Widget _buildNeutralFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Eyes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEye(),
            _buildEye(),
          ],
        ),
        const SizedBox(height: 8),
        // Mouth
        Container(
          width: 30,
          height: 15,
          decoration: BoxDecoration(
            color: AppTheme.textSecondary,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ],
    );
  }

  Widget _buildHappyFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Eyes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEye(),
            _buildEye(),
          ],
        ),
        const SizedBox(height: 8),
        // Smile
        Container(
          width: 40,
          height: 20,
          decoration: BoxDecoration(
            color: AppTheme.successColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSatisfiedFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Eyes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEye(),
            _buildEye(),
          ],
        ),
        const SizedBox(height: 8),
        // Slight smile
        Container(
          width: 35,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildThinkingFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Eyes looking up
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEye(offset: const Offset(0, -2)),
            _buildEye(offset: const Offset(0, -2)),
          ],
        ),
        const SizedBox(height: 8),
        // Neutral mouth
        Container(
          width: 25,
          height: 12,
          decoration: BoxDecoration(
            color: AppTheme.textSecondary,
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ],
    );
  }

  Widget _buildListeningFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Wide eyes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEye(size: 12),
            _buildEye(size: 12),
          ],
        ),
        const SizedBox(height: 8),
        // Slightly open mouth
        Container(
          width: 20,
          height: 8,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ],
    );
  }

  Widget _buildSpeakingFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Normal eyes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEye(),
            _buildEye(),
          ],
        ),
        const SizedBox(height: 8),
        // Open mouth
        Container(
          width: 25,
          height: 15,
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(15),
          ),
        ),
      ],
    );
  }

  Widget _buildDisappointedFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Sad eyes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEye(shape: EyeShape.sad),
            _buildEye(shape: EyeShape.sad),
          ],
        ),
        const SizedBox(height: 8),
        // Frown
        Container(
          width: 30,
          height: 15,
          decoration: BoxDecoration(
            color: AppTheme.errorColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(15),
              topRight: Radius.circular(15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEncouragingFace() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Bright eyes
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildEye(color: AppTheme.primaryColor),
            _buildEye(color: AppTheme.primaryColor),
          ],
        ),
        const SizedBox(height: 8),
        // Encouraging smile
        Container(
          width: 35,
          height: 18,
          decoration: BoxDecoration(
            color: AppTheme.warningColor,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(18),
              bottomRight: Radius.circular(18),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEye({double size = 8.0, Offset offset = Offset.zero, Color? color, EyeShape shape = EyeShape.normal}) {
    return Transform.translate(
      offset: offset,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color ?? AppTheme.textPrimary,
        ),
        child: shape == EyeShape.sad
            ? Positioned(
                bottom: 0,
                child: Container(
                  width: size,
                  height: size / 2,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(size / 2),
                  ),
                ),
              )
            : null,
      ),
    );
  }

  LinearGradient _getEmotionGradient() {
    final color = _getEmotionColor();
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        color.withOpacity(0.8),
        color.withOpacity(0.6),
      ],
    );
  }

  Color _getEmotionColor() {
    switch (widget.emotion) {
      case AvatarEmotion.happy:
        return AppTheme.successColor;
      case AvatarEmotion.satisfied:
        return AppTheme.primaryColor;
      case AvatarEmotion.thinking:
        return AppTheme.warningColor;
      case AvatarEmotion.listening:
        return AppTheme.secondaryColor;
      case AvatarEmotion.speaking:
        return AppTheme.primaryColor;
      case AvatarEmotion.disappointed:
        return AppTheme.errorColor;
      case AvatarEmotion.encouraging:
        return AppTheme.warningColor;
      default:
        return AppTheme.textSecondary;
    }
  }
}

enum EyeShape { normal, sad }




