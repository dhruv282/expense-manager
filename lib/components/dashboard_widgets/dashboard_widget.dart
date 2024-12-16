import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

abstract class DashboardWidget {
  Widget getWidget();

  StaggeredGridTile getWidgetTile({
    int crossAxisCellCount = 1,
    int mainAxisCellCount = 1,
  }) {
    return StaggeredGridTile.count(
      crossAxisCellCount: crossAxisCellCount,
      mainAxisCellCount: mainAxisCellCount,
      child: getWidget(),
    );
  }
}
