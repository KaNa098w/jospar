// import 'package:flutter/material.dart';
// import 'package:jospar/core/constants/constants.dart';
// import 'package:jospar/core/constants/provider.dart';
// import 'package:jospar/core/constants/theme.dart';
// import 'package:jospar/core/l10n/s.dart';
// import 'package:jospar/core/models/create_list_modal_sheet.dart';
// import 'package:jospar/core/models/task_list_items_response.dart';
// import 'package:jospar/app/screens/auth/phone_input_modul.dart';
// import 'package:jospar/app/screens/auth/profile_page.dart';
// import 'package:jospar/app/screens/trash/trash_screen.dart';
// import 'package:jospar/core/services/task_list_service.dart';
// import 'package:jospar/main.dart';
// import 'package:provider/provider.dart';

// class CustomDrawer extends StatefulWidget {
//   final VoidCallback? onAnyTap;

//   const CustomDrawer({Key? key, this.onAnyTap}) : super(key: key);

//   @override
//   State<CustomDrawer> createState() => _CustomDrawerState();
// }

// class _CustomDrawerState extends State<CustomDrawer> {
//   // Общий горизонтальный отступ для всего Drawer
//   static const double _hpad = 16.0;

//   @override
//   Widget build(BuildContext context) {
//     final global = context.read<GlobalProvider>();
//     final phone = global.authResponse?.user?.phoneNumber;
//     return SafeArea(
//       child: Material(
//         color: Colors.white,
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const SizedBox(height: 24),

//             // Топ-бар (настройки + профиль)
//             Padding(
//               padding: const EdgeInsets.symmetric(horizontal: _hpad),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     children: [
//                       // Кнопка Settings (как было)
//                       IconButton(
//                         icon: const Icon(Icons.settings,
//                             color: Colors.grey, size: 24),
//                         onPressed: widget.onAnyTap,
//                         padding: EdgeInsets.zero,
//                         constraints: const BoxConstraints(),
//                         tooltip: S
//                             .of(context)
//                             .settings, // добавь ключ в ARB (settings)
//                       ),

//                       const SizedBox(width: 8),

//                       // Свитчер языка — PopupMenuButton
//                       PopupMenuButton<Locale>(
//                         tooltip: S
//                             .of(context)
//                             .language, // ключ language уже есть/добавим
//                         offset: const Offset(0, 36),
//                         itemBuilder: (ctx) => [
//                           PopupMenuItem(
//                             value: const Locale('ru'),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.flag, size: 18),
//                                 const SizedBox(width: 8),
//                                 Text('Русский'),
//                                 const Spacer(),
//                                 if (Localizations.localeOf(ctx).languageCode ==
//                                     'ru')
//                                   const Icon(Icons.check, size: 18),
//                               ],
//                             ),
//                           ),
//                           PopupMenuItem(
//                             value: const Locale('kk'),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.flag, size: 18),
//                                 const SizedBox(width: 8),
//                                 Text('Қазақша'),
//                                 const Spacer(),
//                                 if (Localizations.localeOf(ctx).languageCode ==
//                                     'kk')
//                                   const Icon(Icons.check, size: 18),
//                               ],
//                             ),
//                           ),
//                           PopupMenuItem(
//                             value: const Locale('en'),
//                             child: Row(
//                               children: [
//                                 const Icon(Icons.flag, size: 18),
//                                 const SizedBox(width: 8),
//                                 Text('English'),
//                                 const Spacer(),
//                                 if (Localizations.localeOf(ctx).languageCode ==
//                                     'en')
//                                   const Icon(Icons.check, size: 18),
//                               ],
//                             ),
//                           ),
//                         ],
//                         onSelected: (loc) {
//                           context.read<LocaleProvider>().setLocale(loc);
//                           widget.onAnyTap
//                               ?.call(); // опционально — закрыть drawer
//                         },
//                         child: Row(
//                           children: [
//                             const Icon(Icons.language,
//                                 color: Colors.grey, size: 22),
//                             const SizedBox(width: 6),
//                             Text(
//                               Constants.localeLabel(
//                                   Localizations.localeOf(context).languageCode),
//                               style: const TextStyle(
//                                 color: Colors.grey,
//                                 fontWeight: FontWeight.w600,
//                               ),
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),

//                   // Профиль / авторизация (как у тебя)
//                   IconButton(
//                     icon: (context
//                                     .read<GlobalProvider>()
//                                     .authResponse
//                                     ?.user
//                                     ?.phoneNumber ??
//                                 '')
//                             .trim()
//                             .isNotEmpty
//                         ? _buildProfileIcon(context)
//                         : const Icon(Icons.cloud_off_sharp,
//                             color: Colors.redAccent, size: 24),
//                     onPressed: () {
//                       final phone = context
//                           .read<GlobalProvider>()
//                           .authResponse
//                           ?.user
//                           ?.phoneNumber;
//                       if (phone != null && phone.trim().isNotEmpty) {
//                         Navigator.of(context).push(
//                             MaterialPageRoute(builder: (_) => ProfilePage()));
//                       } else {
//                         Navigator.of(context).push(
//                             MaterialPageRoute(builder: (_) => AuthPage()));
//                       }
//                     },
//                     padding: EdgeInsets.zero,
//                     constraints: const BoxConstraints(),
//                   ),
//                 ],
//               ),
//             ),

