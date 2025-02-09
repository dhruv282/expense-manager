import 'package:data_table_2/data_table_2.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/pages/edit_expense.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/utils/logger/logger.dart';
import 'package:expense_manager/utils/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpenseDataSource extends DataTableSource {
  final BuildContext context;
  final List<ExpenseData> _expenseData;

  ExpenseDataSource(this.context, this._expenseData);

  @override
  DataRow2? getRow(int index) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    ExpenseData expense = _expenseData[index];
    return DataRow2(
      cells: <DataCell>[
        DataCell(Text(DateFormat('MM/dd/yyyy').format(expense.date))),
        DataCell(Text(expense.description)),
        DataCell(Text(expense.category)),
        DataCell(Text(expense.person)),
        DataCell(Text(NumberFormat.simpleCurrency().format(expense.cost))),
      ],
      onDoubleTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditExpensePage(expense: expense))),
      onLongPress: () => showDialog<void>(
          context: context,
          barrierDismissible: true,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Delete Expense'),
              content: const Text('Are you sure?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    expenseProvider.deleteExpense(expense).then((_) {
                      if (!context.mounted) return;
                      showSnackBar(
                        context,
                        'Expense deleted!',
                        SnackBarColor.success,
                      );
                      Navigator.of(context).pop();
                    }).catchError((e) {
                      logger.e(e);
                      if (!context.mounted) return;
                      showSnackBar(
                        context,
                        'Failed to delete expense :(',
                        SnackBarColor.error,
                      );
                    });
                  },
                  child: const Text(
                    'Delete',
                    selectionColor: Color.fromARGB(255, 95, 0, 0),
                  ),
                ),
              ],
            );
          }),
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => _expenseData.length;

  @override
  int get selectedRowCount => 0;
}
