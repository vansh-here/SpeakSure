import 'dart:math';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class ContributionHeatmap extends StatelessWidget {
  final int weeks;
  final List<int>? data; // values 0..n per day
  final double cellSize;
  final double cellSpacing;

  const ContributionHeatmap({
    super.key,
    this.weeks = 20,
    this.data,
    this.cellSize = 12,
    this.cellSpacing = 3,
  });

  Color _levelColor(BuildContext context, int value) {
    final levels = [
      Theme.of(context).brightness == Brightness.dark ? const Color(0xFF0E1623) : const Color(0xFFE2E8F0),
      AppTheme.primaryColor.withOpacity(0.25),
      AppTheme.primaryColor.withOpacity(0.45),
      AppTheme.primaryColor.withOpacity(0.65),
      AppTheme.primaryColor.withOpacity(0.85),
    ];
    if (value <= 0) return levels[0];
    if (value <= 2) return levels[1];
    if (value <= 4) return levels[2];
    if (value <= 6) return levels[3];
    return levels[4];
  }

  @override
  Widget build(BuildContext context) {
    final rng = Random(42);
    final values = data ?? List<int>.generate(7 * weeks, (_) => rng.nextInt(8));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.grid_view_rounded, size: 20, color: AppTheme.primaryColor),
            const SizedBox(width: 8),
            Text(
              'Activity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: List.generate(weeks, (w) {
              return Padding(
                padding: EdgeInsets.only(right: cellSpacing),
                child: Column(
                  children: List.generate(7, (d) {
                    final idx = d * weeks + w;
                    final v = values[idx % values.length];
                    return Container(
                      width: cellSize,
                      height: cellSize,
                      margin: EdgeInsets.only(bottom: cellSpacing),
                      decoration: BoxDecoration(
                        color: _levelColor(context, v),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Text('Less', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
            const SizedBox(width: 8),
            ...List.generate(5, (i) => Container(
              width: cellSize,
              height: cellSize,
              margin: EdgeInsets.only(right: 4),
              decoration: BoxDecoration(
                color: _levelColor(context, i * 2),
                borderRadius: BorderRadius.circular(3),
              ),
            )),
            const SizedBox(width: 8),
            Text('More', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppTheme.textSecondary)),
          ],
        )
      ],
    );
  }
}
