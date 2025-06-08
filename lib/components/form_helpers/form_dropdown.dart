import 'package:flutter/material.dart';

class CustomFormDropdown extends StatefulWidget {
  final List<String> options;
  final String? labelText;
  final String? hintText;
  final IconData? icon;
  final String? Function(String?)? validator;
  final TextEditingController controller;
  final DropdownMenuItem<String>? addOption;
  final Function? onAddOptionSelect;
  final Function? onChanged;

  const CustomFormDropdown({
    super.key,
    required this.options,
    required this.controller,
    this.labelText,
    this.hintText,
    this.icon,
    this.validator,
    this.addOption,
    this.onAddOptionSelect,
    this.onChanged,
  });

  @override
  State<CustomFormDropdown> createState() => _CustomFormDropdownState();
}

class _CustomFormDropdownState extends State<CustomFormDropdown> {
  late String value;

  @override
  Widget build(BuildContext context) {
    var options = widget.options.map<DropdownMenuItem<String>>((String value) {
      return DropdownMenuItem(
        value: value,
        child: Text(value),
      );
    }).toList();
    if (widget.addOption != null) {
      options.add(widget.addOption as DropdownMenuItem<String>);
    }
    return DropdownButtonFormField<String>(
      dropdownColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      decoration: InputDecoration(
        border: const OutlineInputBorder(),
        icon: widget.icon != null ? Icon(widget.icon) : null,
        labelText: widget.labelText,
        hintText: widget.hintText,
      ),
      validator: widget.validator,
      value: widget.controller.text.isEmpty ? null : widget.controller.text,
      onChanged: (String? val) {
        if (widget.addOption != null &&
            val == widget.addOption?.value &&
            widget.onAddOptionSelect != null) {
          widget.onAddOptionSelect!();
        } else {
          setState(() {
            value = val!;
            widget.controller.text = val;
          });
          widget.onChanged?.call(val);
        }
      },
      items: options,
    );
  }
}
