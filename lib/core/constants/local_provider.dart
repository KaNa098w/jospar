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
    _locale = Locale(const ['ru', 'kk', 'en'].contains(code) ? code! : 'kk');
    notifyListeners();
  }

  Future<void> setLocale(Locale locale) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, locale.languageCode);
    _locale = locale;
    notifyListeners();
  }
}
