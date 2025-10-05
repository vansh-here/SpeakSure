import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class QuestionCard extends StatelessWidget {
  final String question;
  final String category;
  final String difficulty;
  final int questionNumber;
  final int totalQuestions;

  const QuestionCard({
    super.key,
    required this.question,
    required this.category,
    required this.difficulty,
    required this.questionNumber,
    required this.totalQuestions,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.primaryColor.withOpacity(0.05),
              AppTheme.secondaryColor.withOpacity(0.02),
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            const SizedBox(height: 20),
            _buildQuestion(context),
            const SizedBox(height: 20),
            _buildTags(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            'Q$questionNumber',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            'Question $questionNumber of $totalQuestions',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        _buildDifficultyChip(context),
      ],
    );
  }

  Widget _buildDifficultyChip(BuildContext context) {
    Color chipColor;
    switch (difficulty.toLowerCase()) {
      case 'easy':
        chipColor = AppTheme.successColor;
        break;
      case 'medium':
        chipColor = AppTheme.warningColor;
        break;
      case 'hard':
        chipColor = AppTheme.errorColor;
        break;
      default:
        chipColor = AppTheme.textSecondary;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        difficulty,
        style: TextStyle(
          color: chipColor,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildQuestion(BuildContext context) {
    return Text(
      question,
      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: AppTheme.textPrimary,
        height: 1.4,
      ),
    );
  }

  Widget _buildTags(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _buildTag(context, Icons.category, category),
        _buildTag(context, Icons.schedule, '3 min'),
        _buildTag(context, Icons.record_voice_over, 'Voice Response'),
      ],
    );
  }

  Widget _buildTag(BuildContext context, IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: 6),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}


