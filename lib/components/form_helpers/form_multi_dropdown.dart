import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

class CustomFormMultiDropdown extends StatefulWidget {
  final List<String> options;
  final String labelText;
  final String hintText;
  final MultiSelectController<String> controller;
  final String? Function(List<DropdownItem<String>>?) validator;
  const CustomFormMultiDropdown({
    super.key,
    required this.options,
    required this.labelText,
    required this.validator,
    required this.controller,
    required this.hintText,
  });

  @override
  State<CustomFormMultiDropdown> createState() =>
      _CustomFormMultiDropdownState();
}

class _CustomFormMultiDropdownState extends State<CustomFormMultiDropdown> {
  @override
  Widget build(BuildContext context) {
    return MultiDropdown(
        searchEnabled: true,
        fieldDecoration: FieldDecoration(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: Theme.of(context).dividerColor,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              width: 2.0,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
          labelText: widget.labelText,
          hintText: widget.hintText,
        ),
        dropdownDecoration: DropdownDecoration(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
        ),
        dropdownItemDecoration: DropdownItemDecoration(
          selectedBackgroundColor:
              Theme.of(context).colorScheme.primaryContainer,
        ),
        chipDecoration: ChipDecoration(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        ),
        validator: widget.validator,
        controller: widget.controller,
        items: widget.options
            .map((o) => DropdownItem(label: o, value: o))
            .toList());
  }
}
