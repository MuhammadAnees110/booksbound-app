import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  static const String _themePrefKey = 'themeMode';

  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider({ThemeMode? initialTheme}) {
    if (initialTheme != null) {
      _themeMode = initialTheme;
    } else {
      _loadThemePreference();
    }
  }

  Future<void> _loadThemePreference() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString(_themePrefKey);
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'dark':
            _themeMode = ThemeMode.dark;
            break;
          case 'light':
            _themeMode = ThemeMode.light;
            break;
          default:
            _themeMode = ThemeMode.system;
        }
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setTheme(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      final value = mode == ThemeMode.dark
          ? 'dark'
          : (mode == ThemeMode.light ? 'light' : 'system');
      await prefs.setString(_themePrefKey, value);
    } catch (_) {}
  }

  Future<void> toggleTheme() async {
    if (_themeMode == ThemeMode.dark) {
      await setTheme(ThemeMode.light);
    } else {
      await setTheme(ThemeMode.dark);
    }
  }
}
