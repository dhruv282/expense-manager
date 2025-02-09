import 'package:flutter/material.dart';
import 'package:expense_manager/components/form_helpers/form_multi_dropdown.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:provider/provider.dart';

class OwnerFilter extends StatelessWidget {
  final MultiSelectController<String> ownerFilterController;
  const OwnerFilter({super.key, required this.ownerFilterController});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return CustomFormMultiDropdown(
      labelText: 'Owner',
      hintText: 'Filter by owner',
      options: expenseProvider.ownerOptions,
      controller: ownerFilterController,
    );
  }
}
