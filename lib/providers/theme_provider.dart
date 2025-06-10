import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  late final SharedPreferences prefs;
  final _themeColorKey = 'themeColor';
  final _themeModeKey = 'themeMode';
  Color _themeColor = Colors.cyan;
  ThemeMode _themeMode = ThemeMode.system;

  Color get themeColor => _themeColor;
  ThemeMode get themeMode => _themeMode;

  ThemeProvider() {
    SharedPreferences.getInstance().then((p) => prefs = p).then((v) {
      var color = prefs.getInt(_themeColorKey);
      if (color != null) {
        _themeColor = Color(color);
      }

      var mode = prefs.getString(_themeModeKey);
      if (mode != null) {
        _themeMode = ThemeMode.values.firstWhere((m) => m.name == mode);
      }
    }).whenComplete(() => notifyListeners());
  }

  void updateThemeColor(Color c) {
    _themeColor = c;
    prefs.setInt(_themeColorKey, c.toARGB32());
    notifyListeners();
  }

  void updateThemeMode(ThemeMode m) {
    _themeMode = m;
    prefs.setString(_themeModeKey, m.name);
    notifyListeners();
  }
}
