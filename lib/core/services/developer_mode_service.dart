import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeveloperModeService {
  DeveloperModeService._();

  static const _enabledKey = 'developer_mode_enabled';
  static final ValueNotifier<bool> enabled = ValueNotifier<bool>(false);
  static bool _loaded = false;

  static Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final preferences = await SharedPreferences.getInstance();
    enabled.value = preferences.getBool(_enabledKey) ?? false;
  }

  static Future<void> enable() async {
    if (enabled.value) return;
    enabled.value = true;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_enabledKey, true);
  }
}
