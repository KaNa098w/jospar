import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jospar/core/constants/constants.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DeviceRegistrationService {
  DeviceRegistrationService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;

  Future<void> ensureGuestRegistered({required String deviceId}) async {
    final preferences = await SharedPreferences.getInstance();
    final registrationKey = 'registered_guest_device:$deviceId';
    if (preferences.getBool(registrationKey) == true) return;

    final response = await _client.post(
      Uri.parse('${Constants.baseUrl}/v1/devices'),
      headers: const {
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'device_id': deviceId}),
    );
    if ((response.statusCode >= 200 && response.statusCode < 300) ||
        response.statusCode == 409) {
      await preferences.setBool(registrationKey, true);
      return;
    }
    throw DeviceRegistrationException(response.statusCode, response.body);
  }

  Future<void> ensureRegistered({
    required String token,
    required String userId,
    required String deviceId,
    bool force = false,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    final registrationKey = 'registered_device:$userId:$deviceId';
    if (!force && preferences.getBool(registrationKey) == true) return;

    final response = await _client.post(
      Uri.parse('${Constants.baseUrl}/v1/devices'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'device_id': deviceId}),
    );
    if ((response.statusCode >= 200 && response.statusCode < 300) ||
        response.statusCode == 409) {
      await preferences.setBool(registrationKey, true);
      return;
    }
    throw DeviceRegistrationException(
      response.statusCode,
      response.body,
    );
  }
}

class DeviceRegistrationException implements Exception {
  const DeviceRegistrationException(this.statusCode, this.body);

  final int statusCode;
  final String body;

  @override
  String toString() => 'Device registration failed ($statusCode): $body';
}
