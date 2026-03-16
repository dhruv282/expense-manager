import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class YearSelector extends StatefulWidget {
  final Function(bool) setLoadingState;
  const YearSelector({super.key, required this.setLoadingState});

  @override
  State<YearSelector> createState() => _YearSelector();
}

class _YearSelector extends State<YearSelector> {
  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final valueNotifier = ValueNotifier(expenseProvider.selectedYear);

    return DropdownButtonHideUnderline(
      child: DropdownButton2(
        valueListenable: valueNotifier,
        onChanged: (year) {
          setState(() {
            widget.setLoadingState(true);
            valueNotifier.value = year;
            expenseProvider.loadExpenseData(year: year).whenComplete(() {
              widget.setLoadingState(false);
            });
          });
        },
        items: expenseProvider.yearOptions
                .map((int year) => DropdownItem(
                      value: year,
                      child: Text(year.toString()),
                    ))
                .toList() +
            [const DropdownItem(value: null, child: Text("ALL"))],
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
