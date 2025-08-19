import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/dashboard_widgets/helpers/pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpensePieChart extends DashboardWidget {
  @override
  Widget getWidget() {
    return PieChartWidget(
      getCategoryData: (expenseProvider) {
        final Map<String, double> categoryTotals = {};
        for (var expense in expenseProvider.expenses) {
          if (!expenseProvider.isIncome(expense.category)) {
            categoryTotals.update(
              expense.category,
              (value) => value + expense.cost,
              ifAbsent: () => expense.cost,
            );
          }
        }
        return categoryTotals;
      },
      getDefaultLabel: (expenseProvider) {
        final currencyFormatter = NumberFormat.simpleCurrency();
        double expenseTotal = 0;
        for (var expense in expenseProvider.expenses) {
          if (!expenseProvider.isIncome(expense.category)) {
            expenseTotal += expense.cost;
          }
        }
        return "Total\n${currencyFormatter.format(expenseTotal)}";
      },
    );
  }
}
