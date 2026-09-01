import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:jospar/core/constants/constants.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:jospar/core/services/share_delivery_mode.dart';

class CollaborationService {
  CollaborationService({http.Client? client})
      : _client = client ?? http.Client();

  final http.Client _client;
  final AuthStorage _authStorage = AuthStorage();

  Future<Map<String, dynamic>> createInvite(
    String taskId, {
    required ShareDeliveryMode mode,
    String? role,
    int? expiresInSeconds,
    int? maxUses,
  }) {
    final resolvedRole =
        mode == ShareDeliveryMode.duplicate ? 'viewer' : (role ?? 'editor');
    return _request(
      'POST',
      '/tasks/$taskId/shares',
      body: {
        'role': resolvedRole,
        'mode': mode.queryValue,
        'expires_in_seconds': expiresInSeconds,
        'max_uses': maxUses,
      },
    );
  }

  Future<Map<String, dynamic>> inviteInfo(String hash) {
    return _request('GET', '/shares/$hash');
  }

  Future<Map<String, dynamic>> inviteTask(String hash) async {
    final response = await inviteInfo(hash);
    dynamic task = response['task'];
    final data = response['data'];
    if (task == null && data is Map) {
      task = data['task'] ?? data;
    }
    task ??= response;
    if (task is! Map || task['id'] == null) {
      throw const CollaborationException(
        statusCode: 500,
        code: 'invalid_response',
        message: 'Сервер не вернул задачу для копирования',
      );
    }
    return _normalizeTask(Map<String, dynamic>.from(task));
  }

  Future<Map<String, dynamic>> acceptInvite(String hash) async {
    Map<String, dynamic> response;
    try {
      response = await _request('POST', '/shares/$hash/accept');
    } on CollaborationException catch (error) {
      // Older backend versions returned 409 when the same account opened an
      // already accepted invitation. Treat it as an idempotent reopen and
      // fetch the current task instead.
      if (error.statusCode != 409) rethrow;
      return inviteTask(hash);
    }
    final task = response['task'];
    if (task is! Map) {
      throw const CollaborationException(
        statusCode: 500,
        code: 'invalid_response',
        message: 'Сервер не вернул совместную задачу',
      );
    }
    return _normalizeTask(Map<String, dynamic>.from(task));
  }

  static Map<String, dynamic> _normalizeTask(Map<String, dynamic> task) {
    final children = task['children'] ?? task['subtasks'];
    if (children is List) {
      task['children'] = children
          .whereType<Map>()
          .map((child) => _normalizeTask(Map<String, dynamic>.from(child)))
          .toList(growable: false);
    } else {
      task['children'] = <Map<String, dynamic>>[];
    }
    return task;
  }

  Future<List<Map<String, dynamic>>> collaborators(String taskId) async {
    final response = await _requestRaw('GET', '/tasks/$taskId/collaborators');
    final items = response is List
        ? response
        : response is Map
            ? response['items'] ?? response['collaborators'] ?? response['data']
            : null;
    if (items is! List) return const [];
    return items.whereType<Map>().map((item) {
      final normalized = Map<String, dynamic>.from(item);
      final user = item['user'];
      if (user is Map) {
        normalized['user_id'] ??= user['id'];
        normalized['name'] ??= _userName(user);
        normalized['email'] ??= user['email'];
        normalized['avatar_url'] ??= user['avatar_url'] ??
            user['photo_url'] ??
            user['picture'] ??
            user['avatar'];
      }
      return normalized;
    }).toList(growable: false);
  }

  static String? _userName(Map<dynamic, dynamic> user) {
    final direct = user['name']?.toString().trim();
    if (direct != null && direct.isNotEmpty) return direct;
    final fullName =
        '${user['first_name'] ?? ''} ${user['last_name'] ?? ''}'.trim();
    if (fullName.isNotEmpty) return fullName;
    return user['email']?.toString();
  }

  Future<void> updateRole(
    String taskId,
    String userId,
    String role,
  ) async {
    await _request(
      'PATCH',
      '/tasks/$taskId/collaborators/$userId',
      body: {'role': role},
    );
  }

  Future<void> removeCollaborator(String taskId, String userId) async {
    await _request('DELETE', '/tasks/$taskId/collaborators/$userId');
  }

  Future<void> leave(String taskId) async {
    await _request('DELETE', '/tasks/$taskId/collaborators/me');
  }

  Future<void> revokeInvite(String taskId, String inviteId) async {
    await _request('DELETE', '/tasks/$taskId/shares/$inviteId');
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _requestRaw(method, path, body: body);
    return response is Map
        ? Map<String, dynamic>.from(response)
        : <String, dynamic>{};
  }

  Future<dynamic> _requestRaw(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final token = await _authStorage.getToken();
    if (token == null) {
      throw const CollaborationException(
        statusCode: 401,
        code: 'unauthenticated',
        message: 'Необходимо войти в аккаунт',
      );
    }
    final request = http.Request(
      method,
      Uri.parse('${Constants.baseUrl}/v1$path'),
    )..headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      });
    if (body != null) request.body = jsonEncode(body);

    late final http.StreamedResponse streamed;
    try {
      streamed = await _client.send(request).timeout(
            const Duration(seconds: 12),
            onTimeout: () => throw const CollaborationException(
              statusCode: 408,
              code: 'request_timeout',
              message:
                  'Сервер не ответил вовремя. Проверьте интернет и попробуйте ещё раз.',
            ),
          );
    } on CollaborationException {
      rethrow;
    } catch (error) {
      throw CollaborationException(
        statusCode: 0,
        code: 'network_error',
        message: 'Не удалось подключиться к серверу: $error',
      );
    }
    final response = await http.Response.fromStream(streamed);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return const {};
      return jsonDecode(response.body);
    }

    String? code;
    String? message;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map && decoded['error'] is Map) {
        final error = decoded['error'] as Map;
        code = error['code']?.toString();
        message = error['message']?.toString();
      }
    } catch (_) {
      // Use the HTTP fallback below.
    }
    throw CollaborationException(
      statusCode: response.statusCode,
      code: code ?? 'http_error',
      message: message ?? 'Ошибка сервера (${response.statusCode})',
      responseBody: response.body,
    );
  }
}

class CollaborationException implements Exception {
  const CollaborationException({
    required this.statusCode,
    required this.code,
    required this.message,
    this.responseBody,
  });

  final int statusCode;
  final String code;
  final String message;
  final String? responseBody;

  @override
  String toString() => message;
}
