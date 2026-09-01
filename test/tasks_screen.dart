// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:intl/date_symbol_data_local.dart';
// import 'package:jospar/constants/theme.dart';
// import 'package:jospar/constants/utils.dart';
// import 'package:jospar/models/tasks_response.dart';
// import 'package:jospar/screens/modal_sheet/add_task_modal.dart';
// import 'package:jospar/services/taks_services.dart';
// import 'package:provider/provider.dart';
// import '../../../constants/provider.dart';
// import '../../../widgets/custom_drawer_widget.dart';
// import '../../../widgets/task_section_widget.dart';
// import '../../widgets/task_item_widget.dart';

// class TasksPage extends StatefulWidget {
//   const TasksPage({super.key});

//   @override
//   _TasksPageState createState() => _TasksPageState();
// }

// class _TasksPageState extends State<TasksPage>
//     with SingleTickerProviderStateMixin {
//   final TaskService _taskService = TaskService();

//   DateTime _selectedDay = DateTime.now();
//   bool _isCalendarVisible = false;
//   double _scaleFactor = 1.0;
//   DateTime _focusedDay = DateTime.now();

//   final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

//   final Map<String, GlobalKey<TaskSectionState>> _sectionKeys = {
//     'today': GlobalKey<TaskSectionState>(),
//     'tomorrow': GlobalKey<TaskSectionState>(),
//     'week': GlobalKey<TaskSectionState>(),
//     'later': GlobalKey<TaskSectionState>(),
//   };

//   @override
//   void initState() {
//     super.initState();
//     initializeDateFormatting('ru', null);
//   }

//   void _toggleCalendar() {
//     setState(() {
//       _isCalendarVisible = !_isCalendarVisible;
//       final today = DateUtils.dateOnly(DateTime.now());
//       // И при открытии, и при закрытии фиксируем сегодня —
//       // так "выбранная ранее дата" не залипнет.
//       _selectedDay = today;
//       _focusedDay = today;
//     });
//   }

//   Future<void> _addTask() async {
//     setState(() => _scaleFactor = 0.88);

//     await showAddTaskModal(
//       context: context,
//       selectedDay: _selectedDay,
//       taskId: '',
//       onSaveTask: (title, subtasks, date, taskListId) async {
//         await _saveTask(title, subtasks, date, taskListId);
//       },
//     );

//     if (context.mounted) {
//       context.read<GlobalProvider>().refreshTasks(context);
//     }

//     setState(() => _scaleFactor = 1.0);
//   }

//   String _fmt(DateTime d) =>
//       '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

//   Future<void> _saveTask(
//     String title,
//     List subtasks,
//     DateTime date,
//     String taskListId,
//   ) async {
//     if (taskListId.isEmpty) {
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Выбери список задач')),
//       );
//       return;
//     }

//     try {
//       final created = await _taskService.createTask(
//         context,
//         name: title,
//         date: _fmt(date), // 'YYYY-MM-DD'
//         taskListId: taskListId,
//       );

//       final parentTaskId = created['id'] as String?;
//       if (parentTaskId == null || parentTaskId.isEmpty) {
//         throw Exception('Сервер не вернул id созданной задачи');
//       }

//       for (final s in subtasks) {
//         final subTitle = (s['title'] as String?)?.trim();
//         if (subTitle == null || subTitle.isEmpty) continue;

//         try {
//           await _taskService.createSubtask(
//             context,
//             name: subTitle,
//             parentTaskId: parentTaskId,
//             taskListId: taskListId,
//           );
//           context.read<GlobalProvider>().refreshTasks(context);
//         } catch (e, st) {
//           debugPrint('createSubtask("$subTitle") failed: $e\n$st');
//         }
//       }

//       if (!mounted) return;
//       await context.read<GlobalProvider>().refreshTasks(context);
//     } catch (e, st) {
//       debugPrint('saveTask failed: $e\n$st');
//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Не удалось создать задачу: $e')),
//       );
//     }
//   }

//   DateTime? _parseApiDate(String? s) {
//     if (s == null || s.isEmpty) return null;

