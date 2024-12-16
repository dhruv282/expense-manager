import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/dashboard_widgets/helpers/pie_chart.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpensePieChart extends DashboardWidget {
  @override
  Widget getWidget() {
    return PieChartWidget(
      getCategoryData: (List<ExpenseData> expenses) {
        final Map<String, double> categoryTotals = {};
        for (var expense in expenses) {
          if (expense.category != "Income") {
            categoryTotals.update(
              expense.category,
              (value) => value + expense.cost,
              ifAbsent: () => expense.cost,
            );
          }
        }
        return categoryTotals;
      },
      getDefaultLabel: (List<ExpenseData> expenses) {
        final currencyFormatter = NumberFormat.simpleCurrency();
        double expenseTotal = 0;
        for (var expense in expenses) {
          if (expense.category != "Income") {
            expenseTotal += expense.cost;
          }
        }
        return "Total\n${currencyFormatter.format(expenseTotal)}";
      },
    );
  }
}
