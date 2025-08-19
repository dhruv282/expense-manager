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
