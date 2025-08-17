import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/expense/expense_list_tile.dart';
import 'package:expense_manager/components/form_helpers/numeric_field.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/utils/logger/logger.dart';
import 'package:expense_manager/utils/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
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
            padding: EdgeInsets.only(top: 5, left: 10, right: 10, bottom: 5),
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
          Expanded(
              child: ListView(
            children: expenseProvider.pendingTransactions.entries
                .map((m) => m.value.map((e) {
                      final amountController =
                          TextEditingController(text: e.cost.toString());
                      return ExpenseListTile(
                        expense: e,
                        onTap: () => showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                              title: Text('Pending Transaction'),
                              content: Wrap(children: [
                                Column(
                                  children: [
                                    Text(
                                        'Add this transaction to your records?'),
                                    const SizedBox(height: 20),
                                    NumericField(
                                      controller: amountController,
                                    ),
                                  ],
                                )
                              ]),
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
                                      e.cost =
                                          double.parse(amountController.text);
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
                      );
                    }))
                .expand((w) => w)
                .toList(),
          ))
        ]),
      ),
    );
  }
}
