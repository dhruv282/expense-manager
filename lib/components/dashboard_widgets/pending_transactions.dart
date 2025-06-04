import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/utils/logger/logger.dart';
import 'package:expense_manager/utils/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PendingTransactions extends DashboardWidget {
  @override
  Widget getWidget() {
    return PendingTransactionsWidget();
  }
}

class PendingTransactionsWidget extends StatefulWidget {
  const PendingTransactionsWidget({super.key});

  @override
  State<PendingTransactionsWidget> createState() =>
      _PendingTransactionsWidgetState();
}

class _PendingTransactionsWidgetState extends State<PendingTransactionsWidget> {
  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(5),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: EdgeInsets.only(top: 5, left: 10, right: 10),
            child: Row(spacing: 5, children: [
              Icon(Icons.schedule,
                  color: Theme.of(context).colorScheme.primary),
              Text(
                'Pending Transactions',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              )
            ]),
          ),
          Divider(
            color: Theme.of(context).colorScheme.primary,
            thickness: 3,
          ),
          Expanded(
              child: ListView(
            children: expenseProvider.pendingTransactions.entries
                .map((m) => m.value.map((e) => Card(
                      child: ListTile(
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: Theme.of(context)
                                  .colorScheme
                                  .primary
                                  .withAlpha(75),
                              width: 1,
                            )),
                        title: Text(
                          e.category,
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(e.description),
                              Text(
                                DateFormat.yMMMd().format(e.date),
                                style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ]),
                        trailing: Text("\$${e.cost.toStringAsFixed(2)}",
                            style: TextStyle(
                              color: expenseProvider.isIncome(e.category)
                                  ? Color.fromARGB(255, 0, 190, 0)
                                  : Color.fromARGB(255, 190, 0, 0),
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            )),
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: Text('Pending Transaction'),
                              content:
                                  Text('Add this transaction to your records?'),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    expenseProvider
                                        .triggerRecurringScheduleRule(
                                            m.key, e, true)
                                        .then((_) {
                                      if (!context.mounted) return;
                                      Navigator.of(context).pop();
                                    }).catchError((e) {
                                      logger.e(e);
                                    });
                                  },
                                  child: const Text('Skip'),
                                ),
                                FilledButton(
                                    onPressed: () {
                                      expenseProvider
                                          .triggerRecurringScheduleRule(
                                              m.key, e, false)
                                          .then((v) {
                                        if (!context.mounted) return;
                                        Navigator.of(context).pop();
                                        showSnackBar(
                                          context,
                                          'Transaction added successfully!',
                                          SnackBarColor.success,
                                        );
                                      }).catchError((e) {
                                        logger.e(e);
                                        if (!context.mounted) return;
                                        showSnackBar(
                                            context,
                                            'Failed to add transaction',
                                            SnackBarColor.error);
                                      });
                                    },
                                    child: Text('Add')),
                              ]),
                        ),
                      ),
                    )))
                .expand((w) => w)
                .toList(),
          ))
        ]),
      ),
    );
  }
}
