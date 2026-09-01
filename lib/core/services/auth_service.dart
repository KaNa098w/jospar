import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:jospar/core/constants/constants.dart';
import 'package:jospar/core/models/auth_response.dart';
import 'package:jospar/core/services/auth_interceptor.dart';
import 'package:jospar/core/services/auth_storage.dart';

class AuthException implements Exception {
  const AuthException(this.code, this.message, {this.statusCode});

  final String code;
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class AuthService {
  AuthService({
    Dio? dio,
    AuthStorage? storage,
  })  : _storage = storage ?? AuthStorage(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: Constants.baseUrl,
              headers: const {
                'Accept': 'application/json',
                'Content-Type': 'application/json',
              },
            )) {
    if (dio == null) {
      _dio.interceptors.add(AuthInterceptor(_storage));
    }
  }

  final Dio _dio;
  final AuthStorage _storage;

  Future<AuthResponse> socialLogin({
    required String provider,
    required String token,
    String? deviceId,
    String? firstName,
    String? lastName,
  }) async {
    try {
      _debugLog(
        'POST /v1/auth/social '
        '(provider=$provider, providerTokenLength=${token.length}, '
        'deviceId=${deviceId == null ? 'absent' : 'present'})',
      );
      final response = await _dio.post<Map<String, dynamic>>(
        '/v1/auth/social',
        data: {
          'provider': provider,
          'token': token,
          if (deviceId != null && deviceId.isNotEmpty) 'device_id': deviceId,
          if (firstName != null && firstName.isNotEmpty)
            'first_name': firstName,
          if (lastName != null && lastName.isNotEmpty) 'last_name': lastName,
        },
      );
      _debugLog(
        'POST /v1/auth/social: response status=${response.statusCode}',
      );
      final data = response.data;
      if (data == null) {
        throw const AuthException(
          'invalid_response',
          'Сервер вернул пустой ответ.',
        );
      }
      final result = AuthResponse.fromJson(data);
      final accessToken = result.token;
      if (accessToken == null || accessToken.isEmpty) {
        throw const AuthException(
          'invalid_response',
          'Сервер не вернул токен авторизации.',
        );
      }
      await _storage.setToken(accessToken);
      _debugLog(
        'social login: success '
        '(userId=${result.user?.id ?? 'absent'}, '
        'accessTokenLength=${accessToken.length})',
      );
      return result;
    } on DioException catch (error) {
      _debugLog(
        'POST /v1/auth/social: DioException '
        '(status=${error.response?.statusCode}, data=${error.response?.data})',
      );
      throw _mapDioError(error);
    }
  }

  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get<Map<String, dynamic>>('/v1/user');
      final data = response.data;
      if (data == null) {
        throw const AuthException(
          'invalid_response',
          'Сервер вернул пустой ответ.',
        );
      }
      return User.fromJson(data['user'] is Map
          ? (data['user'] as Map).cast<String, dynamic>()
          : data);
    } on DioException catch (error) {
      throw _mapDioError(error);
    }
  }

  Future<void> deleteAccount() async {
    try {
      final response = await _dio.delete<void>('/v1/user');
      if (response.statusCode != 204) {
        throw AuthException(
          'invalid_response',
          'Сервер не подтвердил удаление аккаунта.',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (error) {
      throw _mapDioError(
        error,
        fallbackMessage:
            'Не удалось удалить аккаунт. Проверьте подключение и повторите.',
      );
    }
  }

  Future<void> logout() => _storage.clearToken();

  AuthException _mapDioError(
    DioException exception, {
    String fallbackMessage =
        'Не удалось выполнить вход. Проверьте подключение к интернету.',
  }) {
    final data = exception.response?.data;
    final error = data is Map ? data['error'] : null;
    final code = error is Map ? error['code']?.toString() : null;
    final message = error is Map ? error['message']?.toString() : null;
    return AuthException(
      code ?? 'network_error',
      message ?? fallbackMessage,
      statusCode: exception.response?.statusCode,
    );
  }

  static void _debugLog(String message) {
    if (kDebugMode) debugPrint('[AuthApi] $message');
  }
}
