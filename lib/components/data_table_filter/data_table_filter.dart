import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:expense_manager/components/form_helpers/form_field.dart';
import 'package:expense_manager/components/form_helpers/form_multi_dropdown.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_date_range_picker/flutter_date_range_picker.dart';
import 'package:intl/intl.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

class DataTableFilter extends StatefulWidget {
  final List<ExpenseData> unFilteredData;
  final Function(List<ExpenseData>) onFilter;
  const DataTableFilter({
    super.key,
    required this.unFilteredData,
    required this.onFilter,
  });

  @override
  State<DataTableFilter> createState() => _DataTableFilterState();
}

class _DataTableFilterState extends State<DataTableFilter> {
  final currencyFormatter = NumberFormat.simpleCurrency();
  final dateFormatter = DateFormat('MM/dd/yyyy');
  List<Widget> activeFilters = [];
  double largestAmount = 0;
  final _activeFiltersScrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _filterSnapShot = Map<String, String>();
  final _descriptionFilterController = TextEditingController();
  final _categoryFilterController = MultiSelectController<String>();
  final _ownerFilterController = MultiSelectController<String>();
  final _costRangeFilter = Tuple2<TextEditingController, TextEditingController>(
      TextEditingController(), TextEditingController());
  final _dateRangeFilter = Tuple2<TextEditingController, TextEditingController>(
      TextEditingController(), TextEditingController());

  Chip getFilterChip(String label, Function onClear) => Chip(
        label: Text(label),
        deleteIcon: const Icon(Icons.close, size: 20),
        onDeleted: () {
          setState(() {
            onClear();
            processFilters();
          });
        },
      );

  void updateActiveFilters() {
    List<Chip> newActiveFilters = [];
    if (_descriptionFilterController.text.isNotEmpty) {
      newActiveFilters.add(getFilterChip(
          "Description has '${_descriptionFilterController.text}'",
          () => setState(() {
                _descriptionFilterController.clear();
              })));
    }
    if (_categoryFilterController.selectedItems.isNotEmpty) {
      newActiveFilters.add(getFilterChip(
          "Category is '${_categoryFilterController.selectedItems.map((e) => e.value).join("', '")}'",
          () => setState(() {
                _categoryFilterController.clearAll();
              })));
    }
    if (_ownerFilterController.selectedItems.isNotEmpty) {
      newActiveFilters.add(getFilterChip(
          "Owner is '${_ownerFilterController.selectedItems.map((e) => e.value).join("', '")}'",
          () => setState(() {
                _ownerFilterController.clearAll();
              })));
    }

    final costRangeFilterLow = double.parse(
        _costRangeFilter.item1.text.replaceFirst("\$", "").replaceAll(",", ""));
    final costRangeFilterHigh = double.parse(
        _costRangeFilter.item2.text.replaceFirst("\$", "").replaceAll(",", ""));
    if (costRangeFilterLow != 0 || costRangeFilterHigh != largestAmount) {
      var label =
          "Cost is between ${currencyFormatter.format(costRangeFilterLow)} and ${currencyFormatter.format(costRangeFilterHigh)}";
      if (costRangeFilterLow != 0 && costRangeFilterHigh == largestAmount) {
        label =
            "Cost is more than ${currencyFormatter.format(costRangeFilterLow)}";
      } else if (costRangeFilterLow == 0 &&
          costRangeFilterHigh != largestAmount) {
        label =
            "Cost is less than ${currencyFormatter.format(costRangeFilterHigh)}";
      }
      newActiveFilters.add(getFilterChip(label, () {
        _costRangeFilter.item1.text = currencyFormatter.format(0);
        _costRangeFilter.item2.text = currencyFormatter.format(largestAmount);
      }));
    }

    if (_dateRangeFilter.item1.text.isNotEmpty &&
        _dateRangeFilter.item2.text.isNotEmpty) {
      final dateRangeFilterLow =
          dateFormatter.parse(_dateRangeFilter.item1.text);
      final dateRangeFilterHigh =
          dateFormatter.parse(_dateRangeFilter.item2.text);
      var label =
          "Date is between ${_dateRangeFilter.item1.text} and ${_dateRangeFilter.item2.text}";
      if (dateRangeFilterLow == dateRangeFilterHigh) {
        label = "Date is ${_dateRangeFilter.item1.text}";
      }
      newActiveFilters.add(getFilterChip(label, () {
        _dateRangeFilter.item1.text = "";
        _dateRangeFilter.item2.text = "";
      }));
    }

    activeFilters = newActiveFilters
        .expand((chip) => [chip, const SizedBox(width: 8)])
        .toList();
  }

  void createFilterSnapShot() {
    _filterSnapShot["dateRangeLow"] = _dateRangeFilter.item1.text;
    _filterSnapShot["dateRangeHigh"] = _dateRangeFilter.item2.text;
    _filterSnapShot["description"] = _descriptionFilterController.text;
    _filterSnapShot["category"] =
        _categoryFilterController.selectedItems.map((v) => v.value).join(":");
    _filterSnapShot["owner"] =
        _ownerFilterController.selectedItems.map((v) => v.value).join(":");
    _filterSnapShot["costRangeLow"] = _costRangeFilter.item1.text;
    _filterSnapShot["costRangeHigh"] = _costRangeFilter.item2.text;
  }

