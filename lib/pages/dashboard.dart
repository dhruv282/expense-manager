import 'package:expense_manager/providers/dashboard_widgets_provider.dart';
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
    final widgetsWithConfig = dashboardWidgetProvider.widgetsWithConfig.entries
        .where((e) => e.value.isEnabled);
    return SingleChildScrollView(
        child: StaggeredGrid.count(
      axisDirection: AxisDirection.down,
      crossAxisCount: 2,
      mainAxisSpacing: 1,
      crossAxisSpacing: 2,
      children: widgetsWithConfig
          .map((e) => e.key.getWidgetTile(
              crossAxisCellCount: e.value.size.item1,
              mainAxisCellCount: e.value.size.item2))
          .toList(),
    ));
  }
}
