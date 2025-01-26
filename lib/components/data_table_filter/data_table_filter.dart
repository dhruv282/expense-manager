import 'package:expense_manager/components/data_table_filter/category_filter.dart';
import 'package:expense_manager/components/data_table_filter/cost_filter.dart';
import 'package:expense_manager/components/data_table_filter/date_range_filter.dart';
import 'package:expense_manager/components/data_table_filter/description_filter.dart';
import 'package:expense_manager/components/data_table_filter/owner_filter.dart';
import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';
import 'package:flutter/material.dart';
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
  int? currentYear;
  List<Widget> activeFilters = [];
  double largestAmount = 0;
  final _activeFiltersScrollController = ScrollController();
  final _formKey = GlobalKey<FormState>();
  final _filterSnapShot = <String, String>{};
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
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    largestAmount = expenseProvider.expenses
        .reduce((value, element) => value.cost > element.cost ? value : element)
        .cost;

    if (currentYear != expenseProvider.selectedYear) {
      currentYear = expenseProvider.selectedYear;
      _filterSnapShot.clear();
      resetFiltersToSnapShot();
      activeFilters = [];
    }

    if (_costRangeFilter.item1.text.isEmpty) {
      _costRangeFilter.item1.text = currencyFormatter.format(0);
    }
    if (_costRangeFilter.item2.text.isEmpty) {
      _costRangeFilter.item2.text = currencyFormatter.format(largestAmount);
    }

    return Row(children: [
      TextButton(
        child: const Icon(Icons.filter_list),
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
                                    ),
                                  ),
                                ),
                                DateRangeFilter(
                                    dateRangeFilter: _dateRangeFilter),
                                DescriptionFilter(
                                    descriptionFilterController:
                                        _descriptionFilterController),
                                CategoryFilter(
                                    categoryFilterController:
                                        _categoryFilterController),
                                OwnerFilter(
                                    ownerFilterController:
                                        _ownerFilterController),
                                CostFilter(costRangeFilter: _costRangeFilter),
                              ]
                                  .expand(
                                      (f) => [f, const SizedBox(height: 20)])
                                  .toList() +
                              [
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
                                            createFilterSnapShot();
                                            processFilters();
                                            Navigator.pop(context);
                                          },
                                          child: const Text('Apply')),
                                    ]),
                              ],
                        ),
                      ),
                    ),
                  ),
                );
              }).then((val) {
            resetFiltersToSnapShot();
          });
        },
      ),
      Expanded(
        child: FadingEdgeScrollView.fromScrollView(
          child: ListView(
            scrollDirection: Axis.horizontal,
            controller: _activeFiltersScrollController,
            children: activeFilters,
          ),
        ),
      )
    ]);
  }
}
