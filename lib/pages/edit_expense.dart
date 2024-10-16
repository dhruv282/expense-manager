import 'package:expense_manager/components/expense_form/expense_form.dart';
import 'package:expense_manager/components/expense_form/constants.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/utils/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class EditExpensePage extends StatefulWidget {
  final ExpenseData expense;
  const EditExpensePage({super.key, required this.expense});

  @override
  State<EditExpensePage> createState() => _EditExpensePageState();
}

class _EditExpensePageState extends State<EditExpensePage> {
  Map<String, TextEditingController> formControllerMap = {
    amountTextFormFieldLabel: TextEditingController(),
    descriptionTextFormFieldLabel: TextEditingController(),
    categoryTextFormFieldLabel: TextEditingController(),
    dateTextFormFieldLabel: TextEditingController(),
    personTextFormFieldLabel: TextEditingController(),
  };

  @override
  void initState() {
    super.initState();
    formControllerMap[amountTextFormFieldLabel]?.text =
        widget.expense.cost.toString();
    formControllerMap[descriptionTextFormFieldLabel]?.text =
        widget.expense.description;
    formControllerMap[categoryTextFormFieldLabel]?.text =
        widget.expense.category;
    formControllerMap[dateTextFormFieldLabel]?.text =
        DateFormat('MM/dd/yyyy').format(widget.expense.date);
    formControllerMap[personTextFormFieldLabel]?.text = widget.expense.person;
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text("Edit Expense"),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ExpenseForm(
            controllerMap: formControllerMap,
            onSubmit: (ExpenseData e) {
              // Add expense ID for a successful update.
              e.id = widget.expense.id;
              return expenseProvider.updateExpense(e);
            },
            onSuccess: () {
              showSnackBar(context, 'Expense updated!', SnackBarColor.success);
            },
            onError: () {
              showSnackBar(
                  context, 'Failed to update expense :(', SnackBarColor.error);
            },
          ),
        ));
  }
}
