import 'package:expense_manager/data/expense_data.dart';
import 'package:expense_manager/providers/expense_provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class PieChartWidget extends StatefulWidget {
  final Map<String, double> Function(List<ExpenseData>) getCategoryData;
  final String Function(List<ExpenseData>) getDefaultLabel;
  final List<Color>? colorList;
  const PieChartWidget(
      {super.key,
      required this.getCategoryData,
      required this.getDefaultLabel, this.colorList});

  @override
  State<StatefulWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget> {
  final currencyFormatter = NumberFormat.simpleCurrency();
  String touchedKey = "";

  @override
  Widget build(BuildContext context) {
    final colorList = widget.colorList ?? Colors.primaries;
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final Map<String, double> categoryTotals =
        widget.getCategoryData(expenseProvider.expenses);
    final List<PieChartSectionData> pieChartSectionData = [];
    for (var i = 0; i < categoryTotals.length; i++) {
      final key = categoryTotals.keys.toList()[i];
      final isTouched = touchedKey == key;
      pieChartSectionData.add(PieChartSectionData(
        showTitle: false,
        title: key,
        value: categoryTotals[key],
        color: isTouched ? Colors.transparent : colorList[i],
        borderSide: isTouched
            ? BorderSide(color: colorList[i], width: 2)
            : const BorderSide(color: Colors.transparent),
      ));
    }
    return Card(
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Stack(alignment: AlignmentDirectional.center, children: [
              PieChart(PieChartData(
                sections: pieChartSectionData,
                pieTouchData: PieTouchData(
                  touchCallback: (FlTouchEvent event, pieTouchResponse) {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      setState(() => touchedKey = "");
                      return;
                    }
                    final touchedIndex =
                        pieTouchResponse.touchedSection!.touchedSectionIndex;

                    if (touchedIndex >= 0) {
                      setState(() =>
                          touchedKey = pieChartSectionData[touchedIndex].title);
                    }
                  },
                ),
              )),
              Text(
                touchedKey.isEmpty
                    ? widget.getDefaultLabel(expenseProvider.expenses)
                    : "$touchedKey\n${currencyFormatter.format(categoryTotals[touchedKey])}",
                textAlign: TextAlign.center,
              ),
            ])));
  }
}
