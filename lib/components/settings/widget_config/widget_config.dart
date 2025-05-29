import 'package:expense_manager/providers/dashboard_widgets_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:provider/provider.dart';

class WidgetConfig extends StatefulWidget {
  const WidgetConfig({super.key});

  @override
  State<StatefulWidget> createState() => _WidgetConfigState();
}

class _WidgetConfigState extends State<WidgetConfig> {
  @override
  Widget build(BuildContext context) {
    final dashboardWidgetProvider =
        Provider.of<DashboardWidgetsProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Widget Configuration')),
      body: SingleChildScrollView(
          child: StaggeredGrid.count(
        axisDirection: AxisDirection.down,
        crossAxisCount: 2,
        mainAxisSpacing: 1,
        crossAxisSpacing: 2,
        children: dashboardWidgetProvider.widgetsWithConfig.entries
            .map((e) => e.key.getWidgetTile(
                  crossAxisCellCount: e.value.size.item1,
                  mainAxisCellCount: e.value.size.item2,
                  showVisibilityToggle: true,
                  isEnabled: e.value.isEnabled,
                  onChanged: (value) {
                    dashboardWidgetProvider.updateWidgetVisibility(
                        e.key, value);
                  },
                ))
            .toList(),
      )),
    );
  }
}
