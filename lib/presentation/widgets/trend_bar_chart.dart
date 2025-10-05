import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class TrendBarChart extends StatelessWidget {
  final List<double> values; // weekly counts
  const TrendBarChart({super.key, required this.values});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.stacked_bar_chart, color: AppTheme.primaryColor, size: 20),
            const SizedBox(width: 8),
            Text('Weekly Practice', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 240,
          child: BarChart(
            BarChartData(
              gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 5, getDrawingHorizontalLine: (v) => FlLine(color: Colors.white12, strokeWidth: 1)),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, getTitlesWidget: (v, meta) {
                  final labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(labels[v.toInt() % labels.length], style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : AppTheme.textSecondary, fontSize: 12)),
                  );
                })),
                leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 28, getTitlesWidget: (v, meta) => Text(v.toInt().toString(), style: TextStyle(color: Theme.of(context).brightness == Brightness.dark ? Colors.white54 : AppTheme.textSecondary, fontSize: 12)))),
              ),
              barGroups: List.generate(values.length, (i) => BarChartGroupData(x: i, barRods: [
                BarChartRodData(toY: values[i], color: AppTheme.primaryColor, width: 14, borderRadius: const BorderRadius.vertical(top: Radius.circular(6))),
              ])),
            ),
          ),
        ),
      ],
    );
  }
}
