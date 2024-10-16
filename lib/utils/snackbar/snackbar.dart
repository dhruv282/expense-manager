import 'dart:collection';

import 'package:flutter/material.dart';

enum SnackBarColor { success, error }

final Map<SnackBarColor, Color> darkColorMap = HashMap.from({
  SnackBarColor.success: const Color.fromARGB(255, 0, 95, 0),
  SnackBarColor.error: const Color.fromARGB(255, 95, 0, 0),
});

final Map<SnackBarColor, Color> lightColorMap = HashMap.from({
  SnackBarColor.success: const Color.fromARGB(255, 0, 190, 0),
  SnackBarColor.error: const Color.fromARGB(255, 190, 0, 0),
});

void showSnackBar(
    BuildContext context, String text, SnackBarColor snackbarColor) {
  bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        text,
        style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
      ),
      backgroundColor: isDarkMode
          ? darkColorMap[snackbarColor]
          : lightColorMap[snackbarColor],
    ),
  );
}
