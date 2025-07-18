import 'package:expense_manager/pages/edit_recurring_schedule.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class RecurringTransactions extends StatefulWidget {
  const RecurringTransactions({super.key});

  @override
  State<StatefulWidget> createState() => _RecurringTransactionsState();
}

class _RecurringTransactionsState extends State<RecurringTransactions> {
  final currencyFormatter =
      NumberFormat.simpleCurrency(name: 'USD', decimalDigits: 2);

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return Scaffold(
        appBar: AppBar(title: const Text('Recurring Transactions')),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: expenseProvider.recurringSchedules.isEmpty
              ? Center(
                  child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.primaryContainer,
                          border: Border.all(
                              width: 2.0,
                              color: Theme.of(context).colorScheme.primary),
                          borderRadius: BorderRadius.circular(10)),
                      child: const Text('No data')))
              : ListView(
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
                    trailing: Text(currencyFormatter.format(schedule.cost),
                        style: TextStyle(
                          color: expenseProvider
                              .getCategoryColor(schedule.category),
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
