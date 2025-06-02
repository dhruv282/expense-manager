import 'package:expense_manager/components/form_helpers/date_picker.dart';
import 'package:expense_manager/components/form_helpers/form_dropdown.dart';
import 'package:expense_manager/components/form_helpers/form_field.dart';
import 'package:expense_manager/components/form_helpers/form_multi_dropdown.dart';
import 'package:expense_manager/components/recurring_schedule_form/constants.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:rrule/rrule.dart';

class RecurringScheduleForm extends StatefulWidget {
  final Map<String, dynamic> recurrenceRuleJson;

  const RecurringScheduleForm({
    super.key,
    required this.recurrenceRuleJson,
  });

  @override
  State<RecurringScheduleForm> createState() => _RecurringScheduleFormState();
}

class _RecurringScheduleFormState extends State<RecurringScheduleForm> {
  final formFieldSpacing = const SizedBox(height: 20);
  RruleL10n? l10n;
  String recurringRuleText = '';
  final Map<String, TextEditingController> recurranceRuleControllerMap = {
    recurringFrequencyTextFormFieldLabel:
        TextEditingController(text: 'Monthly'),
    recurringIntervalTextFormFieldLabel: TextEditingController(text: '1'),
    recurringEndsFormFieldLabel: TextEditingController(text: 'Never'),
    recurringNumOccurrencesFormFieldLabel: TextEditingController(text: '12'),
  };
  var recurrenceUntilController = DateTime.now();
  final Map<String, List<DropdownItem<String>>>
      recurrenceRuleMultiSelectValues = {
    recurringByDayFormFieldLabel: recurringDaysOfWeek.entries
        .map((e) => DropdownItem(
              label: e.key,
              value: e.value,
            ))
        .toList(),
    recurringByMonthFormFieldLabel: recurringMonths.entries
        .map((e) => DropdownItem(
              label: e.key,
              value: e.value.toString(),
            ))
        .toList(),
  };

