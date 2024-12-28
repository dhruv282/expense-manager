import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LineChartWidget extends StatefulWidget {
  final List<LineChartBarData> Function(List<ExpenseData>) getLineBarData;
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
    var lineBarData = widget.getLineBarData(expenseProvider.expenses);

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
                  getTooltipColor: (group) => Theme.of(context)
                      .colorScheme
                      .secondaryContainer
                      .withOpacity(.80),
                  getTooltipItems: widget.getTooltipItems,
                ),
              ),
            ))));
  }
}
