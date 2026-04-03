import 'package:expense_manager/components/dashboard_widgets/expense_pie_chart.dart';
import 'package:expense_manager/components/dashboard_widgets/expense_vs_income_line_chart.dart';
import 'package:expense_manager/components/dashboard_widgets/expense_vs_income_pie_chart.dart';
import 'package:flutter/material.dart';

enum DashboardWidgetId {
  expensePieChart,
  expenseVsIncomePie,
  expenseVsIncomeLineChart,
}

extension DashboardWidgetIdExtension on DashboardWidgetId {
  String get persistenceKey => 'widget_${name}_enabled';
  String get orderPersistenceKey => 'widget_${name}_order';
  String get sizePersistenceKey => 'widget_${name}_size';

  String get displayName {
    return switch (this) {
      DashboardWidgetId.expensePieChart => 'Expense Distribution',
      DashboardWidgetId.expenseVsIncomePie => 'Expense vs Income',
      DashboardWidgetId.expenseVsIncomeLineChart => 'Expense Trends',
    };
  }

  (int, int) get defaultSize {
    return switch (this) {
      DashboardWidgetId.expensePieChart => (2, 2),
      DashboardWidgetId.expenseVsIncomePie => (2, 2),
      DashboardWidgetId.expenseVsIncomeLineChart => (2, 1),
    };
  }

  Widget getWidget() {
    return switch (this) {
      DashboardWidgetId.expensePieChart => ExpensePieChart().getWidget(),
      DashboardWidgetId.expenseVsIncomePie =>
        ExpenseVsIncomePieChart().getWidget(),
      DashboardWidgetId.expenseVsIncomeLineChart =>
        ExpenseVsIncomeLineChart().getWidget(),
    };
  }
}

class WidgetConfig {
  final DashboardWidgetId id;
  final (int, int) size;
  bool isEnabled;
  int order;

  WidgetConfig({
    required this.id,
    required this.size,
    required this.isEnabled,
    required this.order,
  });

  WidgetConfig copyWith({
    bool? isEnabled,
    int? order,
    (int, int)? size,
  }) {
    return WidgetConfig(
      id: id,
      size: size ?? this.size,
      isEnabled: isEnabled ?? this.isEnabled,
      order: order ?? this.order,
    );
  }

  @override
  String toString() =>
      'WidgetConfig(id: $id, size: $size, isEnabled: $isEnabled, order: $order)';
}
