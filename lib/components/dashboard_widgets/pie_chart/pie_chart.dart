import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/dashboard_widgets/pie_chart/widget_tile.dart';
import 'package:flutter/material.dart';

class PieChart extends DashboardWidget {
  @override
  Widget getConfigPage() {
    return const Card();
  }

  @override
  Widget getWidget() {
    return const PieChartWidget();
  }
}
