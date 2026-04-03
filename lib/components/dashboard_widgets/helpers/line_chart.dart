import 'package:expense_manager/providers/expense_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LineChartWidget extends StatefulWidget {
  final List<LineChartBarData> Function(ExpenseProvider) getLineBarData;
  final Widget Function(double, TitleMeta) leftTitleWidgets;
  final Widget Function(double, TitleMeta) bottomTitleWidgets;
  final List<LineTooltipItem?> Function(List<LineBarSpot>) getTooltipItems;
  const LineChartWidget({
    super.key,
    required this.getLineBarData,
    required this.leftTitleWidgets,
    required this.bottomTitleWidgets,
    required this.getTooltipItems,
  });

  @override
  State<StatefulWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget> {
  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    var lineBarData = widget.getLineBarData(expenseProvider);

    // Calculate dynamic interval based on number of data points
    // Aim for ~4-6 labels on the x-axis
    int interval = 1;
    if (lineBarData.isNotEmpty && lineBarData.first.spots.isNotEmpty) {
      final dataPointCount = lineBarData.first.spots.length;
      if (dataPointCount > 24) {
        interval = (dataPointCount / 6).ceil(); // ~6 labels
      } else if (dataPointCount > 12) {
        interval = 3; // ~4 labels
      }
    }

    return Card(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: LineChart(LineChartData(
              minY: 0,
              gridData: const FlGridData(
                show: true,
                drawVerticalLine: false,
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          interval: interval.toDouble(),
                          getTitlesWidget: widget.bottomTitleWidgets)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                          showTitles: true,
                          getTitlesWidget: widget.leftTitleWidgets,
                          reservedSize: 40)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false))),
              lineBarsData: lineBarData,
              lineTouchData: LineTouchData(
                getTouchLineStart: (_, __) => -double.infinity,
                getTouchLineEnd: (_, __) => double.infinity,
                getTouchedSpotIndicator:
                    (LineChartBarData barData, List<int> spotIndexes) {
                  return spotIndexes.map((spotIndex) {
                    return TouchedSpotIndicatorData(
                      FlLine(
                        color: Theme.of(context).colorScheme.secondary,
                        strokeWidth: 1.5,
                        dashArray: [8, 2],
                      ),
                      FlDotData(
                        show: true,
                        getDotPainter: (spot, percent, barData, index) {
                          return FlDotCirclePainter(
                            radius: 6,
                            color: barData.color!,
                            strokeWidth: 0,
                          );
                        },
                      ),
                    );
                  }).toList();
                },
                touchSpotThreshold: 15,
                touchTooltipData: LineTouchTooltipData(
                  fitInsideHorizontally: true,
                  getTooltipColor: (group) => Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withValues(alpha: .80),
                  getTooltipItems: widget.getTooltipItems,
                ),
              ),
            ))));
  }
}
