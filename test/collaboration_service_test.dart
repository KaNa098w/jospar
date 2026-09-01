import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:jospar/core/services/collaboration_service.dart';
import 'package:jospar/core/services/share_delivery_mode.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('createInvite sends backend mode and duplicate viewer role', () async {
    SharedPreferences.setMockInitialValues({'token': 'access-token'});
    final service = CollaborationService(
      client: MockClient((request) async {
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['mode'], 'duplicate');
        expect(body['role'], 'viewer');
        expect(body['expires_in_seconds'], isNull);
        expect(body['max_uses'], isNull);
        return http.Response(
          jsonEncode({
            'hash': 'share-hash',
            'url': 'https://jospar.kz/s/share-hash',
            'mode': 'duplicate',
          }),
          201,
        );
      }),
    );

    await service.createInvite(
      'task-1',
      mode: ShareDeliveryMode.duplicate,
    );
  });

  test('collaborators accepts a bare list and nested user objects', () async {
    SharedPreferences.setMockInitialValues({'token': 'access-token'});
    final service = CollaborationService(
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/tasks/task-1/collaborators');
        expect(request.headers['Authorization'], 'Bearer access-token');
        return http.Response(
          jsonEncode([
            {
              'role': 'owner',
              'user': {
                'id': 'user-1',
                'first_name': 'John',
                'last_name': 'Appleseed',
                'email': 'john@example.com',
              },
            },
          ]),
          200,
        );
      }),
    );

    final collaborators = await service.collaborators('task-1');

    expect(collaborators, hasLength(1));
    expect(collaborators.single['user_id'], 'user-1');
    expect(collaborators.single['name'], 'John Appleseed');
    expect(collaborators.single['email'], 'john@example.com');
  });

  test('inviteTask normalizes subtasks as recursive children', () async {
    SharedPreferences.setMockInitialValues({'token': 'access-token'});
    final service = CollaborationService(
      client: MockClient((request) async {
        expect(request.url.path, '/api/v1/shares/share-hash');
        return http.Response(
          jsonEncode({
            'data': {
              'task': {
                'id': 'task-1',
                'name': 'Основная',
                'subtasks': [
                  {
                    'id': 'task-2',
                    'name': 'Подзадача',
                    'subtasks': [
                      {'id': 'task-3', 'name': 'Вложенная'},
                    ],
                  },
                ],
              },
            },
          }),
          200,
          headers: {'content-type': 'application/json; charset=utf-8'},
        );
      }),
    );

    final task = await service.inviteTask('share-hash');
    final children = task['children'] as List<dynamic>;
    expect(children, hasLength(1));
    expect(children.single['name'], 'Подзадача');
    expect(children.single['children'], hasLength(1));
  });

  test('accepting an already used link reopens its current task', () async {
    SharedPreferences.setMockInitialValues({'token': 'access-token'});
    var requests = 0;
    final service = CollaborationService(
      client: MockClient((request) async {
        requests++;
        if (request.method == 'POST') {
          expect(request.url.path, '/api/v1/shares/repeat-hash/accept');
          return http.Response(
            jsonEncode({
              'error': {
                'code': 'already_accepted',
                'message': 'Invite already accepted',
              },
            }),
            409,
          );
        }
        expect(request.url.path, '/api/v1/shares/repeat-hash');
        return http.Response(
          jsonEncode({
            'task': {
              'id': 'task-1',
              'name': 'Shared task',
              'subtasks': [
                {'id': 'child-1', 'name': 'Subtask'},
              ],
            },
          }),
          200,
        );
      }),
    );

    final task = await service.acceptInvite('repeat-hash');

    expect(requests, 2);
    expect(task['id'], 'task-1');
    expect(task['children'], hasLength(1));
  });
}
