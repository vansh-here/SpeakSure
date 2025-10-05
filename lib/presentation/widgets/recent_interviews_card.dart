import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class RecentInterviewsCard extends StatelessWidget {
  const RecentInterviewsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.history,
                  color: AppTheme.primaryColor,
                  size: 24,
                ),
                const SizedBox(width: 12),
                Text(
                  'Recent Interviews',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () {
                    // Navigate to all interviews
                  },
                  child: Text(
                    'View All',
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildInterviewItem(
              context,
              'Software Engineer Interview',
              '8.5',
              '2 days ago',
              AppTheme.successColor,
            ),
            const SizedBox(height: 16),
            _buildInterviewItem(
              context,
              'Product Manager Interview',
              '7.8',
              '1 week ago',
              AppTheme.warningColor,
            ),
            const SizedBox(height: 16),
            _buildInterviewItem(
              context,
              'Data Scientist Interview',
              '9.2',
              '2 weeks ago',
              AppTheme.successColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInterviewItem(
    BuildContext context,
    String title,
    String score,
    String date,
    Color scoreColor,
  ) {
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
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: scoreColor,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: scoreColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              score,
              style: TextStyle(
                color: scoreColor,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


