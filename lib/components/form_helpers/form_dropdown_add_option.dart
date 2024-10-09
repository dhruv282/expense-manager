import 'package:expense_manager/utils/logger/logger.dart';
import 'package:flutter/material.dart';

DropdownMenuItem<String> getAddOptionDropdownItem(String val, String text) {
  return DropdownMenuItem(
    value: val,
    child: Row(
      children: [
        const Icon(Icons.add),
        const SizedBox(width: 10),
        Text(text),
      ],
    ),
  );
}

Future showAddDialog(context, String dialogTitle, String dialogHintText,
    Future Function(String val) onAdd, Function onAddError) {
  final TextEditingController controller = TextEditingController();

  return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(dialogTitle),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(hintText: dialogHintText),
          ),
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
                  onAdd(val).then((value) {
                    Navigator.of(context).pop();
                  }).catchError((error) {
                      logger.e(error);
                      onAddError();
                    });
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      });
}
