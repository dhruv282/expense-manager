import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:expense_manager/components/expense_form/constants.dart';
import 'package:expense_manager/components/form_helpers/form_dropdown_add_option.dart';
import 'package:expense_manager/components/recurring_schedule_form/recurring_schedule_form.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/data/recurring_schedule.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/utils/logger/logger.dart';
import 'package:expense_manager/components/form_helpers/date_picker.dart';
import 'package:expense_manager/components/form_helpers/form_dropdown.dart';
import 'package:expense_manager/components/form_helpers/form_field.dart';
import 'package:expense_manager/utils/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:rrule/rrule.dart';

class ExpenseForm extends StatefulWidget {
  final Map<String, TextEditingController> controllerMap;
  final RecurrenceRule? recurrenceRule;
  final Future Function(ExpenseData e, RecurringSchedule? s) onSubmit;
  final Function() onSuccess;
  final Function() onError;

  const ExpenseForm({
    super.key,
    required this.controllerMap,
    this.recurrenceRule,
    required this.onSubmit,
    required this.onSuccess,
    required this.onError,
  });

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
  final formFieldSpacing = const SizedBox(height: 20);
  var isSubmitting = false;
  var recurringTransaction = false;
  final Map<String, dynamic> reccurenceRuleJson = {};
  var recurrenceRuleAutoConfirm = false;

  String? checkEmptyInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    if (widget.recurrenceRule != null) {
      reccurenceRuleJson.addAll(widget.recurrenceRule!.toJson());
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return SafeArea(
      child: Scaffold(
        body: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.only(bottom: 80),
                child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Date field
                        CustomDatePicker(
                            initialDate: DateFormat('MM/dd/yyyy').parse(widget
                                .controllerMap[dateTextFormFieldLabel]!.text),
                            onDateSelected: (date) {
                              widget.controllerMap[dateTextFormFieldLabel]!
                                  .text = DateFormat.yMd().format(date);
                            }),
                        formFieldSpacing,
                        // Cost field
                        CustomFormField(
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatter:
                              CurrencyTextInputFormatter.simpleCurrency(
                                  enableNegative: false),
                          controller:
                              widget.controllerMap[amountTextFormFieldLabel]!,
                          labelText: amountTextFormFieldLabel,
                          hintText: amountTextFormFieldHint,
                          validator: checkEmptyInput,
                        ),
                        formFieldSpacing,
                        // Description field
                        CustomFormField(
                          keyboardType: TextInputType.text,
                          inputFormatter:
                              FilteringTextInputFormatter.singleLineFormatter,
                          controller: widget
                              .controllerMap[descriptionTextFormFieldLabel]!,
                          textCapitalization: TextCapitalization.words,
                          labelText: descriptionTextFormFieldLabel,
                          hintText: descriptionTextFormFieldHint,
                          validator: checkEmptyInput,
                        ),
                        formFieldSpacing,
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
                        const SizedBox(height: 5),
                        const Divider(),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Reccuring Transaction',
                                style: theme.textTheme.titleMedium),
                            Switch(
                              value: recurringTransaction,
                              onChanged: (value) {
                                setState(() {
                                  recurringTransaction = value;
                                });
                              },
                            ),
                          ],
                        ),
                        if (recurringTransaction)
                          RecurringScheduleForm(
                            recurrenceRuleJson: reccurenceRuleJson,
                            autoConfirm: recurrenceRuleAutoConfirm,
                            onAutoConfirmChanged: (value) {
                              setState(() {
                                recurrenceRuleAutoConfirm = value;
                              });
                            },
                          ),
                      ],
                    )))),
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
                      widget.controllerMap[descriptionTextFormFieldLabel]!.text.trim(),
                  cost: double.parse(widget
                      .controllerMap[amountTextFormFieldLabel]!.text
                      .replaceFirst("\$", "")
                      .replaceAll(",", "")),
                  date: DateFormat('M/d/yyyy').parse(
                      widget.controllerMap[dateTextFormFieldLabel]!.text),
                  category:
                      widget.controllerMap[categoryTextFormFieldLabel]!.text,
                );

                RecurringSchedule? recurringSchedule;
                if (recurringTransaction) {
                  recurringSchedule = RecurringSchedule(
                    description: expense.description,
                    cost: expense.cost,
                    category: expense.category,
                    autoConfirm: recurrenceRuleAutoConfirm,
                    recurrenceRule:
                        RecurrenceRule.fromJson(reccurenceRuleJson).toString(),
                    lastExecuted: expense.date,
                  );
                }

                widget.onSubmit(expense, recurringSchedule).then((res) {
                  widget.onSuccess();
                  if (context.mounted) {
                    Navigator.pop(context);
                  }
                }).catchError((error) {
                  logger.e(error);
                  widget.onError();
                });
              }
              setState(() {
                isSubmitting = false;
              });
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
      ),
    );
  }
}
