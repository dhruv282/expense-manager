import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/dashboard_widgets/helpers/line_chart.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ExpenseVsIncomeLineChart extends DashboardWidget {
  @override
  Widget getWidget() {
    return _ExpenseVsIncomeLineChartContent();
  }
}

class _ExpenseVsIncomeLineChartContent extends StatefulWidget {
  const _ExpenseVsIncomeLineChartContent();

  @override
  State<_ExpenseVsIncomeLineChartContent> createState() =>
      _ExpenseVsIncomeLineChartContentState();
}

class _ExpenseVsIncomeLineChartContentState
    extends State<_ExpenseVsIncomeLineChartContent> {
  late List<(int, int)> sortedPeriods;
  late Map<(int, int), Tuple2<double, double>> monthlyIncomeAndExpenses;

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final compactCurrencyFormatter =
        NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0);
    final simpleCurrencyFormatter = NumberFormat.simpleCurrency();

    // Map (year, month) to (income, expense)
    monthlyIncomeAndExpenses = {};
    for (var expense in expenseProvider.expenses) {
      final key = (expense.date.year, expense.date.month);
      if (expenseProvider.isIncome(expense.category)) {
        monthlyIncomeAndExpenses.update(
          key,
          (tuple) => Tuple2(tuple.item1 + expense.cost, tuple.item2),
          ifAbsent: () => Tuple2(expense.cost, 0),
        );
      } else {
        monthlyIncomeAndExpenses.update(
          key,
          (tuple) => Tuple2(tuple.item1, tuple.item2 + expense.cost),
          ifAbsent: () => Tuple2(0, expense.cost),
        );
      }
    }

    // Sort by (year, month) and create sequential x-coordinates
    sortedPeriods = monthlyIncomeAndExpenses.keys.toList();
    sortedPeriods.sort((a, b) {
      if (a.$1 != b.$1) return a.$1.compareTo(b.$1);
      return a.$2.compareTo(b.$2);
    });

    return LineChartWidget(
      getLineBarData: (expenseProvider) {
        return [
          LineChartBarData(
            spots: sortedPeriods
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(),
                    monthlyIncomeAndExpenses[entry.value]!.item1))
                .toList(),
            color: Colors.green,
            belowBarData: BarAreaData(
                show: true, color: Colors.green.withValues(alpha: 0.3)),
            dotData: FlDotData(show: false),
          ),
          LineChartBarData(
            spots: sortedPeriods
                .asMap()
                .entries
                .map((entry) => FlSpot(entry.key.toDouble(),
                    monthlyIncomeAndExpenses[entry.value]!.item2))
                .toList(),
            color: Colors.red,
            belowBarData: BarAreaData(
                show: true, color: Colors.red.withValues(alpha: 0.3)),
            dotData: FlDotData(show: false),
          ),
        ];
      },
      leftTitleWidgets: (double value, TitleMeta meta) {
        if (value % 5000 != 0) {
          return Container();
        }
        return SideTitleWidget(
          meta: meta,
          child: Text(
            compactCurrencyFormatter.format(value),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );
      },
      bottomTitleWidgets: (double value, TitleMeta meta) {
        final index = value.toInt();
        if (index < 0 || index >= sortedPeriods.length) {
          return Container();
        }
        final (year, month) = sortedPeriods[index];
        final text = DateFormat('MMM').format(DateTime(year, month));

        return SideTitleWidget(
          meta: meta,
          space: 4,
          child: Text(text,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              )),
        );
      },
      getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
        return touchedBarSpots.map((barSpot) {
          final index = barSpot.x.toInt();
          if (index < 0 || index >= sortedPeriods.length) {
            return null;
          }
          final (year, month) = sortedPeriods[index];

          return LineTooltipItem(
            barSpot.barIndex == 0
                ? DateFormat('MMM yyyy').format(DateTime(year, month))
                : '',
            const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
            children: [
              TextSpan(
                text:
                    '\n${barSpot.barIndex == 0 ? 'Income' : 'Expenses'}: ${simpleCurrencyFormatter.format(barSpot.y)}',
                style: TextStyle(
                  color: barSpot.bar.color,
                  fontSize: 12,
                ),
              ),
            ],
          );
        }).toList()
          // Sort such that tooltips with the month title always appear first
          ..sort((a, b) {
            if (a == null) return 1;
            if (b == null) return -1;
            if (a.text.isNotEmpty) {
              return -1;
            } else if (b.text.isNotEmpty) {
              return 1;
            }
            return 0;
          });
      },
    );
  }
}
