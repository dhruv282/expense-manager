import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

abstract class DashboardWidget {
  Widget getConfigPage();

  StaggeredGridTile getWidgetTile();
}
