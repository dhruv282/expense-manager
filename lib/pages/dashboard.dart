import 'package:expense_manager/components/dashboard_widgets/category_totals.dart';
import 'package:expense_manager/components/dashboard_widgets/pending_transactions.dart';
import 'package:expense_manager/providers/dashboard_widget_config.dart';
import 'package:expense_manager/providers/dashboard_widgets_provider.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  void _showFullscreenWidget(
    BuildContext context,
    DashboardWidgetId id,
  ) {
    showDialog(
      context: context,
      builder: (context) => Dialog.fullscreen(
        child: Material(
          child: Stack(
            children: [
              Column(
                children: [
                  AppBar(
                    title: Text(id.displayName),
                    leading: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                    elevation: 0,
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: id.getWidget(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardWidgetProvider =
        Provider.of<DashboardWidgetsProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);

    if (!dashboardWidgetProvider.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    final sortedWidgets = dashboardWidgetProvider.getSortedConfigs();
    final enabledWidgets =
        sortedWidgets.where((e) => e.value.isEnabled).toList();

    return SingleChildScrollView(
      child: Column(
        children: [
          if (expenseProvider.pendingTransactions.isNotEmpty) ...[
            PendingTransactionsWidget()
          ],
          CategoryTotalsWidget(),
          if (enabledWidgets.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.dashboard_customize, size: 48),
                    const SizedBox(height: 16),
                    const Text('No widgets enabled'),
                    const SizedBox(height: 8),
                    Text(
                      'Go to Widget Settings to manage widgets',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            )
          else
            StaggeredGrid.count(
              axisDirection: AxisDirection.down,
              crossAxisCount: 2,
              mainAxisSpacing: 1,
              crossAxisSpacing: 2,
              children: enabledWidgets
                  .map((e) => StaggeredGridTile.count(
                        crossAxisCellCount: e.value.size.$1,
                        mainAxisCellCount: e.value.size.$2,
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Widget title bar
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .appBarTheme
                                      .backgroundColor,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(4),
                                    topRight: Radius.circular(4),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        e.key.displayName,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.fullscreen,
                                        size: 24,
                                      ),
                                      tooltip: 'View fullscreen',
                                      onPressed: () =>
                                          _showFullscreenWidget(context, e.key),
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(
                                        minWidth: 32,
                                        minHeight: 32,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Widget content
                              Expanded(
                                child: SizedBox.expand(
                                  child: Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: e.key.getWidget(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ))
                  .toList(),
            ),
        ],
      ),
    );
  }
}
