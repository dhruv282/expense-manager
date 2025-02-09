import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BarChartWidget extends StatefulWidget {
  final List<BarChartGroupData> Function(List<ExpenseData>)
      getBarChartGroupData;
  final Widget Function(double, TitleMeta) leftTitleWidgets;
  final Widget Function(double, TitleMeta) bottomTitleWidgets;
  final BarTooltipItem? Function(BarChartGroupData, int, BarChartRodData, int)
      getTooltipItems;
  const BarChartWidget({
    super.key,
    required this.getBarChartGroupData,
    required this.leftTitleWidgets,
    required this.bottomTitleWidgets,
    required this.getTooltipItems,
  });

  @override
  State<StatefulWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget> {
  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    var groupData = widget.getBarChartGroupData(expenseProvider.expenses);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: BarChart(BarChartData(
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
                      interval: 1,
                      getTitlesWidget: widget.bottomTitleWidgets)),
              topTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                      showTitles: true,
                      getTitlesWidget: widget.leftTitleWidgets,
                      reservedSize: 40)),
              rightTitles:
                  const AxisTitles(sideTitles: SideTitles(showTitles: false))),
          barGroups: groupData,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipItem: widget.getTooltipItems,
              getTooltipColor: (group) => Theme.of(context)
                  .colorScheme
                  .secondaryContainer
                  .withValues(alpha: .80),
            ),
          ),
        )),
      ),
    );
  }
}
