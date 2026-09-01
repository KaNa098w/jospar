import 'package:dio/dio.dart';
import 'package:jospar/core/services/auth_storage.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this.storage);

  final AuthStorage storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    options.headers['Accept'] = 'application/json';
    final token = await storage.getToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final data = err.response?.data;
    final error = data is Map ? data['error'] : null;
    final code = error is Map ? error['code'] : null;
    if (err.response?.statusCode == 401 && code == 'unauthenticated') {
      await storage.clearToken();
    }
    handler.next(err);
  }
}
