import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class DonutChart extends StatelessWidget {
  final Map<String, double> data; // label -> value
  const DonutChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final colors = [
      AppTheme.primaryColor,
      AppTheme.successColor,
      AppTheme.accentColor,
      AppTheme.secondaryColor,
      AppTheme.warningColor,
    ];

    final total = data.values.fold<double>(0, (p, c) => p + c);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.pie_chart, color: Color(0xFF06B6D4), size: 20),
            const SizedBox(width: 8),
            Text('Question Types', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 220,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 58,
              sections: List.generate(data.length, (i) {
                final entry = data.entries.elementAt(i);
                final pct = total == 0 ? 0 : (entry.value / total * 100);
                return PieChartSectionData(
                  value: entry.value,
                  title: '${pct.toStringAsFixed(0)}%',
                  radius: 60,
                  color: colors[i % colors.length],
                  titleStyle: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                );
              }),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 8,
          children: List.generate(data.length, (i) {
            final entry = data.entries.elementAt(i);
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(width: 10, height: 10, decoration: BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle)),
                const SizedBox(width: 6),
                Text(entry.key, style: Theme.of(context).textTheme.bodySmall),
              ],
            );
          }),
        ),
      ],
    );
  }
}