  String? checkEmptyInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a value';
    }
    return null;
  }

  String capitalizeString(String input) {
    if (input.isEmpty) return input;
    return "${input.substring(0, 1).toUpperCase()}${input.substring(1).toLowerCase()}";
  }

  @override
  void initState() {
    super.initState();

    if (widget.recurrenceRuleJson.containsKey('freq')) {
      recurranceRuleControllerMap[recurringFrequencyTextFormFieldLabel]!.text =
          capitalizeString(widget.recurrenceRuleJson['freq']);
    } else {
      widget.recurrenceRuleJson['freq'] =
          recurranceRuleControllerMap[recurringFrequencyTextFormFieldLabel]!
              .text
              .toUpperCase();
    }

    if (widget.recurrenceRuleJson.containsKey('interval')) {
      recurranceRuleControllerMap[recurringIntervalTextFormFieldLabel]!.text =
          widget.recurrenceRuleJson['interval'].toString();
    } else {
      widget.recurrenceRuleJson['interval'] = int.tryParse(
              recurranceRuleControllerMap[recurringIntervalTextFormFieldLabel]!
                  .text) ??
          1;
    }

    if (!widget.recurrenceRuleJson.containsKey('byday')) {
      widget.recurrenceRuleJson['byday'] = [];
    }

    if (!widget.recurrenceRuleJson.containsKey('bymonth')) {
      widget.recurrenceRuleJson['bymonth'] = [];
    }

    if (widget.recurrenceRuleJson.containsKey('until')) {
      recurranceRuleControllerMap[recurringEndsFormFieldLabel]!.text = 'Until';
    } else if (widget.recurrenceRuleJson.containsKey('count')) {
      recurranceRuleControllerMap[recurringEndsFormFieldLabel]!.text = 'After';
    } else {
      recurranceRuleControllerMap[recurringEndsFormFieldLabel]!.text = 'Never';
    }

    if (widget.recurrenceRuleJson.containsKey('count')) {
      recurranceRuleControllerMap[recurringNumOccurrencesFormFieldLabel]!.text =
          widget.recurrenceRuleJson['count'].toString();
    }

    RruleL10nEn.create().then((v) {
      l10n = v;
      setState(() {
        evaluateRecurrenceRuleText();
      });
    });
  }

  void evaluateRecurrenceRuleText() {
    try {
      recurringRuleText = RecurrenceRule.fromJson(widget.recurrenceRuleJson)
          .toText(l10n: l10n!);
    } catch (e) {
      recurringRuleText = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    var isWeekly = widget.recurrenceRuleJson.containsKey('freq') &&
        widget.recurrenceRuleJson['freq'] == 'WEEKLY';
    var isMonthly = widget.recurrenceRuleJson.containsKey('freq') &&
        widget.recurrenceRuleJson['freq'] == 'MONTHLY';
    List<Widget> conditionalWidgets = [];
    if (isWeekly) {
      conditionalWidgets.addAll([
        CustomFormMultiDropdown(
            key: const Key(recurringByDayFormFieldLabel),
            labelText: recurringByDayFormFieldLabel,
            options:
                recurrenceRuleMultiSelectValues[recurringByDayFormFieldLabel]!
                    .map((i) => DropdownItem(
                        label: i.label,
                        value: i.value,
                        selected: widget.recurrenceRuleJson['byday']
                            .contains(i.value)))
                    .toList(),
            onChanged: (v) {
              setState(() {
                widget.recurrenceRuleJson['byday'] = v;
                evaluateRecurrenceRuleText();
              });
            }),
        formFieldSpacing,
      ]);
    } else if (isMonthly) {
      conditionalWidgets.addAll([
        CustomFormMultiDropdown(
            key: const Key(recurringByMonthFormFieldLabel),
            labelText: recurringByMonthFormFieldLabel,
            options:
                recurrenceRuleMultiSelectValues[recurringByMonthFormFieldLabel]!
                    .map((e) => DropdownItem(
                        label: e.label,
                        value: e.value,
                        selected: widget.recurrenceRuleJson['bymonth']
                            .contains(int.parse(e.value))))
                    .toList(),
            onChanged: (v) {
              setState(() {
                widget.recurrenceRuleJson['bymonth'] =
                    v.map((e) => int.parse(e)).toList();
                evaluateRecurrenceRuleText();
              });
            }),
        formFieldSpacing,
      ]);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (recurringRuleText.isNotEmpty) ...[
          Card.outlined(
              child: Padding(
                  padding: EdgeInsets.all(10),
                  child: Row(spacing: 10, children: [
                    Icon(
                      Icons.schedule,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    Flexible(
                        child: Text(
                      recurringRuleText,
                      style: Theme.of(context).textTheme.bodyLarge,
                    )),
                  ]))),
          formFieldSpacing,
        ],
        CustomFormDropdown(
          labelText: recurringFrequencyTextFormFieldLabel,
          options: recurringFrequencyOptions,
          controller: recurranceRuleControllerMap[
              recurringFrequencyTextFormFieldLabel]!,
          validator: checkEmptyInput,
          onChanged: (value) {
            setState(() {
              var val = value.toString().toUpperCase();
              widget.recurrenceRuleJson['freq'] = val;

              for (var i in recurrenceRuleMultiSelectValues[
                  recurringByDayFormFieldLabel]!) {
                i.selected = false;
              }
              for (var i in recurrenceRuleMultiSelectValues[
                  recurringByMonthFormFieldLabel]!) {
                i.selected = false;
              }

              widget.recurrenceRuleJson['byday'] = [];
              widget.recurrenceRuleJson['bymonth'] = [];
              evaluateRecurrenceRuleText();
            });
          },
        ),
        formFieldSpacing,
        CustomFormField(
          keyboardType: TextInputType.number,
          inputFormatter: FilteringTextInputFormatter.digitsOnly,
          controller:
              recurranceRuleControllerMap[recurringIntervalTextFormFieldLabel]!,
          labelText: recurringIntervalTextFormFieldLabel,
          validator: checkEmptyInput,
          onChanged: (value) {
            setState(() {
              widget.recurrenceRuleJson['interval'] =
                  int.tryParse(value ?? '1'); // Default to 1 if parsing fails
              evaluateRecurrenceRuleText();
            });
          },
        ),
        formFieldSpacing,
        ...conditionalWidgets,
        Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            spacing: 10,
            children: [
              Expanded(
                  child: CustomFormDropdown(
                labelText: recurringEndsFormFieldLabel,
                options: ['Never', 'Until', 'After'],
                controller:
                    recurranceRuleControllerMap[recurringEndsFormFieldLabel]!,
                validator: checkEmptyInput,
                onChanged: (value) {
                  setState(() {
                    if (value == 'Never') {
                      widget.recurrenceRuleJson.remove('until');
                      widget.recurrenceRuleJson.remove('count');
                    } else if (value == 'Until') {
                      widget.recurrenceRuleJson.remove('count');
                      widget.recurrenceRuleJson['until'] =
                          DateFormat('yyyy-MM-ddTHH:mm:ss')
                              .format(recurrenceUntilController);
                    } else if (value == 'After') {
                      widget.recurrenceRuleJson.remove('until');
                      widget.recurrenceRuleJson['count'] = int.parse(
                          recurranceRuleControllerMap[
                                  recurringNumOccurrencesFormFieldLabel]!
                              .text);
                    }
                    evaluateRecurrenceRuleText();
                  });
                },
              )),
              if (recurranceRuleControllerMap[recurringEndsFormFieldLabel]!
                      .text ==
                  'Until')
                CustomDatePicker(
                    initialDate: recurrenceUntilController,
                    onDateSelected: (date) {
                      setState(() {
                        recurrenceUntilController = date;
                        widget.recurrenceRuleJson['until'] =
                            DateFormat('yyyy-MM-ddTHH:mm:ss').format(date);
                        evaluateRecurrenceRuleText();
                      });
                    })
              else if (recurranceRuleControllerMap[recurringEndsFormFieldLabel]!
                      .text ==
                  'After')
                Expanded(
                    child: CustomFormField(
                  keyboardType: TextInputType.number,
                  inputFormatter: FilteringTextInputFormatter.digitsOnly,
                  controller: recurranceRuleControllerMap[
                      recurringNumOccurrencesFormFieldLabel]!,
                  labelText: recurringNumOccurrencesFormFieldLabel,
                  validator: checkEmptyInput,
                  onChanged: (value) {
                    setState(() {
                      widget.recurrenceRuleJson['count'] = int.tryParse(
                          value ?? '1'); // Default to 1 if parsing fails
                      evaluateRecurrenceRuleText();
                    });
                  },
                )),
            ])
      ],
    );
  }
}
