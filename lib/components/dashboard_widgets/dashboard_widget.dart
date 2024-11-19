import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

abstract class DashboardWidget {
  Widget getConfigPage();

  Widget getWidget();

  StaggeredGridTile getWidgetTile() {
    return StaggeredGridTile.count(
      crossAxisCellCount: 1,
      mainAxisCellCount: 1,
      child: WidgetTileWrapper(child: getWidget()),
    );
  }
}

class WidgetTileWrapper extends StatefulWidget {
  final Widget child;
  const WidgetTileWrapper({super.key, required this.child});

  @override
  State<StatefulWidget> createState() => _WidgetTileWrapperState();
}

class _WidgetTileWrapperState extends State<WidgetTileWrapper> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: widget.child,
    );
  }
}
