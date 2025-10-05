import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class VoiceVisualizer extends StatefulWidget {
  final bool isActive;
  final bool isListening;
  final double height;
  final int barCount;

  const VoiceVisualizer({
    super.key,
    required this.isActive,
    this.isListening = false,
    this.height = 40.0,
    this.barCount = 5,
  });

  @override
  State<VoiceVisualizer> createState() => _VoiceVisualizerState();
}

class _VoiceVisualizerState extends State<VoiceVisualizer>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late List<AnimationController> _barControllers;
  late List<Animation<double>> _barAnimations;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    _barControllers = List.generate(
      widget.barCount,
      (index) => AnimationController(
        duration: Duration(milliseconds: 300 + (index * 100)),
        vsync: this,
      ),
    );

    _barAnimations = _barControllers.map((controller) {
      return Tween<double>(
        begin: 0.1,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.easeInOut,
      ));
    }).toList();

    if (widget.isActive) {
      _startAnimation();
    }
  }

  @override
  void didUpdateWidget(VoiceVisualizer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _startAnimation();
      } else {
        _stopAnimation();
      }
    }
  }

  void _startAnimation() {
    _animationController.repeat();
    for (int i = 0; i < _barControllers.length; i++) {
      _barControllers[i].repeat(
        reverse: true,
        period: Duration(milliseconds: 500 + (i * 150)),
      );
    }
  }

  void _stopAnimation() {
    _animationController.stop();
    for (var controller in _barControllers) {
      controller.stop();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in _barControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height,
      width: double.infinity,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(widget.barCount, (index) {
          return _buildBar(index);
        }),
      ),
    );
  }

  Widget _buildBar(int index) {
    return AnimatedBuilder(
      animation: _barAnimations[index],
      builder: (context, child) {
        final height = widget.isActive
            ? widget.height * _barAnimations[index].value * (0.5 + Random().nextDouble() * 0.5)
            : widget.height * 0.1;

        return Container(
          width: 4,
          height: height,
          margin: const EdgeInsets.symmetric(horizontal: 2),
          decoration: BoxDecoration(
            color: _getBarColor(index),
            borderRadius: BorderRadius.circular(2),
            boxShadow: widget.isActive
                ? [
                    BoxShadow(
                      color: _getBarColor(index).withOpacity(0.3),
                      blurRadius: 4,
                      spreadRadius: 1,
                    ),
                  ]
                : null,
          ),
        );
      },
    );
  }

  Color _getBarColor(int index) {
    if (!widget.isActive) {
      return AppTheme.textSecondary.withOpacity(0.3);
    }

    if (widget.isListening) {
      return AppTheme.primaryColor;
    }

    // Create a gradient effect across bars
    final colors = [
      AppTheme.successColor,
      AppTheme.primaryColor,
      AppTheme.secondaryColor,
      AppTheme.warningColor,
      AppTheme.errorColor,
    ];

    return colors[index % colors.length];
  }
}



