import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/dashboard_widgets/helpers/bar_chart.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class ExpenseVsIncomeBarChart extends DashboardWidget {
  @override
  Widget getWidget() {
    return _ExpenseVsIncomeBarChartContent();
  }
}

class _ExpenseVsIncomeBarChartContent extends StatefulWidget {
  const _ExpenseVsIncomeBarChartContent();

  @override
  State<_ExpenseVsIncomeBarChartContent> createState() =>
      _ExpenseVsIncomeBarChartContentState();
}

class _ExpenseVsIncomeBarChartContentState
    extends State<_ExpenseVsIncomeBarChartContent> {
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

    return BarChartWidget(
      getBarChartGroupData: (expenseProvider) {
        return sortedPeriods.asMap().entries.map((entry) {
          final index = entry.key;
          final period = entry.value;
          return BarChartGroupData(x: index, barsSpace: 4, barRods: [
            BarChartRodData(
              toY: monthlyIncomeAndExpenses[period]!.item1,
              color: Colors.green,
              width: 7,
            ),
            BarChartRodData(
              toY: monthlyIncomeAndExpenses[period]!.item2,
              color: Colors.red,
              width: 7,
            ),
          ]);
        }).toList();
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
      getTooltipItems: (group, groupIndex, rod, rodIndex) {
        if (groupIndex < 0 || groupIndex >= sortedPeriods.length) {
          return null;
        }
        final (year, month) = sortedPeriods[groupIndex];
        return BarTooltipItem(
            "${DateFormat('MMM yyyy').format(DateTime(year, month))} ${rodIndex == 0 ? 'Income' : 'Expenses'}\n",
            TextStyle(
              color: rod.color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
            children: [
              TextSpan(
                  text: simpleCurrencyFormatter.format(rod.toY),
                  style: TextStyle(
                    color: rod.color,
                    fontSize: 12,
                  )),
            ]);
      },
    );
  }
}
