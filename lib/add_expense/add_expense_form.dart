import 'package:expense_manager/constants/expense_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../utils/date_picker.dart';
import '../utils/form_field.dart';

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

  String? checkEmptyInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter an amount';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
          children: [
            ExpenseFormField(
              enabled: true,
              maxCharacters: maxCharacters,
              keyboardType: TextInputType.number,
              inputFormatter: FilteringTextInputFormatter.digitsOnly,
              controller: widget.controllerMap[amountTextFormFieldLabel]!,
              labelText: amountTextFormFieldLabel,
              hintText: amountTextFormFieldHint,
              icon: Icons.attach_money,
              onSaved: (value) {},
              validator: (value) {
                return checkEmptyInput(value);
              },
            ),
            ExpenseFormField(
              enabled: true,
              maxCharacters: maxCharacters,
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
            Row(children: [
              Expanded(
                child: ExpenseFormField(
                  enabled: true,
                  maxCharacters: null,
                  keyboardType: TextInputType.text,
                  inputFormatter:
                      FilteringTextInputFormatter.singleLineFormatter,
                  controller: widget.controllerMap[dateTextFormFieldLabel]!,
                  labelText: dateTextFormFieldLabel,
                  hintText: dateTextFormFieldHint,
                  icon: null,
                  onSaved: (value) {},
                  validator: (value) {
                    return null;
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
            ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ],
        ));
  }
}
