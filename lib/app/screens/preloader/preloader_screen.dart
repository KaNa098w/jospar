import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:jospar/app/widgets/accept_button.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/core/models/tasks_response.dart';
import 'package:jospar/core/services/task_list_service.dart';
import 'package:jospar/core/services/taks_services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jospar/core/services/auth_storage.dart';

class TasksPreloaderScreen extends StatefulWidget {
  const TasksPreloaderScreen({super.key});

  @override
  State<TasksPreloaderScreen> createState() => _TasksPreloaderScreenState();
}

class _TasksPreloaderScreenState extends State<TasksPreloaderScreen> {
  final TaskListService _taskListService = TaskListService();
  final TaskService _taskService = TaskService();
  bool isLoading = true;
  bool hasError = false;
  bool showReloadButton = false;

  @override
  void initState() {
    super.initState();
    _loadInitialData();

    Timer(const Duration(seconds: 10), () {
      if (mounted && isLoading) {
        setState(() {
          showReloadButton = true;
        });
      }
    });
  }

  Future<void> _loadInitialData() async {
    final global = Provider.of<GlobalProvider>(context, listen: false);
    setState(() {
      isLoading = true;
      hasError = false;
      showReloadButton = false;
    });
    try {
      final deviceId = await _getDeviceId();
      if (!mounted) return;
      if (global.deviceId == null || global.deviceId!.isEmpty) {
        await global.setDeviceId(deviceId);
      }
      if (!mounted) return;
      if (global.inComingHash?.isNotEmpty == true) {
        final token = await AuthStorage().getToken();
        if (!mounted) return;
        if (token == null || token.isEmpty) {
          context.go('/auth');
          return;
        }
      }
      final taskListsResponse = await _taskListService.getTaskLists(context);
      if (taskListsResponse.items != null) {
        global.setTaskLists(taskListsResponse.items!);
      } else {
        throw Exception('Пустой список задач');
      }

      if (!mounted) return;
      final tasksResponse =
          await _taskService.getTasks(context, only_parent: 1);

      final items = tasksResponse.items ?? <TaskItems>[];

      await global.setApiTasks(items);

      _navigateToTasks();
    } catch (e) {
      debugPrint(
          "Error in _loadInitialData: $e"); // Добавим логирование для отладки

      setState(() {
        hasError = true;

        isLoading = false;
      });
    }
  }

  void _navigateToTasks() {
    if (!mounted) return;
    context.go('/tasks'); // или context.goNamed('tasks');
  }

  Future<String> _getDeviceId() async {
    return AuthStorage().ensureDeviceId();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.white,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 20),
            if (hasError || showReloadButton) ...[
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Не удалось загрузить локальные задачи. Попробуйте снова.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
              ),
              const SizedBox(height: 16),
              AcceptButton(text: 'Перезагрузить', onPressed: _loadInitialData),
            ] else if (isLoading) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: 200,
                height: 200,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SvgPicture.asset(
                    'assets/icons/jospar_logo.svg',
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
