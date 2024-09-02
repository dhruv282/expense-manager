import 'package:data_table_2/data_table_2.dart';
import 'package:expense_manager/data/expense_data.dart';
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
              DataCell(Text(e.date)),
              DataCell(Text(e.description)),
              DataCell(Text(e.category)),
              DataCell(Text(e.person)),
              DataCell(Text(NumberFormat.simpleCurrency().format(e.cost))),
            ],
            onDoubleTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => EditExpensePage(expense: e)))));
      }
      return dataRows;
    }

    return DataTable2(
        showBottomBorder: true,
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        sortArrowIcon: Icons.keyboard_arrow_up,
        sortArrowAnimationDuration: const Duration(milliseconds: 500),
        isVerticalScrollBarVisible: true,
        empty: Center(
            child: Container(
                padding: const EdgeInsets.all(20),
                color: Colors.grey[200],
                child: const Text('No data'))),
        columns: [
          DataColumn2(
            label: const Text('Date'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) =>
                sort<String>((d) => d.date, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Description'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) =>
                sort<String>((d) => d.description, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Category'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) =>
                sort<String>((d) => d.category, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Owner'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) =>
                sort<String>((d) => d.person, columnIndex, ascending),
          ),
          DataColumn2(
            label: const Text('Cost'),
            size: ColumnSize.S,
            numeric: true,
            onSort: (columnIndex, ascending) =>
                sort<num>((d) => d.cost, columnIndex, ascending),
          ),
        ],
        rows: generateDataRows());
  }
}
