import 'package:expense_manager/components/dashboard_widgets/category_totals.dart';
import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/dashboard_widgets/pending_transactions.dart';
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
  @override
  Widget build(BuildContext context) {
    final dashboardWidgetProvider =
        Provider.of<DashboardWidgetsProvider>(context);
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    Map<DashboardWidget, WidgetConfig> widgetsWithConfig = {};

    widgetsWithConfig.addEntries(dashboardWidgetProvider
        .widgetsWithConfig.entries
        .where((e) => e.value.isEnabled));

    return SingleChildScrollView(
      child: Column(
        children: [
          if (expenseProvider.pendingTransactions.isNotEmpty) ...[
            PendingTransactionsWidget()
          ],
          // Fixed Category Trend Chart at the top
          CategoryTotalsWidget(),
          // Staggered grid for other widgets
          StaggeredGrid.count(
            axisDirection: AxisDirection.down,
            crossAxisCount: 2,
            mainAxisSpacing: 1,
            crossAxisSpacing: 2,
            children: widgetsWithConfig.entries
                .map((e) => e.key.getWidgetTile(
                    crossAxisCellCount: e.value.size.item1,
                    mainAxisCellCount: e.value.size.item2))
                .toList(),
          ),
        ],
      ),
    );
  }
}
