import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with TickerProviderStateMixin {
  late AnimationController _controller1;
  late AnimationController _controller2;
  late AnimationController _controller3;
  
  late Animation<double> _animation1;
  late Animation<double> _animation2;
  late Animation<double> _animation3;

  @override
  void initState() {
    super.initState();
    
    _controller1 = AnimationController(
      duration: const Duration(seconds: 8),
      vsync: this,
    );
    _controller2 = AnimationController(
      duration: const Duration(seconds: 12),
      vsync: this,
    );
    _controller3 = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _animation1 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller1,
      curve: Curves.easeInOut,
    ));
    
    _animation2 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller2,
      curve: Curves.easeInOut,
    ));
    
    _animation3 = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller3,
      curve: Curves.easeInOut,
    ));
    
    _controller1.repeat(reverse: true);
    _controller2.repeat(reverse: true);
    _controller3.repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller1.dispose();
    _controller2.dispose();
    _controller3.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: Theme.of(context).brightness == Brightness.dark
              ? [
                  AppTheme.backgroundDark,
                  const Color(0xFF0B1220),
                  AppTheme.backgroundDark,
                ]
              : [
                  AppTheme.backgroundColor,
                  const Color(0xFFF1F5F9),
                  AppTheme.backgroundColor,
                ],
        ),
      ),
      child: Stack(
        children: [
          // Animated circles
          Positioned(
            top: -100,
            right: -100,
            child: AnimatedBuilder(
              animation: _animation1,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.8 + (_animation1.value * 0.4),
                  child: Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.primaryColor.withOpacity(0.1),
                          AppTheme.primaryColor.withOpacity(0.05),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Positioned(
            bottom: -150,
            left: -150,
            child: AnimatedBuilder(
              animation: _animation2,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.6 + (_animation2.value * 0.6),
                  child: Container(
                    width: 400,
                    height: 400,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.secondaryColor.withOpacity(0.08),
                          AppTheme.secondaryColor.withOpacity(0.03),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          Positioned(
            top: 200,
            left: -50,
            child: AnimatedBuilder(
              animation: _animation3,
              builder: (context, child) {
                return Transform.scale(
                  scale: 0.7 + (_animation3.value * 0.5),
                  child: Container(
                    width: 200,
                    height: 200,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.accentColor.withOpacity(0.06),
                          AppTheme.accentColor.withOpacity(0.02),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          
          // Floating particles
          ...List.generate(20, (index) {
            return Positioned(
              top: (index * 50.0) % MediaQuery.of(context).size.height,
              left: (index * 30.0) % MediaQuery.of(context).size.width,
              child: AnimatedBuilder(
                animation: _controller1,
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      (index % 2 == 0 ? 1 : -1) * _animation1.value * 20,
                      (index % 3 == 0 ? 1 : -1) * _animation2.value * 15,
                    ),
                    child: Opacity(
                      opacity: 0.3 + (_animation1.value * 0.4),
                      child: Container(
                        width: 4 + (index % 3) * 2,
                        height: 4 + (index % 3) * 2,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: index % 3 == 0 
                              ? AppTheme.primaryColor
                              : index % 3 == 1
                                  ? AppTheme.secondaryColor
                                  : AppTheme.accentColor,
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}






