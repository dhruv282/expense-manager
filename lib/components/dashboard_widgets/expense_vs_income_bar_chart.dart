import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/dashboard_widgets/helpers/bar_chart.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

class ExpenseVsIncomeBarChart extends DashboardWidget {
  @override
  Widget getWidget() {
    final compactCurrencyFormatter =
        NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0);
    final simpleCurrencyFormatter = NumberFormat.simpleCurrency();
    return BarChartWidget(
      getBarChartGroupData: (expenseProvider) {
        final Map<int, Tuple2<double, double>> monthlyIncomeAndExpenses = {};
        for (var expense in expenseProvider.expenses) {
          if (expenseProvider.isIncome(expense.category)) {
            monthlyIncomeAndExpenses.update(
              expense.date.month,
              (tuple) => Tuple2(tuple.item1 + expense.cost, tuple.item2),
              ifAbsent: () => Tuple2(expense.cost, 0),
            );
          } else {
            monthlyIncomeAndExpenses.update(
              expense.date.month,
              (tuple) => Tuple2(tuple.item1, tuple.item2 + expense.cost),
              ifAbsent: () => Tuple2(0, expense.cost),
            );
          }
        }
        var months = monthlyIncomeAndExpenses.keys.toList();
        months.sort();
        return months
            .map((m) => BarChartGroupData(x: m, barsSpace: 4, barRods: [
                  BarChartRodData(
                    toY: monthlyIncomeAndExpenses[m]!.item1,
                    color: Colors.green,
                    width: 7,
                  ),
                  BarChartRodData(
                    toY: monthlyIncomeAndExpenses[m]!.item2,
                    color: Colors.red,
                    width: 7,
                  ),
                ]))
            .toList();
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
        var text = DateFormat('MMM').format(DateTime(0, value.toInt()));

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
      getTooltipItems: (group, groupIndex, rod, rodIndex) => BarTooltipItem(
          "${DateFormat('MMM').format(DateTime(0, group.x))} ${rodIndex == 0 ? 'Income' : 'Expenses'}\n",
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
          ]),
    );
  }
}
