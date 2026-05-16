import 'package:flutter/material.dart';

class AppThemeNotifier extends ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  void toggle() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }

  bool get isDark => _mode == ThemeMode.dark;
}

final appTheme = AppThemeNotifier();
