import 'package:data_table_2/data_table_2.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/data_sources/expense_data_source.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
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
    int rowsPerPage = 10;

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

    return SafeArea(
        child: Padding(
      padding: const EdgeInsets.all(5),
      child: PaginatedDataTable2(
        source: ExpenseDataSource(context),
        sortColumnIndex: sortColumnIndex,
        sortAscending: sortAscending,
        sortArrowIcon: Icons.keyboard_arrow_up,
        sortArrowAnimationDuration: const Duration(milliseconds: 500),
        scrollController: controller,
        horizontalScrollController: horizontalController,
        minWidth: 900,
        isVerticalScrollBarVisible: true,
        isHorizontalScrollBarVisible: true,
        availableRowsPerPage: const [10, 50],
        rowsPerPage: rowsPerPage,
        onRowsPerPageChanged: (int? value) {
          setState(() {
            rowsPerPage = value ?? rowsPerPage;
          });
        },
        columnSpacing: 0,
        renderEmptyRowsInTheEnd: false,
        empty: Center(
            child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    border: Border.all(
                        width: 2.0,
                        color: Theme.of(context).colorScheme.primary),
                    borderRadius: BorderRadius.circular(10)),
                child: const Text('No data'))),
        columns: [
          DataColumn2(
            label: const Text('Date'),
            size: ColumnSize.S,
            onSort: (columnIndex, ascending) =>
                sort<DateTime>((d) => d.date, columnIndex, ascending),
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
      ),
    ));
  }
}
