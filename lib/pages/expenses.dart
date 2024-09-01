import 'package:data_table_2/data_table_2.dart';
import 'package:expense_manager/database_manager/database_manager.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpensePage extends StatefulWidget {
  const ExpensePage({super.key});

  @override
  State<ExpensePage> createState() => _ExpensePageState();
}

class _ExpensePageState extends State<ExpensePage> {
  var entriesLoaded = false;
  List<DataRow> expenseDataEntries = [];

  @override
  void initState() {
    super.initState();
    var dbManager = DatabaseManager();
    dbManager.executeFetchAll().then((entries) {
      for (var e in entries!) {
        expenseDataEntries.add(DataRow(
          cells: <DataCell>[
            DataCell(Text(e.date)),
            DataCell(Text(e.description)),
            DataCell(Text(e.category)),
            DataCell(Text(e.person)),
            DataCell(Text(NumberFormat.compactSimpleCurrency().format(e.cost))),
          ],
        ));
      }
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to load expenses :('),
          backgroundColor: Color.fromARGB(255, 95, 0, 0),
        ),
      );
    }).whenComplete(() {
      setState(() {
        entriesLoaded = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return entriesLoaded
        ? DataTable2(
            showBottomBorder: true,
            empty: Center(
                child: Container(
                    padding: const EdgeInsets.all(20),
                    color: Colors.grey[200],
                    child: const Text('No data'))),
            columns: const [
              DataColumn2(
                label: Text('Date'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: Text('Description'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: Text('Category'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: Text('Owner'),
                size: ColumnSize.S,
              ),
              DataColumn2(
                label: Text('Cost'),
                size: ColumnSize.S,
              ),
            ],
            sortArrowIcon: Icons.keyboard_arrow_up,
            rows: expenseDataEntries)
        : const Center(child: CircularProgressIndicator());
  }
}