//     try {
//       final dt = DateTime.parse(s);
//       return dt.isUtc ? dt.toLocal() : dt;
//     } catch (_) {
//       final m = RegExp(r'^(\d{4})-(\d{2})-(\d{2})').firstMatch(s);
//       if (m != null) {
//         final y = int.parse(m.group(1)!);
//         final mm = int.parse(m.group(2)!);
//         final d = int.parse(m.group(3)!);
//         return DateTime(y, mm, d);
//       }
//       return null;
//     }
//   }

//   String _bucketFor(DateTime? taskDate, DateTime base) {
//     if (taskDate == null) return 'later';

//     final bd = DateUtils.dateOnly(base); // локальная базовая дата
//     final td = DateUtils.dateOnly(taskDate); // локальная дата задачи

//     if (!td.isAfter(bd)) return 'today'; // td <= bd
//     final diff = td.difference(bd).inDays;
//     if (diff == 1) return 'tomorrow';
//     if (diff >= 2 && diff <= 7) return 'week';
//     return 'later';
//   }

//   Map<String, List<TaskItems>> _groupByBuckets(
//     List<TaskItems> items,
//     DateTime base,
//   ) {
//     final map = <String, List<TaskItems>>{
//       'today': [],
//       'tomorrow': [],
//       'week': [],
//       'later': [],
//     };

//     for (final t in items) {
//       final d = _parseApiDate(t.date);
//       final bucket = _bucketFor(d, base);
//       map[bucket]!.add(t);
//     }

//     int _safeCompareDates(String? a, String? b) {
//       final da = _parseApiDate(a) ?? DateTime(3000);
//       final db = _parseApiDate(b) ?? DateTime(3000);
//       return da.compareTo(db);
//     }

//     for (final k in map.keys) {
//       map[k]!.sort((a, b) {
//         final ac = a.isCompleted ?? false;
//         final bc = b.isCompleted ?? false;
//         if (ac != bc) return ac ? 1 : -1;

//         final c1 = _safeCompareDates(a.date, b.date);
//         if (c1 != 0) return c1;

//         final p1 = a.position ?? 0;
//         final p2 = b.position ?? 0;
//         if (p1 != p2) return p1.compareTo(p2);

//         return (a.updatedAt ?? '').compareTo(b.updatedAt ?? '');
//       });
//     }

//     return map;
//   }

//   // --- DnD: вычисление даты под целевую секцию
//   DateTime _dateForBucket(String bucket, DateTime base, {DateTime? current}) {
//     final b = DateUtils.dateOnly(base);
//     switch (bucket) {
//       case 'today':
//         return b;
//       case 'tomorrow':
//         return b.add(const Duration(days: 1));
//       case 'week':
//         if (current != null) {
//           final diff = DateUtils.dateOnly(current).difference(b).inDays;
//           if (diff >= 2 && diff <= 7) return DateUtils.dateOnly(current);
//         }
//         return b.add(const Duration(days: 3));
//       case 'later':
//         return b.add(const Duration(days: 8));
//       default:
//         return b;
//     }
//   }

//   Widget _buildDayTasksList(List<TaskItems> items) {
//     if (items.isEmpty) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Text(
//             'На этот день задач нет',
//             textAlign: TextAlign.center,
//             style: const TextStyle(
//               fontSize: 16,
//               fontWeight: FontWeight.w600,
//               color: ThemeColors.grey5,
//             ),
//           ),
//         ),
//       );
//     }

//     // сортировка: незавершённые вверх, потом по времени/updatedAt
//     items.sort((a, b) {
//       final ac = a.isCompleted == true;
//       final bc = b.isCompleted == true;
//       if (ac != bc) return ac ? 1 : -1;

//       final ad =
//           _parseLocal(a.date) ?? _parseLocal(a.updatedAt) ?? DateTime(1900);
//       final bd =
//           _parseLocal(b.date) ?? _parseLocal(b.updatedAt) ?? DateTime(1900);
//       return ad.compareTo(bd);
//     });

