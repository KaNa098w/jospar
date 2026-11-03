import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:jospar/core/models/auth_response.dart';
import 'package:jospar/core/models/task_list_items_response.dart';
import 'package:jospar/core/models/tasks_response.dart';

import 'package:jospar/core/services/taks_services.dart';
import 'package:jospar/core/services/task_list_service.dart';
import 'package:jospar/core/services/offline/offline_runtime.dart';
import 'package:jospar/core/services/auth_storage.dart';
import 'package:jospar/core/services/social_auth_service.dart';
import 'package:jospar/core/services/share_delivery_mode.dart';
import 'package:jospar/core/services/auth_service.dart';

class WidgetLaunchRequest {
  const WidgetLaunchRequest({this.taskId, this.completeTaskId, this.addDate});

  final String? taskId;
  final String? completeTaskId;
  final DateTime? addDate;
}

class GlobalProvider extends ChangeNotifier {
  /// Rebuilds consumers after background sync changed the local database.
  void notifyLocalDataChanged() => notifyListeners();

  AuthResponse? _authResponse;
  AuthResponse? get authResponse => _authResponse;

  // Выбор адреса
  String? _selectedAddressName;
  String? _selectedAddressId;
  String? get selectedAddressName => _selectedAddressName;
  String? get selectedAddressId => _selectedAddressId;

  // Выбор города
  String? _selectedCityId;
  String? get selectedCityId => _selectedCityId;
  String? _selectedCityName;
  String? get selectedCityName => _selectedCityName;

  // Устройство
  String? _deviceId;
  String? get deviceId => _deviceId;

  String? _inComingHash;
  String? get inComingHash => _inComingHash;
  ShareDeliveryMode _incomingShareMode = ShareDeliveryMode.collaborate;
  ShareDeliveryMode get incomingShareMode => _incomingShareMode;
  WidgetLaunchRequest? _widgetLaunchRequest;
  WidgetLaunchRequest? get widgetLaunchRequest => _widgetLaunchRequest;

  void setInComingHash(
    String? hash, {
    ShareDeliveryMode mode = ShareDeliveryMode.collaborate,
  }) {
    _inComingHash = hash;
    _incomingShareMode = mode;
    notifyListeners();
  }

  void setWidgetLaunchRequest(WidgetLaunchRequest request) {
    _widgetLaunchRequest = request;
    notifyListeners();
  }

  WidgetLaunchRequest? takeWidgetLaunchRequest() {
    final request = _widgetLaunchRequest;
    _widgetLaunchRequest = null;
    if (request != null) notifyListeners();
    return request;
  }

  bool _isDeviceRegistered = false; // <-- флаг разовой регистрации
  bool get isDeviceRegistered => _isDeviceRegistered;

  TaskItems? _sharedTask;
  TaskItems? get sharedTask => _sharedTask;
  void setSharedTask(TaskItems? task) {
    _sharedTask = task;
    notifyListeners();
  }

  // ---------------- Инициализация ----------------
  Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();

    // The access token lives in secure storage. AuthStorage migrates the
    // legacy SharedPreferences value on the first launch after an update.
    final token = await AuthStorage().getToken() ?? '';
    if (token.isNotEmpty) {
      _authResponse = AuthResponse(
        token: token,
        user: User(
          id: prefs.getString('customerId') ?? '',
          firstName: prefs.getString('firstName') ?? '',
          lastName: prefs.getString('lastName') ?? '',
          phoneNumber: prefs.getString('phoneNumber') ?? '',
          email: prefs.getString('email') ?? '',
          avatarUrl: prefs.getString('avatarUrl'),
        ),
      );
    }

    _selectedAddressName = prefs.getString('selectedAddressName');
    _selectedAddressId = prefs.getString('selectedAddressId');
    _selectedCityId = prefs.getString('selectedCityId');
    _selectedCityName = prefs.getString('selectedCityName');

    _deviceId = prefs.getString('deviceId');
    _isDeviceRegistered = prefs.getBool('isDeviceRegistered') ?? false;

