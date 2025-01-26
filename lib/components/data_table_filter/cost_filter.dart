import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:expense_manager/components/form_helpers/form_field.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

class CostFilter extends StatelessWidget {
  final Tuple2<TextEditingController, TextEditingController> costRangeFilter;
  const CostFilter({super.key, required this.costRangeFilter});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Text(
        "Cost",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      const SizedBox(height: 10),
      Row(
        children: [
          Expanded(
              child: CustomFormField(
                  enabled: true,
                  maxCharacters: null,
                  labelText: "From",
                  hintText: "Cost Filter Range Low",
                  icon: null,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatter: CurrencyTextInputFormatter.simpleCurrency(
                      enableNegative: false),
                  controller: costRangeFilter.item1,
                  onSaved: (val) {},
                  onChanged: (val) {},
                  validator: (val) => null,
                  obscureText: false)),
          const SizedBox(width: 20),
          Expanded(
              child: CustomFormField(
                  enabled: true,
                  maxCharacters: null,
                  labelText: "To",
                  hintText: "Cost Filter Range High",
                  icon: null,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  inputFormatter: CurrencyTextInputFormatter.simpleCurrency(
                      enableNegative: false),
                  controller: costRangeFilter.item2,
                  onSaved: (val) {},
                  onChanged: (val) {},
                  validator: (val) => null,
                  obscureText: false)),
        ],
      )
    ]);
  }
}
