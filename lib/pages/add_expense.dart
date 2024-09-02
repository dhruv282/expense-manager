import 'package:expense_manager/components/expense_form.dart';
import 'package:expense_manager/constants/expense_form.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/database_manager/database_manager.dart';
import 'package:flutter/material.dart';

class AddExpensePage extends StatefulWidget {
  const AddExpensePage({super.key});

  @override
  State<AddExpensePage> createState() => _AddExpensePageState();
}

class _AddExpensePageState extends State<AddExpensePage> {
  Map<String, TextEditingController> formControllerMap = {
    amountTextFormFieldLabel: TextEditingController(),
    descriptionTextFormFieldLabel: TextEditingController(),
    categoryTextFormFieldLabel: TextEditingController(),
    dateTextFormFieldLabel: TextEditingController(),
    personTextFormFieldLabel: TextEditingController(),
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back))
          ],
          title: const Text("Add Expense"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ExpenseForm(
            controllerMap: formControllerMap,
            onSubmit: (ExpenseData e) {
              var dbManager = DatabaseManager();
              return dbManager.executeInsert(e);
            },
            onSuccess: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Expense added!'),
                  backgroundColor: Color.fromARGB(255, 0, 95, 0),
                ),
              );
            },
            onError: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Failed to add expense :('),
                  backgroundColor: Color.fromARGB(255, 95, 0, 0),
                ),
              );
            },
          ),
        ));
  }
}