//     return ListView.separated(
//       padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
//       itemCount: items.length,
//       separatorBuilder: (_, __) => const SizedBox(height: 8),
//       itemBuilder: (context, i) {
//         final task = items[i];
//         return GestureDetector(
//           onTap: () async {
//             await showAddTaskModal(
//               context: context,
//               selectedDay: _selectedDay,
//               taskId: task.id ?? '',
//               existingTask: task,
//               onSaveTask: (title, subtasks, date, taskListId) async {
//                 await _taskService.updateTaskPut(
//                   context,
//                   id: task.id ?? '',
//                   name: title,
//                   taskListId: taskListId,
//                   date: _fmt(date),
//                 );
//                 if (context.mounted) {
//                   await context.read<GlobalProvider>().refreshTasks(context);
//                 }
//               },
//             );
//           },
//           child: TaskItem(
//             colorHex: ThemeColors.primary,
//             task: task,
//             onToggle: () async {
//               final prev = task.isCompleted == true;
//               setState(() => task.isCompleted = !prev);
//               try {
//                 await _taskService.updateTask(context, id: task.id ?? '');
//                 if (context.mounted) {
//                   await context.read<GlobalProvider>().refreshTasks(context);
//                 }
//               } catch (e) {
//                 setState(() => task.isCompleted = prev);
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   SnackBar(content: Text('Не удалось обновить задачу: $e')),
//                 );
//               }
//             },
//           ),
//         );
//       },
//     );
//   }

//   Future<void> _onTaskDropped(TaskItems task, String targetKey) async {
//     final oldDate = _parseApiDate(task.date);
//     final newDate = _dateForBucket(targetKey, _selectedDay, current: oldDate);
//     final newDateStr = _fmt(newDate);

//     final srcKey = _bucketFor(oldDate, _selectedDay);
//     final src = _sectionKeys[srcKey]?.currentState;
//     final dst = _sectionKeys[targetKey]?.currentState;

//     // Оптимистично переложим (мутируем дату у той же ссылки — поля у модели мутабельные)
//     final oldDateStr = task.date;
//     task.date = newDateStr;

//     src?.removeTaskById(task.id ?? '');
//     dst?.insertTaskAtTop(task);

//     try {
//       await _taskService.updateTaskPut(
//         context,
//         id: task.id ?? '',
//         date: newDateStr, // <-- главное: обновляем дату
//         taskListId: task.taskListId, // если бэку нужно
//         name: task.name, // если бэку нужно
//       );
//       if (!mounted) return;
//       await context.read<GlobalProvider>().refreshTasks(context);
//     } catch (e) {
//       // Откат оптимистичной операции
//       task.date = oldDateStr;
//       dst?.removeTaskById(task.id ?? '');
//       src?.insertTaskAtTop(task);

//       if (!mounted) return;
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Не удалось изменить дату: $e')),
//       );
//     }
//   }

//   // DragTarget-обёртка для секции
//   Widget _dropTarget(String key, String title, List<TaskItems>? items) {
//     final isEmpty = items == null || items.isEmpty;

//     return DragTarget<TaskItems>(
//       onWillAccept: (t) {
//         if (t == null) return false;
//         final srcKey = _bucketFor(_parseApiDate(t.date), _selectedDay);
//         return srcKey != key; // не принимать из той же секции
//       },
//       onAccept: (t) => _onTaskDropped(t, key),
//       builder: (context, candidates, rejects) {
//         final highlight = candidates.isNotEmpty;

//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 150),
//           curve: Curves.easeOut,
//           padding: EdgeInsets.only(
//             top: highlight ? 12 : 0,
//             bottom: highlight ? 12 : 0,
//           ),
//           child: IgnorePointer(
//             ignoring: isEmpty, // запрет на взаимодействие
//             child: Opacity(
//               opacity: isEmpty ? 0.5 : 1.0, // серый вид, если пусто
//               child: TaskSection(
//                 key: _sectionKeys[key],
//                 title: title,
//                 tasksKey: key,
//                 items: items,
//                 onBeforeOpenModal: () => setState(() => _scaleFactor = 0.88),
//                 onAfterCloseModal: () => setState(() => _scaleFactor = 1.0),
//               ),
//             ),
//           ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final allApiTasks = context.select<GlobalProvider, List<TaskItems>>(
//       (g) => g.allApiTasks,
//     );

//     final dayTasks = allApiTasks.where((t) {
//       final td = _parseLocal(t.date);
//       return _isSameDay(td, _selectedDay);
//     }).toList();

