import 'package:expense_manager/components/add_expense/add_expense_form.dart';
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
        body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: AddExpenseForm(
        controllerMap: formControllerMap,
      ),
    ));
  }
}
