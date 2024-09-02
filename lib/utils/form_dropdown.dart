import 'package:flutter/material.dart';

class ExpenseFormDropdown extends StatefulWidget {
  final List<String> options;
  final String labelText;
  final String hintText;
  final IconData? icon;
  final String? Function(String?) validator;
  final TextEditingController controller;

  const ExpenseFormDropdown({
    super.key,
    required this.options,
    required this.labelText,
    required this.hintText,
    required this.icon,
    required this.validator,
    required this.controller,
  });

  @override
  State<ExpenseFormDropdown> createState() => _ExpenseFormDropdownState();
}

class _ExpenseFormDropdownState extends State<ExpenseFormDropdown> {
  late String value;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        icon: widget.icon != null ? Icon(widget.icon) : null,
        labelText: widget.labelText,
        hintText: widget.hintText,
      ),
      validator: widget.validator,
      onChanged: (String? val) {
        setState(() {
          value = val!;
          widget.controller.text = val;
        });
      },
      items: widget.options.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