  void resetFiltersToSnapShot() {
    _dateRangeFilter.item1.text = _filterSnapShot["dateRangeLow"] ?? "";
    _dateRangeFilter.item2.text = _filterSnapShot["dateRangeHigh"] ?? "";
    _descriptionFilterController.text = _filterSnapShot["description"] ?? "";

    _categoryFilterController.clearAll();
    final snapShotCategories = _filterSnapShot["category"];
    if (snapShotCategories != null) {
      final snapShotCategoriesList = snapShotCategories.split(":");
      _categoryFilterController
          .selectWhere((v) => snapShotCategoriesList.contains(v.label));
      _categoryFilterController
          .unselectWhere((v) => !snapShotCategoriesList.contains(v.label));
    }

    _ownerFilterController.clearAll();
    final snapShotOwners = _filterSnapShot["owner"];
    if (snapShotOwners != null) {
      final snapShotOwnersList = snapShotOwners.split(":");
      _ownerFilterController
          .selectWhere((v) => snapShotOwnersList.contains(v.label));
      _ownerFilterController
          .unselectWhere((v) => !snapShotOwnersList.contains(v.label));
    }

    _costRangeFilter.item1.text = _filterSnapShot["costRangeLow"] ?? "";
    _costRangeFilter.item2.text = _filterSnapShot["costRangeHigh"] ?? "";
  }

  void processFilters() {
    var filteredData = widget.unFilteredData;

    if (_descriptionFilterController.text.isNotEmpty) {
      filteredData = filteredData
          .where((e) => e.description
              .toLowerCase()
              .contains(_descriptionFilterController.text.toLowerCase()))
          .toList();
    }

    if (_categoryFilterController.selectedItems.isNotEmpty) {
      filteredData = filteredData
          .where((e) => _categoryFilterController.selectedItems
              .map((c) => c.value)
              .contains(e.category))
          .toList();
    }

    if (_ownerFilterController.selectedItems.isNotEmpty) {
      filteredData = filteredData
          .where((e) => _ownerFilterController.selectedItems
              .map((c) => c.value)
              .contains(e.person))
          .toList();
    }

    final costRangeFilterLow = double.parse(
        _costRangeFilter.item1.text.replaceFirst("\$", "").replaceAll(",", ""));
    final costRangeFilterHigh = double.parse(
        _costRangeFilter.item2.text.replaceFirst("\$", "").replaceAll(",", ""));
    filteredData = filteredData
        .where(
            (e) => e.cost > costRangeFilterLow && e.cost < costRangeFilterHigh)
        .toList();

    if (_dateRangeFilter.item1.text.isNotEmpty &&
        _dateRangeFilter.item2.text.isNotEmpty) {
      final dateRangeFilterLow =
          dateFormatter.parse(_dateRangeFilter.item1.text);
      final dateRangeFilterHigh =
          dateFormatter.parse(_dateRangeFilter.item2.text);
      filteredData = filteredData
          .where((e) =>
              e.date.isAfter(dateRangeFilterLow) &&
              e.date.isBefore(dateRangeFilterHigh))
          .toList();
    }

    updateActiveFilters();
    widget.onFilter(filteredData);
  }

