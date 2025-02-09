import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:expense_manager/components/expense_form/constants.dart';
import 'package:expense_manager/components/form_helpers/form_dropdown_add_option.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/utils/logger/logger.dart';
import 'package:expense_manager/components/form_helpers/date_picker.dart';
import 'package:expense_manager/components/form_helpers/form_dropdown.dart';
import 'package:expense_manager/components/form_helpers/form_field.dart';
import 'package:expense_manager/utils/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pattern_formatter/date_formatter.dart';
import 'package:provider/provider.dart';

class ExpenseForm extends StatefulWidget {
  final Map<String, TextEditingController> controllerMap;
  final Future Function(ExpenseData e) onSubmit;
  final Function() onSuccess;
  final Function() onError;

  const ExpenseForm(
      {super.key,
      required this.controllerMap,
      required this.onSubmit,
      required this.onSuccess,
      required this.onError});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
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
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return Scaffold(
      body: SingleChildScrollView(
          child: Form(
              key: _formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // Date field
                  Row(children: [
                    Expanded(
                      child: CustomFormField(
                        keyboardType: TextInputType.datetime,
                        inputFormatter: DateInputFormatter(),
                        controller:
                            widget.controllerMap[dateTextFormFieldLabel]!,
                        labelText: dateTextFormFieldLabel,
                        hintText: dateTextFormFieldHint,
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
                    CustomDatePicker(
                        initialDate: DateTime.now(),
                        onDateSelected: (date) {
                          widget.controllerMap[dateTextFormFieldLabel]!.text =
                              DateFormat.yMd().format(date);
                        }),
                  ]),
                  const SizedBox(height: 35),
                  // Cost field
                  CustomFormField(
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatter: CurrencyTextInputFormatter.simpleCurrency(
                        enableNegative: false),
                    controller: widget.controllerMap[amountTextFormFieldLabel]!,
                    labelText: amountTextFormFieldLabel,
                    hintText: amountTextFormFieldHint,
                    validator: checkEmptyInput,
                  ),
                  const SizedBox(height: 35),
                  // Description field
                  CustomFormField(
                    keyboardType: TextInputType.text,
                    inputFormatter:
                        FilteringTextInputFormatter.singleLineFormatter,
                    controller:
                        widget.controllerMap[descriptionTextFormFieldLabel]!,
                    labelText: descriptionTextFormFieldLabel,
                    hintText: descriptionTextFormFieldHint,
                    validator: checkEmptyInput,
                  ),
                  const SizedBox(height: 35),
                  // Category field
                  CustomFormDropdown(
                    options: expenseProvider.categoryOptions,
                    labelText: categoryTextFormFieldLabel,
                    controller:
                        widget.controllerMap[categoryTextFormFieldLabel]!,
                    validator: checkEmptyInput,
                    hintText: categoryTextFormFieldHint,
                    addOption: getAddOptionDropdownItem(
                        'add_new_category', 'Add new category'),
                    onAddOptionSelect: () => showAddDialog(
                      context,
                      'Add Category',
                      'Enter value for new category',
                      (category) => expenseProvider.addCategory(category),
                      () => showSnackBar(
                        context,
                        'Failed to add category :(',
                        SnackBarColor.error,
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  // Owner field
                  CustomFormDropdown(
                    options: expenseProvider.ownerOptions,
                    labelText: personTextFormFieldLabel,
                    controller: widget.controllerMap[personTextFormFieldLabel]!,
                    validator: checkEmptyInput,
                    hintText: personTextFormFieldHint,
                    addOption: getAddOptionDropdownItem(
                        'add_new_owner', 'Add new owner'),
                    onAddOptionSelect: () => showAddDialog(
                      context,
                      'Add Owner',
                      'Enter value for new owner',
                      (owner) => expenseProvider.addOwner(owner),
                      () => showSnackBar(
                        context,
                        'Failed to add owner :(',
                        SnackBarColor.error,
                      ),
                    ),
                  ),
                ],
              ))),
      bottomSheet: ElevatedButton(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(200, 50),
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
                description:
                    widget.controllerMap[descriptionTextFormFieldLabel]!.text,
                cost: double.parse(widget
                    .controllerMap[amountTextFormFieldLabel]!.text
                    .replaceFirst("\$", "")
                    .replaceAll(",", "")),
                date: DateFormat('M/d/yyyy')
                    .parse(widget.controllerMap[dateTextFormFieldLabel]!.text),
                category:
                    widget.controllerMap[categoryTextFormFieldLabel]!.text,
                person: widget.controllerMap[personTextFormFieldLabel]!.text,
              );

              widget.onSubmit(expense).then((res) {
                widget.onSuccess();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }).catchError((error) {
                logger.e(error);
                widget.onError();
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
            fontSize: 20,
            color: isSubmitting
                ? theme.colorScheme.inversePrimary
                : theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
