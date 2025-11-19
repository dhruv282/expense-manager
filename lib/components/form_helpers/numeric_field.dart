import 'package:flutter/material.dart';
import 'package:flutter_simple_calculator/flutter_simple_calculator.dart';
import 'package:intl/intl.dart';

class NumericField extends StatefulWidget {
  final TextEditingController controller;

  const NumericField({
    super.key,
    required this.controller,
  });

  @override
  State<NumericField> createState() => _NumericFieldState();
}

class _NumericFieldState extends State<NumericField> {
  late double total;
  final currencyFormatter =
      NumberFormat.simpleCurrency(name: 'USD', decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    total = double.tryParse(widget.controller.text) ?? 0;
    widget.controller.text = total.toStringAsFixed(2);
  }

  void _showCalculator(BuildContext c) {
    showModalBottomSheet(
        context: c,
        builder: (BuildContext context) {
          return SizedBox(
            height: MediaQuery.of(context).size.height * 0.75,
            child: SafeArea(
              child: SimpleCalculator(
                hideSurroundingBorder: true,
                theme: CalculatorThemeData(
                  displayColor: Theme.of(context).colorScheme.surfaceContainer,
                  expressionColor:
                      Theme.of(context).colorScheme.secondaryContainer,
                  operatorColor: Theme.of(context).colorScheme.primaryContainer,
                  commandColor: Theme.of(context).colorScheme.tertiaryContainer,
                ),
                value: total,
                onChanged: (key, value, expression) => setState(() {
                  total = value ?? 0;
                  widget.controller.text = total.toStringAsFixed(2);
                }),
              ),
            ),
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      child: Padding(
          padding: EdgeInsets.only(top: 15, bottom: 15),
          child: Row(spacing: 10, children: [
            const Icon(Icons.payments),
            Text(
              currencyFormatter.format(total),
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ])),
      onPressed: () => _showCalculator(context),
    );
  }
}