//     final groups = _groupByBuckets(allApiTasks, _selectedDay);
//     return AnnotatedRegion<SystemUiOverlayStyle>(
//       value: _scaleFactor < 1.0
//           ? SystemUiOverlayStyle.light
//           : SystemUiOverlayStyle.dark,
//       child: AnimatedScale(
//         scale: _scaleFactor,
//         duration: const Duration(milliseconds: 300),
//         curve: Curves.easeInOut,
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(_scaleFactor < 1 ? 16 : 0),
//           child: Scaffold(
//             key: _scaffoldKey,
//             backgroundColor: Colors.white,
//             drawerEnableOpenDragGesture: false,
//             drawerEdgeDragWidth: MediaQuery.of(context).size.width,
//             drawerScrimColor: Colors.transparent,
//             appBar: AppBar(
//               backgroundColor: Colors.white,
//               elevation: 0,
//               scrolledUnderElevation: 0,
//               leading: IconButton(
//                 icon: Image.asset(
//                   'assets/icons/menu.png',
//                   width: 28,
//                   height: 28,
//                   color: ThemeColors.black,
//                 ),
//                 onPressed: () => _scaffoldKey.currentState?.openDrawer(),
//               ),
//               actions: [
//                 IconButton(
//                   onPressed: _toggleCalendar,
//                   icon: _isCalendarVisible
//                       ? Icon(
//                           Icons.arrow_upward_rounded,
//                           color: ThemeColors.grey5,
//                         )
//                       : SizedBox(
//                           width: 28,
//                           height: 28,
//                           child: Stack(
//                             alignment: Alignment.center,
//                             children: [
//                               Icon(
//                                 Icons.calendar_today_outlined,
//                                 color: ThemeColors.grey5,
//                                 size: 28,
//                               ),
//                               Transform.translate(
//                                 offset: const Offset(0, 3.5),
//                                 child: Text(
//                                   '${DateTime.now().day}',
//                                   style: const TextStyle(
//                                     fontSize: 11,
//                                     fontWeight: FontWeight.w800,
//                                     color: ThemeColors.black,
//                                     height: 1,
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                   tooltip: '${DateTime.now().day}',
//                 ),
//               ],
//             ),
//             drawer: const CustomDrawer(),
//             body: Row(
//               children: [
//                 Expanded(
//                   child: Column(
//                     children: [
//                       buildAnimatedCalendar(
//                         context: context,
//                         isVisible: _isCalendarVisible,
//                         selectedDay: _selectedDay,
//                         focusedDay: _focusedDay,
//                         onDaySelected: (sel, foc) {
//                           setState(() {
//                             _selectedDay = DateUtils.dateOnly(sel);
//                             _focusedDay = DateUtils.dateOnly(foc);
//                             // _isCalendarVisible = false;
//                           });
//                         },
//                       ),
//                       Expanded(
//                         child: _isCalendarVisible
//                             ? Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Padding(
//                                     padding:
//                                         const EdgeInsets.fromLTRB(20, 4, 20, 8),
//                                     child: Text(
//                                       _formatDayHeader(_selectedDay),
//                                       style: const TextStyle(
//                                         fontFamily: 'Oswald',
//                                         fontWeight: FontWeight.w700,
//                                         fontSize: 22,
//                                         letterSpacing: -0.2,
//                                         color: ThemeColors.black,
//                                       ),
//                                     ),
//                                   ),
//                                   Expanded(
//                                       child: _buildDayTasksList(
//                                           dayTasks)), // ← тут и покажется заглушка
//                                 ],
//                               )
//                             : ListView(
//                                 padding: const EdgeInsets.symmetric(
//                                     vertical: 8, horizontal: 20),
//                                 children: [
//                                   buildAnimatedSection(
//                                     _dropTarget(
//                                         'today', 'Сегодня', groups['today']),
//                                     _isCalendarVisible,
//                                   ),
//                                   buildAnimatedSection(
//                                     _dropTarget('tomorrow', 'Завтра',
//                                         groups['tomorrow']),
//                                     _isCalendarVisible,
//                                   ),
//                                   buildAnimatedSection(
//                                     _dropTarget(
//                                         'week', 'На неделе', groups['week']),
//                                     _isCalendarVisible,
//                                   ),
//                                   buildAnimatedSection(
//                                     _dropTarget(
//                                         'later', 'Потом', groups['later']),
//                                     _isCalendarVisible,
//                                   ),
//                                   const SizedBox(height: 50),
//                                 ],
//                               ),
//                       )
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//             floatingActionButton: GestureDetector(
//               onTap: _addTask,
//               child: buildAddButton(),
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// /// Красиво скрываем/показываем секцию (любой виджет)
// Widget buildAnimatedSection(Widget child, bool hidden) {
//   return AnimatedOpacity(
//     opacity: hidden ? 0.4 : 1,
//     duration: const Duration(milliseconds: 180),
//     curve: Curves.easeOut,
//     child: AnimatedSlide(
//       duration: const Duration(milliseconds: 180),
//       offset: hidden ? const Offset(0, -0.02) : Offset.zero,
//       curve: Curves.easeOut,
//       child: child,
//     ),
//   );
// }

