import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jospar/app/screens/auth/phone_input_modul.dart';
import 'package:jospar/app/screens/auth/profile_page.dart';
import 'package:jospar/app/screens/drawer/widgets/drawer_header_bar.dart';
import 'package:jospar/app/screens/drawer/widgets/task_list_section.dart';
import 'package:jospar/app/screens/drawer/widgets/trash_entry.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:provider/provider.dart';
import 'package:jospar/core/constants/provider.dart';
import 'package:jospar/app/screens/trash/trash_screen.dart';
import 'package:jospar/app/screens/shared/shared_tasks_screen.dart';
import 'package:jospar/core/models/task_list_items_response.dart';
import 'package:jospar/core/constants/theme_provider.dart';
import 'package:jospar/app/screens/sync/synchronization_screen.dart';
import 'package:jospar/app/screens/tasks/task_diary_screen.dart';

class CustomDrawer extends StatefulWidget {
  final VoidCallback? onAnyTap;
  final String? selectedTaskListId;
  final VoidCallback? onHomeTap;
  final ValueChanged<TaskListItems>? onTaskListTap;

  const CustomDrawer({
    super.key,
    this.onAnyTap,
    this.selectedTaskListId,
    this.onHomeTap,
    this.onTaskListTap,
  });

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  static const double _hpad = 16.0;

  @override
  Widget build(BuildContext context) {
    final global = context.watch<GlobalProvider>();
    final themeColor = context.watch<AppThemeProvider>().primary;
    final isTealTheme =
        themeColor.toARGB32() == const Color(0xFF009688).toARGB32();
    final user = global.authResponse?.user;
    return Material(
      color: Theme.of(context).colorScheme.surface,
      child: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                children: [
                  const SizedBox(height: 24),
                  DrawerHeaderBar(
                    hpad: _hpad,
                    user: user,
                    onAnyTap: widget.onAnyTap,
                    onAuthTap: () {
                      widget.onAnyTap?.call();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => user == null
                              ? const AuthPage()
                              : const ProfilePage(),
                        ),
                      );
                    },
                  ),
                  _DrawerSectionHeader(
                    title: S.of(context).screenHome,
                    leading: SvgPicture.asset(
                      'assets/icons/elements.svg',
                      width: 17,
                      height: 17,
                      // В новых версиях flutter_svg используем colorFilter:
                      colorFilter: ColorFilter.mode(
                          Colors.grey.shade700, BlendMode.srcIn),
                    ),
                    isActive: widget.selectedTaskListId == null,
                    hpad: _hpad,
                    onTap: () {
                      widget.onHomeTap?.call();
                      widget.onAnyTap?.call();
                    },
                  ),
                  _DrawerSectionHeader(
                    title: S.of(context).screenTaskDiary,
                    leading: Icon(
                      Icons.history_rounded,
                      color: Colors.grey.shade700,
                      size: 20,
                      weight: 300,
                    ),
                    isActive: false,
                    hpad: _hpad,
                    onTap: () async {
                      widget.onAnyTap?.call();
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const TaskDiaryScreen(),
                        ),
                      );
                      if (!context.mounted) return;
                      await global.refreshTasks(context, silent: true);
                    },
                  ),
                  if (isTealTheme)
                    ListTile(
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: _hpad),
                      leading: Icon(Icons.sync_rounded, color: themeColor),
                      title: Text(
                        S.of(context).synchronization,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      onTap: () {
                        widget.onAnyTap?.call();
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const SynchronizationScreen(),
                          ),
                        );
                      },
                    ),

                  // ⬇️ Вместо screenTaskDiary — выбор языка

                  TaskListsSection(
                    hpad: _hpad,
                    selectedTaskListId: widget.selectedTaskListId,
                    onTaskListTap: (item) {
                      widget.onTaskListTap?.call(item);
                      widget.onAnyTap?.call();
                    },
                  ),
                  ListTile(
                    contentPadding:
                        const EdgeInsets.symmetric(horizontal: _hpad),
                    leading: const Icon(Icons.groups_outlined),
                    title: Text(S.of(context).sharedTasks),
                    onTap: () {
                      widget.onAnyTap?.call();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const SharedTasksScreen(),
                        ),
                      );
                    },
                  ),
                  const Divider(
                    indent: _hpad,
                    endIndent: _hpad,
                    height: 16,
                    color: Color(0xFFE0E0E0),
                  ),
                  TrashEntry(
                    hpad: _hpad,
                    onTap: () {
                      widget.onAnyTap?.call();
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const TrashScreen()),
                      );
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(global.inComingHash ?? ''),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerSectionHeader extends StatelessWidget {
  final String title;
  final Widget leading; // ← было IconData icon
  final bool isActive;
  final double hpad;
  final VoidCallback? onTap;

  const _DrawerSectionHeader({
    required this.title,
    required this.leading,
    required this.isActive,
    required this.hpad,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: hpad, vertical: 12),
        decoration: BoxDecoration(
          color: isActive
              ? colors.primary.withValues(alpha: .13)
              : Colors.transparent,
        ),
        child: Row(children: [
          SizedBox(
            width: 24,
            height: 24,
            child: Center(child: leading),
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.onSurface,
            ),
          ),
        ]),
      ),
    );
  }
}
