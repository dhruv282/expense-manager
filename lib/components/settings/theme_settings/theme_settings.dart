import 'package:expense_manager/components/form_helpers/form_dropdown.dart';
import 'package:expense_manager/components/settings/theme_settings/constants.dart';
import 'package:expense_manager/providers/theme_provider.dart';
import 'package:flex_color_picker/flex_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ThemeSettings extends StatefulWidget {
  const ThemeSettings({super.key});

  @override
  State<StatefulWidget> createState() => _ThemeSettings();
}

class _ThemeSettings extends State<ThemeSettings> {
  final themeModeOptions = {
    'System': ThemeMode.system,
    'Dark': ThemeMode.dark,
    'Light': ThemeMode.light,
  };
  final themeModeController = TextEditingController();
  Color color = Colors.cyan;
  bool initialLoad = true;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    if (initialLoad) {
      themeModeController.text = themeModeOptions.entries
          .firstWhere((t) => t.value == themeProvider.themeMode)
          .key;
      setState(() {
        color = themeProvider.themeColor;
        initialLoad = false;
      });
    }
    return Scaffold(
        appBar: AppBar(title: const Text('Theme Settings')),
        body: Padding(
          padding: EdgeInsets.all(10),
          child: Column(
            children: [
              CustomFormDropdown(
                options: themeModeOptions.keys.toList(),
                labelText: themeModeFormFieldLabel,
                controller: themeModeController,
                onChanged: (String v) {
                  themeProvider.updateThemeMode(themeModeOptions[v]!);
                },
              ),
              const SizedBox(height: 20),
              ColorPicker(
                color: color,
                width: 50,
                height: 50,
                heading: Text(
                  'Select Theme Color',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                pickersEnabled: {
                  ColorPickerType.primary: true,
                  ColorPickerType.accent: false,
                },
                showColorName: true,
                colorNameTextStyle: Theme.of(context).textTheme.titleLarge,
                enableShadesSelection: false,
                onColorChanged: (c) {
                  setState(() => color = c);
                  themeProvider.updateThemeColor(c);
                },
              )
            ],
          ),
        ));
  }
}
