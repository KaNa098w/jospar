// app_theme_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jospar/app/utils/theme.dart'; // ThemeColors

class AppThemeProvider extends ChangeNotifier {
  static const _prefsKeyPrimary = 'app_primary_color_argb';
  static const _prefsKeyMode = 'app_theme_mode';
  Color _primary = ThemeColors.primary;
  ThemeMode _mode = ThemeMode.light;

  Color get primary => _primary;
  ThemeMode get mode => _mode;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final argb = prefs.getInt(_prefsKeyPrimary);
    if (argb != null) {
      _primary = Color(argb);
      ThemeColors.primary = _primary;
    }
    _mode = switch (prefs.getString(_prefsKeyMode)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.light,
    };
    notifyListeners();
  }

  Future<void> setPrimary(Color color) async {
    _primary = color;
    ThemeColors.primary = color; // обновляем глобальный статический цвет
    notifyListeners(); // просим MaterialApp/виджеты перестроиться
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKeyPrimary, color.toARGB32());
  }

  Future<void> setMode(ThemeMode mode) async {
    _mode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKeyMode, mode.name);
  }
}
