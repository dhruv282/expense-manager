import 'package:expense_manager/pages/edit_recurring_schedule.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RecurringTransactions extends StatefulWidget {
  const RecurringTransactions({super.key});

  @override
  State<StatefulWidget> createState() => _RecurringTransactionsState();
}

class _RecurringTransactionsState extends State<RecurringTransactions> {
  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return Scaffold(
        appBar: AppBar(title: const Text('Recurring Transactions')),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: ListView(
              children: expenseProvider.recurringSchedules.map((schedule) {
            return Card(
                child: ListTile(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
              title: Text(
                schedule.category,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                  spacing: 5,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(schedule.description),
                    Text(
                      expenseProvider
                          .recurrenceRuleToText(schedule.recurrenceRule),
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.primary),
                    ),
                  ]),
              trailing: Text("\$${schedule.cost.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: expenseProvider.isIncome(schedule.category)
                        ? Color.fromARGB(255, 0, 190, 0)
                        : Color.fromARGB(255, 190, 0, 0),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  )),
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            EditRecurringSchedule(schedule: schedule)));
              },
            ));
          }).toList()),
        ));
  }
}
