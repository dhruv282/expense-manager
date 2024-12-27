import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/dashboard_widgets/helpers/line_chart.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tuple/tuple.dart';

class ExpenseVsIncomeLineChart extends DashboardWidget {
  @override
  Widget getWidget() {
    final compactCurrencyFormatter =
        NumberFormat.compactCurrency(symbol: '\$', decimalDigits: 0);
    final simpleCurrencyFormatter = NumberFormat.simpleCurrency();
    return LineChartWidget(
      getLineBarData: (List<ExpenseData> expenses) {
        final Map<int, Tuple2<double, double>> monthlyIncomeAndExpenses = {};
        for (var expense in expenses) {
          if (expense.category == "Income") {
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
        return [
          LineChartBarData(
            spots: months
                .map((m) =>
                    FlSpot(m.toDouble(), monthlyIncomeAndExpenses[m]!.item1))
                .toList(),
            color: Colors.green,
            belowBarData:
                BarAreaData(show: true, color: Colors.green.withOpacity(0.3)),
          ),
          LineChartBarData(
            spots: months
                .map((m) =>
                    FlSpot(m.toDouble(), monthlyIncomeAndExpenses[m]!.item2))
                .toList(),
            color: Colors.red,
            belowBarData:
                BarAreaData(show: true, color: Colors.red.withOpacity(0.3)),
          ),
        ];
      },
      leftTitleWidgets: (double value, TitleMeta meta) {
        if (value % 5000 != 0) {
          return Container();
        }
        return SideTitleWidget(
          axisSide: meta.axisSide,
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
          axisSide: meta.axisSide,
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
          return LineTooltipItem(
            barSpot.barIndex == 0
                ? DateFormat('MMM').format(DateTime(0, barSpot.x.toInt()))
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
