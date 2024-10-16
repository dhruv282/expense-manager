import 'package:expense_manager/components/expense_form/expense_form.dart';
import 'package:expense_manager/components/expense_form/constants.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/utils/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Add Expense"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ExpenseForm(
            controllerMap: formControllerMap,
            onSubmit: (ExpenseData e) => expenseProvider.addExpense(e),
            onSuccess: () {
              showSnackBar(
                context,
                'Failed to add expense :(',
                SnackBarColor.success,
              );
            },
            onError: () {
              showSnackBar(
                context,
                'Failed to add expense :(',
                SnackBarColor.error,
              );
            },
          ),
        ));
  }
}
