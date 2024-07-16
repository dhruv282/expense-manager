import 'package:flutter/material.dart';

class ExpenseFormDropdown extends StatefulWidget {
  final List<String> options;
  final String labelText;
  final String hintText;
  final IconData? icon;

  const ExpenseFormDropdown({
    super.key,
    required this.options,
    required this.labelText,
    required this.hintText,
    required this.icon,
  });

  @override
  State<ExpenseFormDropdown> createState() => _ExpenseFormDropdownState();
}

class _ExpenseFormDropdownState extends State<ExpenseFormDropdown> {
  late String value;

  @override
  Widget build(BuildContext context) {
    return DropdownMenu<String>(
      label: Text(widget.labelText),
      leadingIcon: widget.icon != null ? Icon(widget.icon) : null,
      hintText: widget.hintText,
      onSelected: (String? val) {
        setState(() {
          value = val!;
        });
      },
      dropdownMenuEntries:
          widget.options.map<DropdownMenuEntry<String>>((String value) {
        return DropdownMenuEntry(value: value, label: value);
      }).toList(),
    );
  }
}