  @override
  Widget build(BuildContext context) {
    final calendarTextStyle = Theme.of(context).textTheme.bodyMedium!;
    const double calendarTileSize = 35;
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    largestAmount = expenseProvider.expenses
        .reduce((value, element) => value.cost > element.cost ? value : element)
        .cost;

    if (_costRangeFilter.item1.text.isEmpty) {
      _costRangeFilter.item1.text = currencyFormatter.format(0);
    }
    if (_costRangeFilter.item2.text.isEmpty) {
      _costRangeFilter.item2.text = currencyFormatter.format(largestAmount);
    }

    return Row(children: [
      TextButton(
          onPressed: () {
            showDialog(
                context: context,
                builder: (context) {
                  createFilterSnapShot();
                  return Dialog(
                    child: SingleChildScrollView(
                        child: Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Title(
                                      color: Theme.of(context)
                                          .textTheme
                                          .displayLarge!
                                          .color!,
                                      child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            'Filter By',
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleMedium,
                                          ))),
                                  const SizedBox(height: 20),
                                  DateRangeFormField(
                                    builder: (context, dateRange) => Text(
                                        (_dateRangeFilter.item1.text.isEmpty ||
                                                _dateRangeFilter
                                                    .item2.text.isEmpty)
                                            ? ''
                                            : "${_dateRangeFilter.item1.text} - ${_dateRangeFilter.item2.text}"),
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      labelText: "Date",
                                    ),
                                    pickerBuilder: (context,
                                            onDateRangeChanged) =>
                                        Container(
                                            decoration: BoxDecoration(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .surfaceContainerHigh,
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(6),
                                                  topRight: Radius.circular(6),
                                                )),
                                            child: DateRangePickerWidget(
                                              height: 320,
                                              theme: CalendarTheme(
                                                selectedColor: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                inRangeColor: Theme.of(context)
                                                    .colorScheme
                                                    .primaryContainer,
                                                inRangeTextStyle:
                                                    calendarTextStyle,
                                                selectedTextStyle:
                                                    calendarTextStyle,
                                                dayNameTextStyle:
                                                    calendarTextStyle,
                                                todayTextStyle:
                                                    calendarTextStyle,
                                                defaultTextStyle:
                                                    calendarTextStyle,
                                                disabledTextStyle:
                                                    calendarTextStyle,
                                                radius: 25,
                                                tileSize: calendarTileSize,
                                              ),
                                              doubleMonth: false,
                                              onDateRangeChanged: (dateRange) {
                                                if (dateRange != null) {
                                                  _dateRangeFilter.item1.text =
                                                      dateFormatter.format(
                                                          dateRange.start);
                                                  _dateRangeFilter.item2.text =
                                                      dateFormatter.format(
                                                          dateRange.end);
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
                                            dialogFooterBuilder: (
                                                    {selectedDateRange}) =>
                                                Container(
                                                    decoration: BoxDecoration(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .surfaceContainerHigh,
                                                        borderRadius:
                                                            const BorderRadius
                                                                .only(
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  6),
                                                          bottomRight:
                                                              Radius.circular(
                                                                  6),
                                                        )),
                                                    alignment:
                                                        AlignmentDirectional
                                                            .centerEnd,
                                                    padding:
                                                        const EdgeInsets.all(5),
                                                    width: 7 * calendarTileSize,
                                                    child: Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    widgetContext)
                                                                .pop();
                                                          },
                                                          child: const Text(
                                                              "Cancel"),
                                                        ),
                                                        const SizedBox(
                                                            width: 10),
                                                        FilledButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    widgetContext)
                                                                .pop(
                                                                    selectedDateRange);
                                                          },
                                                          child: const Text(
                                                              "Confirm"),
                                                        ),
                                                      ],
                                                    ))),
                                  ),
                                  const SizedBox(height: 20),
                                  CustomFormField(
                                    enabled: true,
                                    maxCharacters: null,
                                    keyboardType: TextInputType.text,
                                    inputFormatter: FilteringTextInputFormatter
                                        .singleLineFormatter,
                                    controller: _descriptionFilterController,
                                    labelText: 'Description',
                                    hintText: 'Filter by description',
                                    obscureText: false,
                                    icon: null,
                                    onSaved: (value) {},
                                    onChanged: (value) {},
                                    validator: (value) => null,
                                  ),
                                  const SizedBox(height: 20),
                                  CustomFormMultiDropdown(
                                    labelText: 'Category',
                                    hintText: 'Filter by category',
                                    options: expenseProvider.categoryOptions,
                                    validator: (value) => null,
                                    controller: _categoryFilterController,
                                  ),
                                  const SizedBox(height: 20),
                                  CustomFormMultiDropdown(
                                    labelText: 'Owner',
                                    hintText: 'Filter by owner',
                                    options: expenseProvider.ownerOptions,
                                    validator: (value) => null,
                                    controller: _ownerFilterController,
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Cost",
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                  const SizedBox(height: 10),
                                  Row(children: [
                                    Expanded(
                                        child: CustomFormField(
                                            enabled: true,
                                            maxCharacters: null,
                                            labelText: "From",
                                            hintText: "Cost Filter Range Low",
                                            icon: null,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            inputFormatter:
                                                CurrencyTextInputFormatter
                                                    .simpleCurrency(
                                                        enableNegative: false),
                                            controller: _costRangeFilter.item1,
                                            onSaved: (val) {},
                                            onChanged: (val) {},
                                            validator: (val) => null,
                                            obscureText: false)),
                                    const SizedBox(width: 20),
                                    Expanded(
                                        child: CustomFormField(
                                            enabled: true,
                                            maxCharacters: null,
                                            labelText: "To",
                                            hintText: "Cost Filter Range High",
                                            icon: null,
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                decimal: true),
                                            inputFormatter:
                                                CurrencyTextInputFormatter
                                                    .simpleCurrency(
                                                        enableNegative: false),
                                            controller: _costRangeFilter.item2,
                                            onSaved: (val) {},
                                            onChanged: (val) {},
                                            validator: (val) => null,
                                            obscureText: false)),
                                  ]),
                                  const Divider(),
                                  Row(
                                      mainAxisAlignment: MainAxisAlignment.end,
                                      children: [
                                        TextButton(
                                            onPressed: () {
                                              resetFiltersToSnapShot();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Cancel')),
                                        const SizedBox(width: 10),
                                        FilledButton(
                                            onPressed: () {
                                              processFilters();
                                              Navigator.pop(context);
                                            },
                                            child: const Text('Apply')),
                                      ]),
                                ],
                              ),
                            ))),
                  );
                });
          },
          child: const Icon(Icons.filter_list)),
      Expanded(
          child: FadingEdgeScrollView.fromScrollView(
              child: ListView(
        scrollDirection: Axis.horizontal,
        controller: _activeFiltersScrollController,
        children: activeFilters,
      )))
    ]);
  }
}
