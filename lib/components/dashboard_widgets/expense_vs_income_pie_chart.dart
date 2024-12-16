import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/dashboard_widgets/helpers/pie_chart.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseVsIncomePieChart extends DashboardWidget {
  @override
  Widget getWidget() {
    return PieChartWidget(
      getCategoryData: (List<ExpenseData> expenses) {
        final Map<String, double> totals = {};
        for (var expense in expenses) {
          if (expense.category != "Income") {
            totals.update(
              "Expenses",
              (value) => value + expense.cost,
              ifAbsent: () => expense.cost,
            );
          } else {
            totals.update(
              "Income",
              (value) => value + expense.cost,
              ifAbsent: () => expense.cost,
            );
          }
        }
        return totals;
      },
      getDefaultLabel: (List<ExpenseData> expenses) {
        final currencyFormatter = NumberFormat.simpleCurrency();
        double expenseTotal = 0;
        double incomeTotal = 0;
        for (var expense in expenses) {
          if (expense.category != "Income") {
            expenseTotal += expense.cost;
          } else {
            incomeTotal += expense.cost;
          }
        }
        return "Savings\n${currencyFormatter.format(incomeTotal - expenseTotal)}";
      },
      colorList: const [
        Colors.red,
        Colors.green,
      ],
    );
  }
}