    notifyListeners();
  }

  ({String hash, ShareDeliveryMode mode})? takeIncomingShare() {
    final h = _inComingHash;
    _inComingHash = null;
    final mode = _incomingShareMode;
    _incomingShareMode = ShareDeliveryMode.collaborate;
    notifyListeners();
    if (h == null || h.isEmpty) return null;
    return (hash: h, mode: mode);
  }

  // ---------------- Аутентификация ----------------
  Future<void> setAuthData(AuthResponse response) async {
    _authResponse = response;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final token = response.token;
    if (token != null && token.isNotEmpty) {
      await AuthStorage().setToken(token);
    }

    if (response.user != null) {
      await prefs.setString('customerId', response.user!.id ?? '');
      await prefs.setString('firstName', response.user!.firstName ?? '');
      await prefs.setString('lastName', response.user!.lastName ?? '');
      await prefs.setString('phoneNumber', response.user!.phoneNumber ?? '');
      await prefs.setString('email', response.user!.email ?? '');
      final avatarUrl = response.user!.avatarUrl;
      if (avatarUrl != null && avatarUrl.isNotEmpty) {
        await prefs.setString('avatarUrl', avatarUrl);
      } else {
        await prefs.remove('avatarUrl');
      }
    }
    // The authentication screen stays on its synchronization progress state
    // until the first authenticated snapshot/pull has actually completed.
    await OfflineRuntime.syncEngine?.synchronize(ignoreStopped: true);
    await OfflineRuntime.realtimeSync?.restart();
  }

  Future<void> refreshCurrentUser() async {
    if (_authResponse?.token == null) return;
    final user = await AuthService().getCurrentUser();
    _authResponse = AuthResponse(token: _authResponse!.token, user: user);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customerId', user.id ?? '');
    await prefs.setString('firstName', user.firstName ?? '');
    await prefs.setString('lastName', user.lastName ?? '');
    await prefs.setString('phoneNumber', user.phoneNumber ?? '');
    await prefs.setString('email', user.email ?? '');
    final avatarUrl = user.avatarUrl;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      await prefs.setString('avatarUrl', avatarUrl);
    } else {
      await prefs.remove('avatarUrl');
    }
    notifyListeners();
  }

  // ---------------- Устройство ----------------
  Future<void> setDeviceId(String id) async {
    _deviceId = id;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('deviceId', id);
  }

  Future<void> setDeviceRegistered(bool v) async {
    _isDeviceRegistered = v;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDeviceRegistered', v);
  }

  // ---------------- Списки задач ----------------
  bool _isSyncingTaskLists = false;
  DateTime? _lastTaskListsSyncedAt;

  bool get isSyncingTaskLists => _isSyncingTaskLists;
  DateTime? get lastTaskListsSyncedAt => _lastTaskListsSyncedAt;

  Future<void> refreshTaskLists(
    BuildContext context, {
    bool silent = false,
    Duration? minInterval,
  }) async {
    if (_isSyncingTaskLists) return;

    if (minInterval != null &&
        _lastTaskListsSyncedAt != null &&
        DateTime.now().difference(_lastTaskListsSyncedAt!) < minInterval) {
      return;
    }

    _isSyncingTaskLists = true;
    if (!silent) notifyListeners();

    try {
      final service = TaskListService();
      final resp = await service.getTaskLists(context);

      List<TaskListItems> lists;
      if (resp.items is List<TaskListItems>) {
        lists = resp.items as List<TaskListItems>;
      } else {
        lists = <TaskListItems>[];
      }

      setTaskLists(lists);
      _lastTaskListsSyncedAt = DateTime.now();
    } finally {
      _isSyncingTaskLists = false;
      if (!silent) notifyListeners();
    }
  }

  // ---------------- Задачи (API) ----------------
  List<TaskItems> _allApiTasks = [];
  Map<String, List<TaskItems>> _apiTasksByList = {};

  List<TaskItems> get allApiTasks => _allApiTasks;
  Map<String, List<TaskItems>> get apiTasksByList => _apiTasksByList;

  Future<void> setApiTasks(List<TaskItems> tasks) async {
    _allApiTasks = tasks;

    final map = <String, List<TaskItems>>{};
    for (final t in tasks) {
      final listId = t.taskListId;
      if (listId == null || listId.isEmpty) continue;
      (map[listId] ??= <TaskItems>[]).add(t);
    }
    _apiTasksByList = map;

    notifyListeners();
  }

  void addTaskOptimistic(TaskItems item) {
    _allApiTasks = [item, ..._allApiTasks];

    final listId = item.taskListId;
    if (listId != null && listId.isNotEmpty) {
      final current = List<TaskItems>.from(_apiTasksByList[listId] ?? const []);
      current.insert(0, item);
      _apiTasksByList = {
        ..._apiTasksByList,
        listId: current,
      };
    }

    notifyListeners();
  }

  void removeTaskOptimistic(String taskId) {
    _allApiTasks = _allApiTasks.where((t) => t.id != taskId).toList();

    final updated = <String, List<TaskItems>>{};
    _apiTasksByList.forEach((listId, list) {
      updated[listId] = list.where((t) => t.id != taskId).toList();
    });
    _apiTasksByList = updated;

    notifyListeners();
  }

  void setTaskCompletedOptimistic(String taskId, bool isCompleted) {
    for (final task in _allApiTasks) {
      if (task.id == taskId) {
        task.isCompleted = isCompleted;
        break;
      }
    }
    // context.select compares the selected List by identity. Publish a new
    // list instance so covered screens (including the task page) rebuild.
    _allApiTasks = List<TaskItems>.of(_allApiTasks);
    notifyListeners();
  }

  bool _isSyncingTasks = false;
  DateTime? _lastTasksSyncedAt;

  bool get isSyncingTasks => _isSyncingTasks;
  DateTime? get lastTasksSyncedAt => _lastTasksSyncedAt;

  Future<void> refreshTasks(
    BuildContext context, {
    bool silent = false,
    Duration? minInterval,
  }) async {
    if (_isSyncingTasks) return;

    if (minInterval != null &&
        _lastTasksSyncedAt != null &&
        DateTime.now().difference(_lastTasksSyncedAt!) < minInterval) {
      return;
    }

    _isSyncingTasks = true;
    if (!silent) notifyListeners();

    try {
      final service = TaskService();
      final resp = await service.getTasks(context, only_parent: 1);
      await setApiTasks(resp.items ?? <TaskItems>[]);
      _lastTasksSyncedAt = DateTime.now();
    } finally {
      _isSyncingTasks = false;
      if (!silent) notifyListeners();
    }
  }

  // ---------------- Локальные списки/задачи (если нужны параллельно) ----------------
  List<TaskListItems> _taskLists = [];
  Map<String, List<TaskItems>> _tasksByList = {};
  List<TaskItems> _allTasks = [];

  void setTaskLists(List<TaskListItems> lists) {
    _taskLists = lists;
    notifyListeners();
  }

  void setAllTasks(Map<String, List<TaskItems>> tasksMap) {
    _tasksByList = tasksMap;
    notifyListeners();
  }

  void setAllTasksOnce(List<TaskItems> tasks) {
    _allTasks = tasks;
    notifyListeners();
  }

  List<TaskItems> get allTasks => _allTasks;
  List<TaskListItems> get taskLists => _taskLists;
  Map<String, List<TaskItems>> get tasksByList => _tasksByList;

  // ---------------- Выход/очистка ----------------
  Future<void> deleteAccount() async {
    final userId = _authResponse?.user?.id ?? await AuthStorage().getUserId();
    final token = await AuthStorage().getToken();
    if (userId == null || userId.isEmpty || token == null || token.isEmpty) {
      throw const AuthException(
        'unauthenticated',
        'Пользователь не авторизован.',
        statusCode: 401,
      );
    }

    try {
      await AuthService().deleteAccount();
    } on AuthException catch (error) {
      if (error.statusCode != 401) rethrow;
    }
    await _clearDeletedAccount(userId);
  }

  Future<void> _clearDeletedAccount(String userId) async {
    await OfflineRuntime.realtimeSync?.stop();
    await OfflineRuntime.store.clearAccountData(userId);
    try {
      await SocialAuthService().signOut();
    } catch (_) {
      // Server deletion must still clear every local credential.
    }
    for (final boxName in const ['tasks_box', 'task_lists_box']) {
      final wasOpen = Hive.isBoxOpen(boxName);
      final box = wasOpen ? Hive.box(boxName) : await Hive.openBox(boxName);
      await box.clear();
      if (!wasOpen) await box.close();
    }
    await AuthStorage().clearAll();

    _authResponse = null;
    _selectedAddressName = null;
    _selectedAddressId = null;
    _selectedCityId = null;
    _selectedCityName = null;
    _deviceId = null;
    _isDeviceRegistered = false;
    _sharedTask = null;
    _inComingHash = null;
    _incomingShareMode = ShareDeliveryMode.collaborate;
    _allApiTasks = [];
    _apiTasksByList = {};
    _taskLists = [];
    _tasksByList = {};
    _allTasks = [];
    _widgetLaunchRequest = null;
    notifyListeners();
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await OfflineRuntime.realtimeSync?.stop();
    try {
      await SocialAuthService().signOut();
    } catch (_) {
      // Local logout must still complete when a provider SDK is unavailable.
      await AuthStorage().clearToken();
    }
    await prefs.remove('customerId');
    await prefs.remove('firstName');
    await prefs.remove('lastName');
    await prefs.remove('phoneNumber');
    await prefs.remove('email');
    await prefs.remove('avatarUrl');

    _authResponse = null;
    _selectedAddressName = null;
    _selectedAddressId = null;

    _allApiTasks = [];
    _apiTasksByList = {};
    _taskLists = [];
    _tasksByList = {};
    _allTasks = [];
    _widgetLaunchRequest = null;

    // очищаем и девайс
    _isDeviceRegistered = false;

    notifyListeners();
  }
}
