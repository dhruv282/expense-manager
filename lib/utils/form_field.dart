import 'package:expense_manager/constants/expense_form.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ExpenseFormField extends StatefulWidget {
  final String labelText;
  final String hintText;
  final IconData? icon;
  final TextInputType keyboardType;
  final TextInputFormatter inputFormatter;

  final TextEditingController controller;
  final void Function(String?) onSaved;
  final String? Function(String?) validator;

  const ExpenseFormField(
      {super.key,
      required this.labelText,
      required this.hintText,
      required this.icon,
      required this.keyboardType,
      required this.inputFormatter,
      required this.controller,
      required this.onSaved,
      required this.validator});

  @override
  State<ExpenseFormField> createState() => _ExpenseFormFieldState();
}

class _ExpenseFormFieldState extends State<ExpenseFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      maxLength: maxCharacters,
      keyboardType: widget.keyboardType,
      inputFormatters: [widget.inputFormatter],
      controller: widget.controller,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        icon: widget.icon != null ? Icon(widget.icon) : null,
        labelText: widget.labelText,
        hintText: widget.hintText,
      ),
      onSaved: widget.onSaved,
      validator: widget.validator,
    );
  }
}
