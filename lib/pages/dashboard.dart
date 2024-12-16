import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/dashboard_widgets/expense_pie_chart.dart';
import 'package:expense_manager/components/dashboard_widgets/expense_vs_income_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final List<DashboardWidget> widgets = [
    ExpensePieChart(),
    ExpenseVsIncomePieChart(),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: StaggeredGrid.count(
      axisDirection: AxisDirection.down,
      crossAxisCount: 2,
      mainAxisSpacing: 1,
      crossAxisSpacing: 2,
      children: widgets.map((w) => w.getWidgetTile()).toList(),
    ));
  }
}
