import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class CategoryScoreCard extends StatelessWidget {
  final String category;
  final double score;
  final Color color;

  const CategoryScoreCard({
    super.key,
    required this.category,
    required this.score,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getScoreDescription(score),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                score.toStringAsFixed(1),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 60,
                child: LinearProgressIndicator(
                  value: score / 10,
                  backgroundColor: AppTheme.textSecondary.withOpacity(0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                  minHeight: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getScoreDescription(double score) {
    if (score >= 9.0) return 'Excellent';
    if (score >= 8.0) return 'Very Good';
    if (score >= 7.0) return 'Good';
    if (score >= 6.0) return 'Fair';
    return 'Needs Improvement';
  }
}






