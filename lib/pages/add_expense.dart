import 'package:expense_manager/components/expense_form.dart';
import 'package:expense_manager/constants/expense_form.dart';
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
          ),
        ));
  }
}