//             _buildHeader('Главный экран', Icons.grid_view, true),
//             _buildHeader('Дневник задач', Icons.bookmark_border, false),

//             _buildMenuList(),

//             Divider(
//               indent: _hpad,
//               endIndent: _hpad,
//               height: 16,
//               color: ThemeColors.greyShade,
//             ),

//             _buildTrash(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildProfileIcon(BuildContext context) {
//     final user = context.watch<GlobalProvider>().authResponse?.user;
//     final initials = _getInitials(user?.firstName, user?.lastName);

//     return CircleAvatar(
//       backgroundColor: Colors.lightBlueAccent,
//       radius: 12, // впишется в 24x24 box
//       child: Text(
//         initials,
//         style: const TextStyle(
//             color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
//       ),
//     );
//   }

//   String _getInitials(String? firstName, String? lastName) {
//     final f = firstName?.isNotEmpty == true ? firstName![0] : '';
//     final l = lastName?.isNotEmpty == true ? lastName![0] : '';
//     return (f + l).toUpperCase();
//   }

//   Widget _buildHeader(String title, IconData icon, bool isActive) => InkWell(
//         onTap: widget.onAnyTap,
//         child: Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(horizontal: _hpad, vertical: 12),
//           // Этот BoxDecoration можно оставить, если нужен фон на всю ширину
//           decoration: BoxDecoration(
//             color: isActive ? Colors.lightBlue.shade50 : Colors.transparent,
//             // Для красоты можно добавить скругление, если понадобится
//             // borderRadius: BorderRadius.circular(8),
//           ),
//           child: Row(
//             children: [
//               Icon(icon, color: Colors.grey.shade700, size: 24),
//               const SizedBox(width: 12),
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );

//   Widget _buildMenuList() {
//     final global = context.watch<GlobalProvider>();
//     final taskLists = global.taskLists;

//     // ИЗМЕНЕНО: Убран внешний Padding, который создавал двойной отступ
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Заголовок секции
//         // ИЗМЕНЕНО: Добавлен Padding непосредственно к заголовку
//         Padding(
//           padding: const EdgeInsets.symmetric(horizontal: _hpad),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'СПИСКИ ЗАДАЧ',
//                 style: TextStyle(
//                   fontSize: 14,
//                   color: Colors.grey,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               IconButton(
//                 onPressed: () async {
//                   await showCreateListModal(context); // Просто ждем завершения
//                   final res = await TaskListService().fetchTaskLists(context);
//                   if (res.items != null) {
//                     global.setTaskLists(res.items!);
//                   }
//                 },
//                 icon: const Icon(Icons.add, size: 24, color: Colors.grey),
//               ),
//             ],
//           ),
//         ),

//         const SizedBox(height: 4),

//         // Теперь _buildMenuItem имеет свой собственный правильный отступ
//         ...taskLists.map(_buildMenuItem),
//       ],
//     );
//   }

//   Widget _buildMenuItem(TaskListItems item) {
//     return InkWell(
//       onTap: widget.onAnyTap,
//       // ИЗМЕНЕНО: Теперь этот Padding является единственным и правильным
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: _hpad, vertical: 8),
//         child: Row(
//           children: [
//             SizedBox(
//               width: 24,
//               height: 24,
//               child: Center(
//                 child: Container(
//                   width: 10,
//                   height: 10,
//                   decoration: BoxDecoration(
//                     color: _parseColor(item.colorHex),
//                     shape: BoxShape.circle,
//                   ),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             Expanded(
//               // Добавлено для переноса длинных названий
//               child: Text(
//                 item.name ?? 'Без названия',
//                 style:
//                     const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
//                 overflow: TextOverflow.ellipsis,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Color _parseColor(String? hex) {
//     if (hex == null || hex.isEmpty) return Colors.grey;
//     try {
//       return Color(int.parse(hex.replaceFirst('#', '0xff')));
//     } catch (e) {
//       return Colors.grey;
//     }
//   }

//   Widget _buildTrash() => InkWell(
//         onTap: () {
//           widget.onAnyTap?.call(); // Закрываем drawer перед переходом
//           Navigator.of(context).push(
//             MaterialPageRoute(builder: (context) => const TrashScreen()),
//           );
//         },
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: _hpad, vertical: 12),
//           child: Row(
//             children: [
//               Icon(Icons.delete_outline, color: Colors.grey, size: 24),
//               SizedBox(width: 12),
//               Text(
//                 'Корзина',
//                 style: TextStyle(
//                     fontSize: 16,
//                     color: Colors.black,
//                     fontWeight: FontWeight.w500),
//               ),
//             ],
//           ),
//         ),
//       );
// }
