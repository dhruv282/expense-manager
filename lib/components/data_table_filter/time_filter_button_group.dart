import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:expense_manager/data/time_period_enums.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TimeFilterButtonGroup extends StatefulWidget {
  final Function(bool) setLoadingState;

  const TimeFilterButtonGroup({
    super.key,
    required this.setLoadingState,
  });

  @override
  State<TimeFilterButtonGroup> createState() => _TimeFilterButtonGroupState();
}

class _TimeFilterButtonGroupState extends State<TimeFilterButtonGroup> {
  late ValueNotifier<TimePeriod?> _valueNotifier;

  @override
  void initState() {
    super.initState();
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    _valueNotifier =
        ValueNotifier<TimePeriod?>(expenseProvider.selectedTimePeriod);
  }

  @override
  void didUpdateWidget(TimeFilterButtonGroup oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update value notifier if provider's selected period changed externally
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);
    if (_valueNotifier.value != expenseProvider.selectedTimePeriod) {
      _valueNotifier.value = expenseProvider.selectedTimePeriod;
    }
  }

  @override
  void dispose() {
    _valueNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    // Get all periods and determine current value
    final allPeriods = TimePeriod.values;

    return DropdownButtonHideUnderline(
      child: DropdownButton2<TimePeriod>(
        valueListenable: _valueNotifier,
        onChanged: (period) {
          if (period != null && expenseProvider.isTimePeriodAvailable(period)) {
            widget.setLoadingState(true);
            _valueNotifier.value = period;
            expenseProvider.setTimePeriod(period).whenComplete(() {
              widget.setLoadingState(false);
            });
          }
        },
        items: allPeriods.map((period) {
          final isAvailable = expenseProvider.isTimePeriodAvailable(period);
          return DropdownItem<TimePeriod>(
            value: period,
            enabled: isAvailable,
            child: Opacity(
              opacity: isAvailable ? 1.0 : 0.5,
              child: Text(getTimePeriodLabel(period)),
            ),
          );
        }).toList(),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            color:
                Theme.of(context).buttonTheme.colorScheme?.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        buttonStyleData: ButtonStyleData(
          decoration: BoxDecoration(
            color:
                Theme.of(context).buttonTheme.colorScheme?.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