// Widget buildAnimatedCalendar({
//   required BuildContext context,
//   required bool isVisible,
//   required DateTime selectedDay,
//   required DateTime focusedDay,
//   required void Function(DateTime selected, DateTime focused) onDaySelected,
// }) {
//   return AnimatedCrossFade(
//     duration: const Duration(milliseconds: 220),
//     firstChild: const SizedBox.shrink(),
//     secondChild: Padding(
//       padding: const EdgeInsets.only(bottom: 8),
//       child: Theme(
//         data: Theme.of(context).copyWith(
//           colorScheme: Theme.of(context).colorScheme.copyWith(
//                 primary: ThemeColors.primary, // активная дата, ховер, стрелки
//                 onPrimary: Colors.white, // текст на активной дате
//               ),
//           // начиная с Flutter 3.16 можно ещё точечно:
//           datePickerTheme: DatePickerThemeData(
//             dayForegroundColor: MaterialStateProperty.resolveWith((states) {
//               if (states.contains(MaterialState.selected)) {
//                 return Colors.white; // текст выбранного дня
//               }
//               return null; // дефолтный цвет
//             }),
//             dayBackgroundColor: MaterialStateProperty.resolveWith((states) {
//               if (states.contains(MaterialState.selected)) {
//                 return ThemeColors.primary; // фон выбранного дня
//               }
//               return null;
//             }),
//           ),
//         ),
//         child: CalendarDatePicker(
//           initialDate: selectedDay,
//           firstDate: DateTime(2000),
//           lastDate: DateTime(2100),
//           currentDate: DateTime.now(),
//           onDateChanged: (d) => onDaySelected(d, d),
//         ),
//       ),
//     ),
//     crossFadeState:
//         isVisible ? CrossFadeState.showSecond : CrossFadeState.showFirst,
//   );
// }

// /// Плавающая большая (+) кнопка
// Widget buildAddButton() {
//   return Container(
//     padding: const EdgeInsets.all(16),
//     decoration: BoxDecoration(
//       color: ThemeColors.primary,
//       shape: BoxShape.circle,
//       boxShadow: [
//         BoxShadow(
//           color: Colors.black.withOpacity(0.1),
//           blurRadius: 12,
//           offset: const Offset(0, 6),
//         ),
//       ],
//     ),
//     child: const Icon(Icons.add, color: Colors.white, size: 28),
//   );
// }

// bool _isSameDay(DateTime? a, DateTime? b) {
//   if (a == null || b == null) return false;
//   final da = DateUtils.dateOnly(a);
//   final db = DateUtils.dateOnly(b);
//   return da == db;
// }

// DateTime? _parseLocal(String? s) {
//   if (s == null || s.isEmpty) return null;
//   try {
//     final dt = DateTime.parse(s);
//     return dt.isUtc ? dt.toLocal() : dt;
//   } catch (_) {
//     return null;
//   }
// }

// String _formatDayHeader(DateTime d) {
//   const months = [
//     'ЯНВ',
//     'ФЕВ',
//     'МАР',
//     'АПР',
//     'МАЙ',
//     'ИЮН',
//     'ИЮЛ',
//     'АВГ',
//     'СЕН',
//     'ОКТ',
//     'НОЯ',
//     'ДЕК'
//   ];
//   const weekdays = ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'];
//   final day = d.day.toString().padLeft(2, '0');
//   final m = months[d.month - 1];
//   // В Dart неделя начинается с понедельника = 1, воскресенье = 7
//   final w = weekdays[(d.weekday - 1) % 7];
//   return '$day $m, $w';
// }
