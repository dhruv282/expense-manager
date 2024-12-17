import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class YearSelector extends StatefulWidget {
  const YearSelector({super.key});

  @override
  State<YearSelector> createState() => _YearSelector();
}

class _YearSelector extends State<YearSelector> {
  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        value: expenseProvider.selectedYear,
        onChanged: (year) {
          setState(() {
            expenseProvider.loadExpenseData(year: year);
          });
        },
        items: expenseProvider.yearOptions
                .map((int year) => DropdownMenuItem(
                      value: year,
                      child: Text(year.toString()),
                    ))
                .toList() +
            [const DropdownMenuItem(value: null, child: Text("ALL"))],
        dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
          color: Theme.of(context).buttonTheme.colorScheme?.secondaryContainer,
          borderRadius: BorderRadius.circular(14),
        )),
        buttonStyleData: ButtonStyleData(
            decoration: BoxDecoration(
          color: Theme.of(context).buttonTheme.colorScheme?.secondaryContainer,
          borderRadius: BorderRadius.circular(14),
        )),
      ),
    );
  }
}
