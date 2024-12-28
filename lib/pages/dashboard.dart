import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/dashboard_widgets/expense_pie_chart.dart';
import 'package:expense_manager/components/dashboard_widgets/expense_vs_income_line_chart.dart';
import 'package:expense_manager/components/dashboard_widgets/expense_vs_income_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:tuple/tuple.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final Map<DashboardWidget, Tuple2<int, int>> widgetsWithSize = {
    ExpensePieChart(): const Tuple2(1, 1),
    ExpenseVsIncomePieChart(): const Tuple2(1, 1),
    ExpenseVsIncomeLineChart(): const Tuple2(2, 1),
  };

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: StaggeredGrid.count(
      axisDirection: AxisDirection.down,
      crossAxisCount: 2,
      mainAxisSpacing: 1,
      crossAxisSpacing: 2,
      children: widgetsWithSize.entries
          .map((e) => e.key.getWidgetTile(
              crossAxisCellCount: e.value.item1,
              mainAxisCellCount: e.value.item2))
          .toList(),
    ));
  }
}
