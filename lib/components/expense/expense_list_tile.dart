import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpenseListTile extends StatelessWidget {
  final ExpenseData expense;
  final VoidCallback? onTap;
  final bool showDate;
  final currencyFormatter =
      NumberFormat.simpleCurrency(name: 'USD', decimalDigits: 2);

  ExpenseListTile({
    super.key,
    required this.expense,
    this.onTap,
    this.showDate = true,
  });

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return Card(
      child: ListTile(
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
            side: BorderSide(
              color: Theme.of(context).colorScheme.primary.withAlpha(75),
              width: 1,
            )),
        title: Text(
          expense.category,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle:
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(expense.description),
          if (showDate)
            Text(
              DateFormat.yMMMd().format(expense.date),
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
        ]),
        trailing: Text(currencyFormatter.format(expense.cost),
            style: TextStyle(
              color: expenseProvider.getCategoryColor(expense.category),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            )),
        onTap: onTap,
      ),
    );
  }
}
