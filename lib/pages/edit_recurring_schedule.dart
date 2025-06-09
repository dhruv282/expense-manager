import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:expense_manager/components/expense_form/constants.dart';
import 'package:expense_manager/components/form_helpers/form_dropdown.dart';
import 'package:expense_manager/components/form_helpers/form_dropdown_add_option.dart';
import 'package:expense_manager/components/form_helpers/form_field.dart';
import 'package:expense_manager/components/recurring_schedule_form/recurring_schedule_form.dart';
import 'package:expense_manager/data/recurring_schedule.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/utils/logger/logger.dart';
import 'package:expense_manager/utils/snackbar/snackbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:rrule/rrule.dart';

class EditRecurringSchedule extends StatefulWidget {
  final RecurringSchedule schedule;

  const EditRecurringSchedule({super.key, required this.schedule});

  @override
  State<EditRecurringSchedule> createState() => _EditRecurringScheduleState();
}

class _EditRecurringScheduleState extends State<EditRecurringSchedule> {
  final _formKey = GlobalKey<FormState>();
  final formFieldSpacing = const SizedBox(height: 20);
  var isSubmitting = false;
  final Map<String, dynamic> reccurenceRuleJson = {};
  Map<String, TextEditingController> formControllerMap = {
    amountTextFormFieldLabel: TextEditingController(),
    descriptionTextFormFieldLabel: TextEditingController(),
    categoryTextFormFieldLabel: TextEditingController(),
  };
  var recurrenceScheduleAutoConfirm = false;

  String? checkEmptyInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    formControllerMap[amountTextFormFieldLabel]?.text =
        widget.schedule.cost.toString();
    formControllerMap[descriptionTextFormFieldLabel]?.text =
        widget.schedule.description;
    formControllerMap[categoryTextFormFieldLabel]?.text =
        widget.schedule.category;
    reccurenceRuleJson.addAll(
        RecurrenceRule.fromString(widget.schedule.recurrenceRule).toJson());
    recurrenceScheduleAutoConfirm = widget.schedule.autoConfirm;
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final theme = Theme.of(context);
    return Scaffold(
        body: SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Edit Recurring Schedule"),
          actions: [
            IconButton(
              icon: Icon(
                Icons.delete,
                color: Colors.redAccent,
              ),
              onPressed: () => showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => AlertDialog(
                        title: const Text('Delete Recurring Schedule'),
                        content: const Text(
                            'Are you sure you want to delete this schedule?'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                              onPressed: () {
                                expenseProvider
                                    .deleteRecurringSchedule(widget.schedule)
                                    .then((_) {
                                  if (!context.mounted) return;
                                  showSnackBar(
                                    context,
                                    'Recurring Schedule deleted!',
                                    SnackBarColor.success,
                                  );
                                  Navigator.of(context).pop();
                                }).catchError((e) {
                                  logger.e(e);
                                  if (!context.mounted) return;
                                  showSnackBar(
                                    context,
                                    'Failed to delete recurring schedule :(',
                                    SnackBarColor.error,
                                  );
                                }).whenComplete(() {
                                  if (!context.mounted) return;
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Text('Delete')),
                        ],
                      )),
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Padding(
                padding: EdgeInsets.only(bottom: 80),
                child: Form(
                  key: _formKey,
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        // Cost field
                        CustomFormField(
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                          inputFormatter:
                              CurrencyTextInputFormatter.simpleCurrency(
                                  enableNegative: false),
                          controller:
                              formControllerMap[amountTextFormFieldLabel]!,
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
                          controller:
                              formControllerMap[descriptionTextFormFieldLabel]!,
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
                              formControllerMap[categoryTextFormFieldLabel]!,
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
                        RecurringScheduleForm(
                          recurrenceRuleJson: reccurenceRuleJson,
                          autoConfirm: recurrenceScheduleAutoConfirm,
                          onAutoConfirmChanged: (value) {
                            setState(() {
                              recurrenceScheduleAutoConfirm = value;
                            });
                          },
                        ),
                      ]),
                )),
          ),
        ),
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
              if (_formKey.currentState!.validate()) {
                void submit() {
                  RecurringSchedule recurringSchedule = RecurringSchedule(
                    id: widget.schedule.id,
                    lastExecuted: widget.schedule.lastExecuted,
                    description:
                        formControllerMap[descriptionTextFormFieldLabel]!.text,
                    cost: double.parse(
                        formControllerMap[amountTextFormFieldLabel]!
                            .text
                            .replaceFirst("\$", "")
                            .replaceAll(",", "")),
                    category:
                        formControllerMap[categoryTextFormFieldLabel]!.text,
                    autoConfirm: recurrenceScheduleAutoConfirm,
                    recurrenceRule:
                        RecurrenceRule.fromJson(reccurenceRuleJson).toString(),
                  );
                  expenseProvider
                      .updateRecurringSchedule(recurringSchedule)
                      .then((_) {
                    if (!context.mounted) return;
                    showSnackBar(
                      context,
                      'Recurring Schedule updated!',
                      SnackBarColor.success,
                    );
                    Navigator.pop(context);
                  }).catchError((e) {
                    logger.e(e);
                    if (!context.mounted) return;
                    showSnackBar(
                      context,
                      'Failed to update recurring schedule :(',
                      SnackBarColor.error,
                    );
                  });
                }

                if (expenseProvider.pendingTransactions.keys
                    .map((e) => e.id)
                    .contains(widget.schedule.id)) {
                  showDialog(
                      context: context,
                      builder: (c) => AlertDialog(
                            title: Text('Are you sure?'),
                            content: Text(
                                'All currently pending transactions from this schedule will be lost.'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Text('Cancel')),
                              FilledButton(
                                  onPressed: () {
                                    submit();
                                  },
                                  child: Text('Continue')),
                            ],
                          ));
                } else {
                  submit();
                }
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
    ));
  }
}
