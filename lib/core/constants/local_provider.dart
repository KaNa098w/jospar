import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Простой провайдер локали с сохранением в SharedPreferences.
class LocaleProvider extends ChangeNotifier {
  static const String _prefsKey = 'app_locale_code';
  Locale _locale = const Locale('kk');

  Locale get locale => _locale;

  Future<void> load() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? code = prefs.getString(_prefsKey);
    if (code != null && code.isNotEmpty) {
      _locale = Locale(code);
      notifyListeners();
    }
  }

  Future<void> setLocale(Locale locale) async {
    _locale = locale;
    notifyListeners();
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
  }
}
