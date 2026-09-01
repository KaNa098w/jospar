import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class AuthStorage {
  static const _kToken = 'access_token';
  static const _kLegacyToken = 'token';
  static const _kDeviceId = 'deviceId';
  static const _kUserId = 'customerId';
  static const _secureStorage = FlutterSecureStorage();

  Future<String?> getToken() async {
    try {
      final secured = await _secureStorage.read(key: _kToken);
      if (secured != null && secured.isNotEmpty) return secured;
    } on PlatformException {
      // Fall through to the legacy storage on unsupported test environments.
    } on MissingPluginException {
      // Fall through to the legacy storage on unsupported test environments.
    }

    final preferences = await SharedPreferences.getInstance();
    final legacy = preferences.getString(_kLegacyToken);
    if (legacy == null || legacy.isEmpty) return null;
    await setToken(legacy);
    return legacy;
  }

  Future<void> setToken(String token) async {
    var storedSecurely = false;
    try {
      await _secureStorage.write(key: _kToken, value: token);
      storedSecurely = true;
    } on PlatformException {
      // SharedPreferences is retained as a fallback for unsigned simulators.
    } on MissingPluginException {
      // SharedPreferences is retained as a fallback for unsigned simulators.
    }
    final preferences = await SharedPreferences.getInstance();
    if (storedSecurely) {
      await preferences.remove(_kLegacyToken);
    } else {
      await preferences.setString(_kLegacyToken, token);
    }
  }

  Future<void> clearToken() async {
    try {
      await _secureStorage.delete(key: _kToken);
    } on PlatformException {
      // The fallback is still cleared below.
    } on MissingPluginException {
      // The fallback is still cleared below.
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_kLegacyToken);
  }

  Future<void> clearAll() async {
    try {
      await _secureStorage.deleteAll();
    } on PlatformException {
      // SharedPreferences is still cleared below.
    } on MissingPluginException {
      // SharedPreferences is still cleared below.
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.clear();
  }

  Future<String?> getDeviceId() async {
    final secured = await _readSecureDeviceId();
    if (secured != null && secured.isNotEmpty) return secured;

    final p = await SharedPreferences.getInstance();
    final d = p.getString(_kDeviceId);
    if (d != null && d.isNotEmpty) {
      await _writeSecureDeviceId(d);
      return d;
    }
    return null;
  }

  Future<String?> getUserId() async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(_kUserId);
    return value == null || value.isEmpty ? null : value;
  }

  Future<void> setUserId(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    if (userId.isEmpty) {
      await preferences.remove(_kUserId);
    } else {
      await preferences.setString(_kUserId, userId);
    }
  }

  Future<String> getAccountId() async => await getUserId() ?? 'anonymous';

  Future<String> ensureDeviceId() async {
    final existing = await getDeviceId();
    if (existing != null) return existing;

    final id = const Uuid().v4();
    await _writeSecureDeviceId(id);

    // Keep the existing provider and device registration flow compatible.
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_kDeviceId, id);
    return id;
  }

  Future<String?> _readSecureDeviceId() async {
    try {
      return await _secureStorage.read(key: _kDeviceId);
    } on PlatformException {
      // Unsigned iOS simulator builds may not have Keychain entitlements.
      return null;
    } on MissingPluginException {
      // Unsigned iOS simulator builds may not have Keychain entitlements.
      return null;
    }
  }

  Future<void> _writeSecureDeviceId(String id) async {
    try {
      await _secureStorage.write(key: _kDeviceId, value: id);
    } on PlatformException {
      // SharedPreferences keeps the stable UUID when Keychain is unavailable.
    } on MissingPluginException {
      // SharedPreferences keeps the stable UUID when Keychain is unavailable.
    }
  }
}
