import 'package:expense_manager/providers/expense_provider.dart';
import 'package:expense_manager/utils/logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future showAddCategoryDialog(context, String dialogTitle, String dialogHintText,
    Future Function(String val, bool isIncome) onAdd, Function onAddError) {
  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCategoryDialog(
          dialogTitle: dialogTitle,
          dialogHintText: dialogHintText,
          onAdd: onAdd,
          onAddError: onAddError,
        );
      });
}

class AddCategoryDialog extends StatefulWidget {
  final String dialogTitle;
  final String dialogHintText;
  final Future Function(String val, bool isIncome) onAdd;
  final Function onAddError;

  const AddCategoryDialog({
    super.key,
    required this.dialogTitle,
    required this.dialogHintText,
    required this.onAdd,
    required this.onAddError,
  });

  @override
  State<AddCategoryDialog> createState() => _AddCategoryDialogState();
}

class _AddCategoryDialogState extends State<AddCategoryDialog> {
  final TextEditingController controller = TextEditingController();
  var isIncome = false;

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    return AlertDialog(
      title: Text(widget.dialogTitle),
      content: Wrap(children: [
        Column(children: [
          TextField(
            controller: controller,
            decoration: InputDecoration(hintText: widget.dialogHintText),
          ),
          const SizedBox(height: 20),
          ToggleButtons(
            borderRadius: BorderRadius.circular(10),
            isSelected: [isIncome, !isIncome],
            onPressed: (index) {
              setState(() {
                isIncome = index == 0;
              });
            },
            children: [
              Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(spacing: 10, children: [
                    Icon(
                      Icons.payments,
                      color: expenseProvider.incomeColor,
                    ),
                    Text('Income')
                  ])),
              Padding(
                  padding: EdgeInsets.only(left: 10, right: 10),
                  child: Row(spacing: 10, children: [
                    Icon(
                      Icons.money_off,
                      color: expenseProvider.expenseColor,
                    ),
                    Text('Expense')
                  ])),
            ],
          ),
        ])
      ]),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            String val = controller.text.trim();
            if (val.isNotEmpty) {
              widget.onAdd(val, isIncome).then((value) {
                if (context.mounted) {
                  Navigator.pop(context);
                }
              }).catchError((error) {
                logger.e(error);
                widget.onAddError();
              });
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
