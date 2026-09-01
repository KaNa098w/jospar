import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:jospar/core/services/auth_interceptor.dart';
import 'package:jospar/core/services/auth_service.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('delete account sends authorized DELETE and accepts empty 204',
      () async {
    SharedPreferences.setMockInitialValues({'token': 'access-token'});
    final storage = AuthStorage();
    final dio = Dio(BaseOptions(baseUrl: 'https://jospar.kz/api'));
    dio.interceptors.add(AuthInterceptor(storage));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.method, 'DELETE');
          expect(options.path, '/v1/user');
          expect(options.data, isNull);
          expect(options.headers['Authorization'], 'Bearer access-token');
          expect(options.headers['Accept'], 'application/json');
          handler.resolve(
            Response<void>(
              requestOptions: options,
              statusCode: 204,
            ),
          );
        },
      ),
    );

    await AuthService(dio: dio, storage: storage).deleteAccount();
  });

  test('delete account exposes unauthorized status', () async {
    SharedPreferences.setMockInitialValues({'token': 'expired-token'});
    final dio = Dio(BaseOptions(baseUrl: 'https://jospar.kz/api'));
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          handler.reject(
            DioException(
              requestOptions: options,
              response: Response<void>(
                requestOptions: options,
                statusCode: 401,
              ),
            ),
          );
        },
      ),
    );

    expect(
      () => AuthService(dio: dio).deleteAccount(),
      throwsA(
        isA<AuthException>().having(
          (error) => error.statusCode,
          'statusCode',
          401,
        ),
      ),
    );
  });
}
