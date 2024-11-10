import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/dashboard_widgets/pie_chart/widget_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class PieChart implements DashboardWidget {
  @override
  Widget getConfigPage() {
    return const Card();
  }

  @override
  StaggeredGridTile getWidgetTile() {
    return const StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: PieChartWidget(),
    );
  }
}
