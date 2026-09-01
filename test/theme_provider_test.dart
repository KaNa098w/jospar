import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/core/constants/theme_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('light theme is used by default on first startup', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppThemeProvider();

    expect(provider.mode, ThemeMode.light);

    await provider.load();

    expect(provider.mode, ThemeMode.light);
  });

  test('theme mode is applied immediately and persisted', () async {
    SharedPreferences.setMockInitialValues({});
    final provider = AppThemeProvider();
    var notifications = 0;
    provider.addListener(() => notifications++);

    final persistence = provider.setMode(ThemeMode.dark);

    expect(provider.mode, ThemeMode.dark);
    expect(notifications, 1);
    await persistence;

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('app_theme_mode'), 'dark');
  });

  test('saved theme mode is restored on startup', () async {
    SharedPreferences.setMockInitialValues({'app_theme_mode': 'dark'});
    final provider = AppThemeProvider();

    await provider.load();

    expect(provider.mode, ThemeMode.dark);
  });
}
