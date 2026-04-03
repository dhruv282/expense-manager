import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CategoryTotals extends DashboardWidget {
  @override
  Widget getWidget() {
    return CategoryTotalsWidget();
  }
}

class CategoryTotalsWidget extends StatefulWidget {
  const CategoryTotalsWidget({super.key});

  @override
  State<CategoryTotalsWidget> createState() => _CategoryTotalsWidgetState();
}

class _CategoryTotalsWidgetState extends State<CategoryTotalsWidget> {
  final sharedPrefsKey = 'categoryTrendChart_visibleCategories';
  final currencyFormatter =
      NumberFormat.simpleCurrency(name: 'USD', decimalDigits: 2);
  late Set<String> _visibleCategories = {};
  SharedPreferences? _prefs;
  bool _isInitialized = false;
  String? _currentTimePeriod;

  @override
  void initState() {
    super.initState();
    _initializePrefs();
  }

  Future<void> _initializePrefs() async {
    _prefs = await SharedPreferences.getInstance();
    setState(() {
      _isInitialized = true;
    });
  }

  Future<void> _saveCategories() async {
    if (_prefs != null) {
      await _prefs!.setStringList(sharedPrefsKey, _visibleCategories.toList());
    }
  }

  Future<void> _loadCategories(String timePeriod) async {
    if (_prefs != null) {
      final savedCategories = _prefs!.getStringList(sharedPrefsKey) ?? [];

      if (savedCategories.isNotEmpty) {
        setState(() {
          _visibleCategories = Set.from(savedCategories);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    var income = 0.0;
    var expenses = 0.0;
    for (var expense in expenseProvider.expenses) {
      if (expenseProvider.isIncome(expense.category)) {
        income += expense.cost;
      } else {
        expenses += expense.cost;
      }
    }

    // Get all unique categories from expenses
    final allCategories =
        expenseProvider.expenses.map((e) => e.category).toSet().toList();

    // Check if time period changed and reload categories for new period
    if (_isInitialized &&
        _currentTimePeriod != expenseProvider.selectedTimePeriod.toString()) {
      _currentTimePeriod = expenseProvider.selectedTimePeriod.toString();
      _loadCategories(_currentTimePeriod!);
    } else if (_isInitialized && _currentTimePeriod == null) {
      // First build after initialization
      _currentTimePeriod = expenseProvider.selectedTimePeriod.toString();
      _loadCategories(_currentTimePeriod!);
    }

    // Initialize visible categories if empty (first time or no saved data)
    if (_visibleCategories.isEmpty && allCategories.isNotEmpty) {
      _visibleCategories = Set.from(allCategories);
    }

    if (expenseProvider.expenses.isEmpty) {
      return Card(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'No data available for the selected period',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      );
    }

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () => _showCategoryToggleSheet(context, allCategories),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Category Totals',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Chip(
                    label: Text('${_visibleCategories.length} visible'),
                    onDeleted: () =>
                        _showCategoryToggleSheet(context, allCategories),
                  ),
                ],
              ),
            ),
          ),
          Row(
            spacing: 8,
            children: [
              Expanded(
                child: _getIncomeExpenseTile(
                    Colors.green, Icons.payments, 'Income', income),
              ),
              Expanded(
                child: _getIncomeExpenseTile(
                    Colors.red, Icons.money_off, 'Expenses', expenses),
              ),
            ],
          ),
          _buildCategoryTiles(context, expenseProvider),
        ],
      ),
    );
  }

  Widget _getIncomeExpenseTile(
      MaterialColor c, IconData icon, String title, double total) {
    return Card(
      color: c.shade100,
      child: Padding(
        padding: EdgeInsets.all(5),
        child: Row(
          spacing: 5,
          children: [
            Icon(icon, color: c, size: 25),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: c.shade700,
                        fontWeight: FontWeight.bold,
                      )),
              Text(currencyFormatter.format(total),
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: c.shade700,
                      )),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryTiles(
    BuildContext context,
    ExpenseProvider expenseProvider,
  ) {
    final visibleCategoryList = _visibleCategories.toList();

    // Sort with income categories first (true values first)
    visibleCategoryList.sort((a, b) {
      final aIsIncome = expenseProvider.isIncome(a);
      final bIsIncome = expenseProvider.isIncome(b);

      if (aIsIncome && !bIsIncome) return -1; // a comes first (income)
      if (!aIsIncome && bIsIncome) return 1; // b comes first (income)
      return a.compareTo(b); // alphabetical sort within same type
    });

    if (visibleCategoryList.isEmpty) {
      return Center(
        child: Text(
          'No categories selected',
          style: Theme.of(context).textTheme.bodySmall,
        ),
      );
    }

    return Column(
      children: visibleCategoryList.map((category) {
        return _buildCategoryTile(
          context,
          category,
          expenseProvider,
        );
      }).toList(),
    );
  }

  Widget _buildCategoryTile(
    BuildContext context,
    String category,
    ExpenseProvider expenseProvider,
  ) {
    double totalAmount = 0.0;
    for (final expense in expenseProvider.expenses) {
      if (expense.category == category) {
        totalAmount += expense.cost;
      }
    }

    if (totalAmount == 0.0) {
      return const SizedBox.shrink();
    }

    final isIncome = expenseProvider.isIncome(category);
    final categoryIcon = isIncome ? Icons.payments : Icons.money_off;
    final categoryIconColor =
        isIncome ? expenseProvider.incomeColor : expenseProvider.expenseColor;

    return Card(
      elevation: 1,
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 12.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 8,
          children: [
            // Category icon
            Icon(
              categoryIcon,
              color: categoryIconColor,
              size: 24,
            ),
            // Category name
            SizedBox(
              width: 100,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    category,
                    style: Theme.of(context).textTheme.labelLarge,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.end,
                spacing: 4,
                children: [
                  Text(
                    currencyFormatter.format(totalAmount),
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: expenseProvider.isIncome(category)
                              ? expenseProvider.incomeColor
                              : expenseProvider.expenseColor,
                        ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCategoryToggleSheet(
    BuildContext context,
    List<String> allCategories,
  ) {
    final expenseProvider =
        Provider.of<ExpenseProvider>(context, listen: false);

    // Sort categories with income first
    final sortedCategories = allCategories.toList();
    sortedCategories.sort((a, b) {
      final aIsIncome = expenseProvider.isIncome(a);
      final bIsIncome = expenseProvider.isIncome(b);

      if (aIsIncome && !bIsIncome) return -1; // a comes first (income)
      if (!aIsIncome && bIsIncome) return 1; // b comes first (income)
      return a.compareTo(b); // alphabetical sort within same type
    });

    showModalBottomSheet(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: DraggableScrollableSheet(
                expand: false,
                builder: (context, scrollController) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Select Categories to Display',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),
                        Flexible(
                          child: ListView.builder(
                            controller: scrollController,
                            itemCount: sortedCategories.length,
                            itemBuilder: (context, index) {
                              final category = sortedCategories[index];
                              final isVisible =
                                  _visibleCategories.contains(category);
                              final isIncome =
                                  expenseProvider.isIncome(category);

                              // Add divider between income and expense categories
                              bool showDivider = false;
                              if (index > 0) {
                                final prevIsIncome = expenseProvider
                                    .isIncome(sortedCategories[index - 1]);
                                if (isIncome != prevIsIncome) {
                                  showDivider = true;
                                }
                              }

                              return Column(
                                children: [
                                  if (showDivider)
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 8.0),
                                      child: Divider(
                                        height: 1,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .outline
                                            .withAlpha(100),
                                      ),
                                    ),
                                  CheckboxListTile(
                                    title: Text(category),
                                    value: isVisible,
                                    onChanged: (value) async {
                                      setState(() {
                                        if (value == true) {
                                          _visibleCategories.add(category);
                                        } else {
                                          _visibleCategories.remove(category);
                                        }
                                      });
                                      // Save to SharedPreferences
                                      await _saveCategories();
                                      // Rebuild parent to update chart
                                      this.setState(() {});
                                    },
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            FilledButton.tonal(
                              onPressed: () async {
                                setState(() {
                                  _visibleCategories = Set.from(allCategories);
                                });
                                // Save to SharedPreferences
                                await _saveCategories();
                                this.setState(() {});
                              },
                              child: const Text('Select All'),
                            ),
                            FilledButton.tonal(
                              onPressed: () async {
                                setState(() {
                                  _visibleCategories.clear();
                                });
                                // Save to SharedPreferences
                                await _saveCategories();
                                this.setState(() {});
                              },
                              child: const Text('Clear All'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Done'),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    ).then((_) {
      // Rebuild the widget when sheet is dismissed
      setState(() {});
    });
  }
}
