import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

abstract class DashboardWidget {
  Widget getWidget();

  StaggeredGridTile getWidgetTile({
    int crossAxisCellCount = 1,
    int mainAxisCellCount = 1,
    bool showVisibilityToggle = false,
    bool isEnabled = true,
    void Function(bool)? onChanged,
  }) {
    return StaggeredGridTile.count(
      crossAxisCellCount: crossAxisCellCount,
      mainAxisCellCount: mainAxisCellCount,
      child: showVisibilityToggle
          ? Card(
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Switch(value: isEnabled, onChanged: onChanged),
                Expanded(child: getWidget()),
              ],
            ))
          : getWidget(),
    );
  }
}
