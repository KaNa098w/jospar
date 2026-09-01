import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jospar/core/services/device_registration_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('guest device registration is unauthenticated and idempotent', () async {
    SharedPreferences.setMockInitialValues({});
    var calls = 0;
    final service = DeviceRegistrationService(
      client: MockClient((request) async {
        calls++;
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/devices');
        expect(request.headers['Authorization'], isNull);
        expect(jsonDecode(request.body), {'device_id': 'device-1'});
        return http.Response('{}', 201);
      }),
    );

    await service.ensureGuestRegistered(deviceId: 'device-1');
    await service.ensureGuestRegistered(deviceId: 'device-1');

    expect(calls, 1);
  });

  test('device registration is authenticated and idempotent locally', () async {
    SharedPreferences.setMockInitialValues({});
    var calls = 0;
    final service = DeviceRegistrationService(
      client: MockClient((request) async {
        calls++;
        expect(request.method, 'POST');
        expect(request.url.path, '/api/v1/devices');
        expect(request.headers['Authorization'], 'Bearer token');
        expect(jsonDecode(request.body), {'device_id': 'device-1'});
        return http.Response('{}', 201);
      }),
    );

    await service.ensureRegistered(
      token: 'token',
      userId: 'user-1',
      deviceId: 'device-1',
    );
    await service.ensureRegistered(
      token: 'token',
      userId: 'user-1',
      deviceId: 'device-1',
    );

    expect(calls, 1);
  });

  test('authenticated device registration can be forced after social login',
      () async {
    SharedPreferences.setMockInitialValues({
      'registered_device:user-1:device-1': true,
    });
    var calls = 0;
    final service = DeviceRegistrationService(
      client: MockClient((request) async {
        calls++;
        expect(request.headers['Authorization'], 'Bearer new-token');
        expect(jsonDecode(request.body), {'device_id': 'device-1'});
        return http.Response('{}', 200);
      }),
    );

    await service.ensureRegistered(
      token: 'new-token',
      userId: 'user-1',
      deviceId: 'device-1',
      force: true,
    );

    expect(calls, 1);
  });
}
