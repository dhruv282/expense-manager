import 'package:expense_manager/components/form_helpers/form_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DescriptionFilter extends StatelessWidget {
  final TextEditingController descriptionFilterController;
  const DescriptionFilter(
      {super.key, required this.descriptionFilterController});

  @override
  Widget build(BuildContext context) {
    return CustomFormField(
      keyboardType: TextInputType.text,
      inputFormatter: FilteringTextInputFormatter.singleLineFormatter,
      controller: descriptionFilterController,
      labelText: 'Description',
      hintText: 'Filter by description',
    );
  }
}
