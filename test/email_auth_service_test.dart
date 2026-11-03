import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/core/services/auth_service.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('login sends credentials and device id, then stores token', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://jospar.kz/api'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.path, '/v1/auth/login');
      expect(options.data, {
        'email': 'reviewer@example.com',
        'password': 'review-password',
        'device_id': 'device-1',
      });
      handler.resolve(Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: 200,
        data: {
          'token': '1|sanctum-token',
          'user': {'id': 'user-1', 'email': 'reviewer@example.com'},
        },
      ));
    }));

    final storage = AuthStorage();
    final response = await AuthService(dio: dio, storage: storage).login(
      email: 'reviewer@example.com',
      password: 'review-password',
      deviceId: 'device-1',
    );

    expect(response.user?.id, 'user-1');
    expect(await storage.getToken(), '1|sanctum-token');
  });

  test('register sends confirmation and optional names', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://jospar.kz/api'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      expect(options.path, '/v1/auth/register');
      expect(options.data, containsPair('password_confirmation', 'password1'));
      expect(options.data, containsPair('first_name', 'Google'));
      expect(options.data, isNot(contains('device_id')));
      handler.resolve(Response<Map<String, dynamic>>(
        requestOptions: options,
        statusCode: 200,
        data: {
          'token': 'token',
          'user': {'id': 'user-2'}
        },
      ));
    }));

    await AuthService(dio: dio).register(
      email: 'reviewer@example.com',
      password: 'password1',
      passwordConfirmation: 'password1',
      firstName: 'Google',
    );
  });

  test('validation errors expose field details', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://jospar.kz/api'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.reject(DioException(
        requestOptions: options,
        response: Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 422,
          data: {
            'error': {
              'code': 'validation_error',
              'message': 'The given data was invalid.',
              'details': {
                'email': ['The email has already been taken.'],
              },
            },
          },
        ),
      ));
    }));

    expect(
      () => AuthService(dio: dio).login(email: 'a@b.co', password: 'password'),
      throwsA(
        isA<AuthException>().having((e) => e.statusCode, 'status', 422).having(
            (e) => e.details['email']?.first,
            'email error',
            'The email has already been taken.'),
      ),
    );
  });

  test('rate limit exposes retry duration', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://jospar.kz/api'));
    dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) {
      handler.reject(DioException(
        requestOptions: options,
        response: Response<Map<String, dynamic>>(
          requestOptions: options,
          statusCode: 429,
          headers: Headers.fromMap({
            'retry-after': ['45'],
          }),
          data: {
            'error': {
              'code': 'too_many_attempts',
              'message': 'Too many attempts.',
              'details': <String, dynamic>{},
            },
          },
        ),
      ));
    }));

    expect(
      () => AuthService(dio: dio).login(email: 'a@b.co', password: 'password'),
      throwsA(
        isA<AuthException>().having((e) => e.statusCode, 'status', 429).having(
            (e) => e.retryAfter, 'retry after', const Duration(seconds: 45)),
      ),
    );
  });
}
