import 'package:data_table_2/data_table_2.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/utils/logger/logger.dart';
import 'package:expense_manager/pages/edit_expense.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  bool sortAscending = true;
  int? sortColumnIndex;
  final ScrollController controller = ScrollController();
  final ScrollController horizontalController = ScrollController();

  @override
  void dispose() {
    controller.dispose();
    horizontalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    void sort<T>(
      Comparable<T> Function(ExpenseData d) getField,
      int columnIndex,
      bool ascending,
    ) {
      expenseProvider.sort(getField, ascending);
      setState(() {
        sortColumnIndex = columnIndex;
        sortAscending = ascending;
      });
    }

    List<DataRow2> generateDataRows() {
      List<DataRow2> dataRows = [];
      for (var e in expenseProvider.expenses) {
        dataRows.add(DataRow2(
          cells: <DataCell>[
            DataCell(Text(DateFormat('MM/dd/yyyy').format(e.date))),
            DataCell(Text(e.description)),
            DataCell(Text(e.category)),
            DataCell(Text(e.person)),
            DataCell(Text(NumberFormat.simpleCurrency().format(e.cost))),
          ],
          onDoubleTap: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => EditExpensePage(expense: e))),
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
                        expenseProvider.deleteExpense(e).then((_) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Expense deleted!'),
                              backgroundColor: Color.fromARGB(255, 0, 95, 0),
                            ),
                          );
                          Navigator.of(context).pop();
                        }).catchError((e) {
                          logger.e(e);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Failed to delete expense :('),
                              backgroundColor: Color.fromARGB(255, 95, 0, 0),
                            ),
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
        ));
      }
      return dataRows;
    }

    return SafeArea(
        child: Padding(
            padding: const EdgeInsets.all(16),
            child: Theme(
                data: ThemeData(
                    iconTheme: const IconThemeData(color: Colors.white),
                    scrollbarTheme: ScrollbarThemeData(
                      thickness: WidgetStateProperty.all(5),
                    )),
                child: DataTable2(
                    showBottomBorder: true,
                    sortColumnIndex: sortColumnIndex,
                    sortAscending: sortAscending,
                    sortArrowIcon: Icons.keyboard_arrow_up,
                    sortArrowAnimationDuration:
                        const Duration(milliseconds: 500),
                    scrollController: controller,
                    horizontalScrollController: horizontalController,
                    minWidth: 900,
                    isVerticalScrollBarVisible: true,
                    isHorizontalScrollBarVisible: true,
                    empty: Center(
                        child: Container(
                            padding: const EdgeInsets.all(20),
                            color: Colors.grey[200],
                            child: const Text('No data'))),
                    columns: [
                      DataColumn2(
                        label: const Text('Date'),
                        size: ColumnSize.S,
                        onSort: (columnIndex, ascending) => sort<DateTime>(
                            (d) => d.date, columnIndex, ascending),
                      ),
                      DataColumn2(
                        label: const Text('Description'),
                        size: ColumnSize.S,
                        onSort: (columnIndex, ascending) => sort<String>(
                            (d) => d.description, columnIndex, ascending),
                      ),
                      DataColumn2(
                        label: const Text('Category'),
                        size: ColumnSize.S,
                        onSort: (columnIndex, ascending) => sort<String>(
                            (d) => d.category, columnIndex, ascending),
                      ),
                      DataColumn2(
                        label: const Text('Owner'),
                        size: ColumnSize.S,
                        onSort: (columnIndex, ascending) => sort<String>(
                            (d) => d.person, columnIndex, ascending),
                      ),
                      DataColumn2(
                        label: const Text('Cost'),
                        size: ColumnSize.S,
                        numeric: true,
                        onSort: (columnIndex, ascending) =>
                            sort<num>((d) => d.cost, columnIndex, ascending),
                      ),
                    ],
                    rows: generateDataRows()))));
  }
}
