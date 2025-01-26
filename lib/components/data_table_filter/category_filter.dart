import 'package:expense_manager/components/form_helpers/form_multi_dropdown.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:provider/provider.dart';

class CategoryFilter extends StatelessWidget {
  final MultiSelectController<String> categoryFilterController;
  const CategoryFilter({super.key, required this.categoryFilterController});

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return CustomFormMultiDropdown(
      labelText: 'Category',
      hintText: 'Filter by category',
      options: expenseProvider.categoryOptions,
      validator: (value) => null,
      controller: categoryFilterController,
    );
  }
}
