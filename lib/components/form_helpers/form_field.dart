import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomFormField extends StatefulWidget {
  final bool enabled;
  final int? maxCharacters;
  final String labelText;
  final String hintText;
  final IconData? icon;
  final TextInputType keyboardType;
  final TextInputFormatter inputFormatter;

  final TextEditingController controller;
  final void Function(String?) onSaved;
  final String? Function(String?) validator;

  const CustomFormField(
      {super.key,
      required this.enabled,
      required this.maxCharacters,
      required this.labelText,
      required this.hintText,
      required this.icon,
      required this.keyboardType,
      required this.inputFormatter,
      required this.controller,
      required this.onSaved,
      required this.validator});

  @override
  State<CustomFormField> createState() => _CustomFormFieldState();
}

class _CustomFormFieldState extends State<CustomFormField> {
  @override
  Widget build(BuildContext context) {
    return TextFormField(
      enabled: widget.enabled,
      maxLength: widget.maxCharacters,
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
