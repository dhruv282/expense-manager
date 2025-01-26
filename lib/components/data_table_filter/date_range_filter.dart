import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class DateRangeFilter extends StatelessWidget {
  final Tuple2<TextEditingController, TextEditingController> dateRangeFilter;
  DateRangeFilter({super.key, required this.dateRangeFilter});
  final dateFormatter = DateFormat('MM/dd/yyyy');

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final calendarTextStyle = Theme.of(context).textTheme.bodyMedium!;
    const double calendarTileSize = 35;
    return DateRangeFormField(
      builder: (context, dateRange) => Text((dateRangeFilter
                  .item1.text.isEmpty ||
              dateRangeFilter.item2.text.isEmpty)
          ? ''
          : "${dateRangeFilter.item1.text} - ${dateRangeFilter.item2.text}"),
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: "Date",
      ),
      pickerBuilder: (context, onDateRangeChanged) => Container(
          decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHigh,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              )),
          child: DateRangePickerWidget(
            height: 320,
            theme: CalendarTheme(
              selectedColor: Theme.of(context).colorScheme.primaryContainer,
              inRangeColor: Theme.of(context).colorScheme.primaryContainer,
              inRangeTextStyle: calendarTextStyle,
              selectedTextStyle: calendarTextStyle,
              dayNameTextStyle: calendarTextStyle,
              todayTextStyle: calendarTextStyle,
              defaultTextStyle: calendarTextStyle,
              disabledTextStyle: calendarTextStyle
                  .merge(TextStyle(color: Theme.of(context).disabledColor)),
              radius: 25,
              tileSize: calendarTileSize,
            ),
            doubleMonth: false,
            initialDisplayedDate: expenseProvider.expenses.firstOrNull?.date,
            minDate: expenseProvider.expenses.lastOrNull?.date,
            maxDate: expenseProvider.expenses.firstOrNull?.date,
            onDateRangeChanged: (dateRange) {
              if (dateRange != null) {
                dateRangeFilter.item1.text =
                    dateFormatter.format(dateRange.start);
                dateRangeFilter.item2.text =
                    dateFormatter.format(dateRange.end);
              }
              onDateRangeChanged(dateRange);
            },
          )),
      showDateRangePicker: (
              {dialogFooterBuilder,
              required pickerBuilder,
              required widgetContext}) =>
          showDateRangePickerDialogOnWidget(
              widgetContext: widgetContext,
              pickerBuilder: pickerBuilder,
              dialogFooterBuilder: ({selectedDateRange}) => Container(
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(6),
                        bottomRight: Radius.circular(6),
                      )),
                  alignment: AlignmentDirectional.centerEnd,
                  padding: const EdgeInsets.all(5),
                  width: 7 * calendarTileSize,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(widgetContext).pop();
                        },
                        child: const Text("Cancel"),
                      ),
                      const SizedBox(width: 10),
                      FilledButton(
                        onPressed: () {
                          Navigator.of(widgetContext).pop(selectedDateRange);
                        },
                        child: const Text("Confirm"),
                      ),
                    ],
                  ))),
    );
  }
}
