import 'package:expense_manager/components/data_table_filter/data_table_filter.dart';
import 'package:expense_manager/components/expense/expense_list_tile.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/pages/edit_expense.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  int? unfilteredExpenseDataHashCode;
  List<ExpenseData> expenseData = [];
  bool initialLoad = true;

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    if (initialLoad ||
        expenseProvider.expenses.hashCode != unfilteredExpenseDataHashCode) {
      setState(() {
        expenseData = expenseProvider.expenses;
        unfilteredExpenseDataHashCode = expenseProvider.expenses.hashCode;
        initialLoad = false;
      });
    }

    return Column(
      children: [
        SizedBox(
            height: 50,
            child: DataTableFilter(
              unFilteredData: expenseProvider.expenses,
              onFilter: (expenses) {
                setState(() {
                  expenseData = expenses;
                });
              },
            )),
        Expanded(
          child: GroupedListView(
            elements: expenseData,
            groupBy: (e) => e.date,
            order: GroupedListOrder.DESC,
            groupHeaderBuilder: (e) => Padding(
                padding: EdgeInsets.only(top: 10, left: 10, right: 10),
                child: Text(
                  DateFormat.MMMMEEEEd().format(e.date),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                )),
            itemComparator: (a, b) => a.date.compareTo(b.date),
            itemBuilder: (context, e) => ExpenseListTile(
              expense: e,
              showDate: false,
              onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => EditExpensePage(expense: e))),
            ),
          ),
        ),
      ],
    );
  }
}
