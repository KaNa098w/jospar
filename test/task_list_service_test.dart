import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:jospar/core/db/app_db.dart';
import 'package:jospar/core/services/offline/offline_runtime.dart';
import 'package:jospar/core/services/task_list_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'default list is seeded once and is not restored after deletion',
    () async {
      final tempDirectory = await Directory.systemTemp.createTemp(
        'jospar-task-list-service-',
      );
      Hive.init(tempDirectory.path);
      await Hive.openBox('tasks_box');
      await Hive.openBox('task_lists_box');
      SharedPreferences.setMockInitialValues({});

      final db = AppDb(NativeDatabase.memory());
      addTearDown(() async {
        await db.close();
        await Hive.close();
        await tempDirectory.delete(recursive: true);
      });
      await OfflineRuntime.initialize(database: db);

      final context = _FakeBuildContext();
      final service = TaskListService();

      final initial = await service.getTaskLists(context);
      expect(initial.items, hasLength(1));
      expect(initial.items!.single.name, 'Личные');

      // Registration claims the locally created anonymous list before it is
      // synchronized with the backend.
      await OfflineRuntime.store.claimAnonymousData('user-1');
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('customerId', 'user-1');

      final listId = initial.items!.single.id!;
      await service.deleteTaskList(context, listId);
      expect((await service.getTaskLists(context)).items, isEmpty);

      // A later logout and authorization must not seed "Личные" again.
      await preferences.remove('customerId');
      expect((await service.getTaskLists(context)).items, isEmpty);
      await preferences.setString('customerId', 'user-1');
      expect((await service.getTaskLists(context)).items, isEmpty);
    },
  );
}

class _FakeBuildContext extends Fake implements BuildContext {}
