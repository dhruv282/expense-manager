import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:expense_manager/constants/expense_form.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/database_manager/database_manager.dart';
import 'package:expense_manager/utils/date_picker.dart';
import 'package:expense_manager/utils/form_dropdown.dart';
import 'package:expense_manager/utils/form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/date_formatter.dart';

class AddExpenseForm extends StatefulWidget {
  final Map<String, TextEditingController> controllerMap;

  const AddExpenseForm({super.key, required this.controllerMap});

  @override
  State<AddExpenseForm> createState() => _AddExpenseFormState();
}

class _AddExpenseFormState extends State<AddExpenseForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  var isSubmitting = false;

  String? checkEmptyInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Form(
        key: _formKey,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            // Date field
            Row(children: [
              Expanded(
                child: ExpenseFormField(
                  enabled: true,
                  maxCharacters: null,
                  keyboardType: TextInputType.datetime,
                  inputFormatter: DateInputFormatter(),
                  controller: widget.controllerMap[dateTextFormFieldLabel]!,
                  labelText: dateTextFormFieldLabel,
                  hintText: dateTextFormFieldHint,
                  icon: null,
                  onSaved: (value) {},
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter a valid date';
                    } else {
                      try {
                        DateFormat.yMd().parse(value).toString();

                        return null;
                      } catch (e) {
                        return 'Please enter a valid date';
                      }
                    }
                  },
                ),
              ),
              DatePicker(
                  initialDate: DateTime.now(),
                  onDateSelected: (date) {
                    widget.controllerMap[dateTextFormFieldLabel]!.text =
                        DateFormat.yMd().format(date);
                  }),
            ]),
            // Cost field
            ExpenseFormField(
              enabled: true,
              maxCharacters: null,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              inputFormatter: CurrencyTextInputFormatter.simpleCurrency(
                  enableNegative: false),
              controller: widget.controllerMap[amountTextFormFieldLabel]!,
              labelText: amountTextFormFieldLabel,
              hintText: amountTextFormFieldHint,
              icon: null,
              onSaved: (value) {},
              validator: (value) {
                return checkEmptyInput(value);
              },
            ),
            // Description field
            ExpenseFormField(
              enabled: true,
              maxCharacters: null,
              keyboardType: TextInputType.text,
              inputFormatter: FilteringTextInputFormatter.singleLineFormatter,
              controller: widget.controllerMap[descriptionTextFormFieldLabel]!,
              labelText: descriptionTextFormFieldLabel,
              hintText: descriptionTextFormFieldHint,
              icon: null,
              onSaved: (value) {},
              validator: (value) {
                return checkEmptyInput(value);
              },
            ),
            // Category field
            ExpenseFormDropdown(
              options: expenseCategories,
              labelText: categoryTextFormFieldLabel,
              controller: widget.controllerMap[categoryTextFormFieldLabel]!,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select a value';
                }
                return null;
              },
              hintText: categoryTextFormFieldHint,
              icon: null,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: isSubmitting
                    ? theme.colorScheme.primary
                    : theme.colorScheme.inversePrimary,
              ),
              onPressed: () {
                // Ignore button presses with ongoing submit operation.
                if (!isSubmitting) {
                  setState(() {
                    isSubmitting = true;
                  });
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    ExpenseData expense = ExpenseData(
                      description: widget
                          .controllerMap[descriptionTextFormFieldLabel]!.text,
                      cost: double.parse(widget
                          .controllerMap[amountTextFormFieldLabel]!.text
                          .replaceFirst("\$", "")
                          .replaceAll(",", "")),
                      date: widget.controllerMap[dateTextFormFieldLabel]!.text,
                      category: widget
                          .controllerMap[categoryTextFormFieldLabel]!.text,
                      person:
                          widget.controllerMap[personTextFormFieldLabel]!.text,
                    );

                    var dbManager = DatabaseManager();
                    dbManager.executeInsert(expense).then((res) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Expense added!'),
                          backgroundColor: Color.fromARGB(255, 0, 95, 0),
                        ),
                      );
                      Navigator.pop(context);
                    }).catchError((error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Failed to add expense :('),
                          backgroundColor: Color.fromARGB(255, 95, 0, 0),
                        ),
                      );
                    }).whenComplete(() {
                      setState(() {
                        isSubmitting = false;
                      });
                    });
                  }
                }
              },
              child: Text(
                'Submit',
                style: TextStyle(
                  color: isSubmitting
                      ? theme.colorScheme.inversePrimary
                      : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ));
  }
}
