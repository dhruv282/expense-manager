import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ExpenseAndIncomeSummary extends DashboardWidget {
  @override
  Widget getWidget() {
    return ExpenseAndIncomeSummaryWidget();
  }
}

class ExpenseAndIncomeSummaryWidget extends StatelessWidget {
  const ExpenseAndIncomeSummaryWidget({super.key});

  Card getCard(MaterialColor c, IconData icon, String title, double total,
          {bool isSavings = false}) =>
      Card(
        color: isSavings ? null : c.shade100,
        shape: isSavings
            ? RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(10)),
                side: BorderSide(color: c.shade500))
            : null,
        child: Padding(
          padding: EdgeInsets.all(5),
          child: Row(
            spacing: 5,
            children: [
              Icon(icon, color: c),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title,
                    style: TextStyle(
                      color: c.shade700,
                      fontWeight: FontWeight.bold,
                    )),
                Text("\$${total.toStringAsFixed(2)}",
                    style: TextStyle(
                      color: c.shade700,
                    )),
              ]),
            ],
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    var income = 0.0;
    var expenses = 0.0;
    for (var expense in expenseProvider.expenses) {
      if (expenseProvider.isIncome(expense.category)) {
        income += expense.cost;
      } else {
        expenses += expense.cost;
      }
    }
    final savings = income - expenses;

    return Card(
        child: Padding(
            padding: EdgeInsets.all(5),
            child: SingleChildScrollView(
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    spacing: 3,
                    children: [
                  getCard(Colors.green, Icons.arrow_downward, 'Income', income),
                  getCard(Colors.red, Icons.arrow_upward, 'Expenses', expenses),
                  getCard(savings >= 0.0 ? Colors.green : Colors.red,
                      Icons.savings, 'Savings', savings,
                      isSavings: true),
                ]))));
  }
}
