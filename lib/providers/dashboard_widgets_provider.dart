import 'package:expense_manager/components/dashboard_widgets/dashboard_widget.dart';
import 'package:expense_manager/components/dashboard_widgets/expense_and_income_summary.dart';
import 'package:expense_manager/components/dashboard_widgets/expense_pie_chart.dart';
import 'package:expense_manager/components/dashboard_widgets/expense_vs_income_line_chart.dart';
import 'package:expense_manager/components/dashboard_widgets/expense_vs_income_pie_chart.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tuple/tuple.dart';

class DashboardWidgetsProvider extends ChangeNotifier {
  late final SharedPreferences prefs;
  final Map<DashboardWidget, WidgetConfig> _widgetsWithConfig = {
    ExpensePieChart(): WidgetConfig(size: Tuple2(1, 1), isEnabled: true),
    ExpenseVsIncomePieChart():
        WidgetConfig(size: Tuple2(1, 1), isEnabled: true),
    ExpenseAndIncomeSummary():
        WidgetConfig(size: Tuple2(1, 1), isEnabled: true),
    ExpenseVsIncomeLineChart():
        WidgetConfig(size: Tuple2(2, 1), isEnabled: true),
  };

  Map<DashboardWidget, WidgetConfig> get widgetsWithConfig =>
      _widgetsWithConfig;

  DashboardWidgetsProvider() {
    SharedPreferences.getInstance().then((p) => prefs = p).then((_) {
      for (var w in _widgetsWithConfig.entries) {
        var enabled = prefs.getBool(w.key.runtimeType.toString());
        if (enabled != null) {
          w.value.isEnabled = enabled;
        }
      }
    }).whenComplete(() => notifyListeners());
  }

  void updateWidgetVisibility(DashboardWidget widget, bool isEnabled) {
    if (_widgetsWithConfig.containsKey(widget)) {
      _widgetsWithConfig[widget]!.isEnabled = isEnabled;
      prefs.setBool(widget.runtimeType.toString(), isEnabled);
      notifyListeners();
    }
  }
}

class WidgetConfig {
  Tuple2<int, int> size;
  bool isEnabled;
  WidgetConfig({required this.size, required this.isEnabled});
}
