import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/theme/app_theme.dart';

class TimerWidget extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onTimeUp;
  final bool showProgress;

  const TimerWidget({
    super.key,
    required this.duration,
    this.onTimeUp,
    this.showProgress = true,
  });

  @override
  State<TimerWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends State<TimerWidget> {
  late Timer _timer;
  late Duration _remainingTime;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = widget.duration;
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (!_isRunning) {
      setState(() {
        _isRunning = true;
      });
      
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          if (_remainingTime.inSeconds > 0) {
            _remainingTime = Duration(seconds: _remainingTime.inSeconds - 1);
          } else {
            _timer.cancel();
            _isRunning = false;
            widget.onTimeUp?.call();
          }
        });
      });
    }
  }

  void _pauseTimer() {
    if (_isRunning) {
      _timer.cancel();
      setState(() {
        _isRunning = false;
      });
    }
  }

  void _resetTimer() {
    _timer.cancel();
    setState(() {
      _remainingTime = widget.duration;
      _isRunning = false;
    });
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  double get _progress {
    return 1.0 - (_remainingTime.inSeconds / widget.duration.inSeconds);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: _remainingTime.inSeconds < 30 
            ? AppTheme.errorColor.withOpacity(0.1)
            : AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _remainingTime.inSeconds < 30 
              ? AppTheme.errorColor.withOpacity(0.3)
              : AppTheme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.timer,
            size: 16,
            color: _remainingTime.inSeconds < 30 
                ? AppTheme.errorColor
                : AppTheme.primaryColor,
          ),
          const SizedBox(width: 8),
          Text(
            _formatDuration(_remainingTime),
            style: TextStyle(
              color: _remainingTime.inSeconds < 30 
                  ? AppTheme.errorColor
                  : AppTheme.primaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          if (widget.showProgress) ...[
            const SizedBox(width: 8),
            SizedBox(
              width: 40,
              height: 4,
              child: LinearProgressIndicator(
                value: _progress,
                backgroundColor: AppTheme.textSecondary.withOpacity(0.2),
                valueColor: AlwaysStoppedAnimation<Color>(
                  _remainingTime.inSeconds < 30 
                      ? AppTheme.errorColor
                      : AppTheme.primaryColor,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}


