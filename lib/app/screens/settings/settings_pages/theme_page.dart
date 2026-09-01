// theme_page.dart
import 'package:flutter/material.dart';
import 'package:jospar/core/constants/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:jospar/app/utils/custom_appbar.dart';

class ThemePage extends StatelessWidget {
  const ThemePage({super.key});

  @override
  Widget build(BuildContext context) {
    final appTheme = context.watch<AppThemeProvider>();
    final current = appTheme.primary;
    final colors = Theme.of(context).colorScheme;

    const presets = <_ThemePreset>[
      _ThemePreset(name: 'Ocean Blue', color: Color(0xFF0267AA)),
      _ThemePreset(name: 'Emerald', color: Color(0xFF10B981)),
      _ThemePreset(name: 'Royal Purple', color: Color(0xFF7C3AED)),
      _ThemePreset(name: 'Sunset', color: Color(0xFFFF6B6B)),
      _ThemePreset(name: 'Amber', color: Color(0xFFFFB300)),
      _ThemePreset(name: 'Indigo', color: Color(0xFF3F51B5)),
      _ThemePreset(name: 'Teal', color: Color(0xFF009688)),
      _ThemePreset(name: 'Pink', color: Color(0xFFE91E63)),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: const CustomAppBar(title: 'Тема'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Режим оформления',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          _AppearanceModeCard(
            selectedMode: appTheme.mode,
            onSelected: (mode) async {
              final persistence = appTheme.setMode(mode);
              context.go('/tasks');
              await persistence;
            },
          ),
          const SizedBox(height: 24),
          Text(
            'Цвет акцента',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: colors.onSurface,
                ),
          ),
          const SizedBox(height: 10),
          ...presets.map((p) {
            final isSelected = _sameColor(p.color, current);
            return _ThemeOptionTile(
              name: p.name,
              color: p.color,
              selected: isSelected,
              onTap: () async {
                // setPrimary updates the provider synchronously before it
                // persists the selection. Navigate immediately so the user
                // sees the selected theme on the main screen without waiting
                // for SharedPreferences I/O.
                final persistence = appTheme.setPrimary(p.color);
                context.go('/tasks');
                await persistence;
              },
            );
          }),
        ],
      ),
    );
  }

  bool _sameColor(Color a, Color b) => a.toARGB32() == b.toARGB32();
}

class _AppearanceModeCard extends StatelessWidget {
  const _AppearanceModeCard({
    required this.selectedMode,
    required this.onSelected,
  });

  final ThemeMode selectedMode;
  final ValueChanged<ThemeMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    const options = <(ThemeMode, IconData, String)>[
      (ThemeMode.light, Icons.light_mode_rounded, 'Светлая'),
      (ThemeMode.dark, Icons.dark_mode_rounded, 'Тёмная'),
      (ThemeMode.system, Icons.settings_suggest_rounded, 'Системная'),
    ];

    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Row(
          children: options.map((option) {
            final (mode, icon, label) = option;
            final selected = selectedMode == mode;
            return Expanded(
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => onSelected(mode),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  decoration: BoxDecoration(
                    color: selected
                        ? colors.primary.withValues(alpha: .14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: selected
                          ? colors.primary.withValues(alpha: .45)
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        icon,
                        size: 23,
                        color:
                            selected ? colors.primary : colors.onSurfaceVariant,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight:
                              selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected
                              ? colors.primary
                              : colors.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(growable: false),
        ),
      ),
    );
  }
}

class _ThemePreset {
  final String name;
  final Color color;
  const _ThemePreset({required this.name, required this.color});
}

class _ThemeOptionTile extends StatefulWidget {
  final String name;
  final Color color;
  final bool selected;
  final VoidCallback onTap;

  const _ThemeOptionTile({
    required this.name,
    required this.color,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_ThemeOptionTile> createState() => _ThemeOptionTileState();
}

class _ThemeOptionTileState extends State<_ThemeOptionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 160));
  late final Animation<double> _scale = Tween(begin: 1.0, end: 0.98).animate(
    CurvedAnimation(parent: _controller, curve: Curves.easeOut),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails _) => _controller.forward();
  void _handleTapCancel() => _controller.reverse();
  void _handleTapUp(TapUpDetails _) {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final selected = widget.selected;
    final colors = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected
                ? widget.color.withValues(alpha: 0.12)
                : colors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: const [
              BoxShadow(
                color: Color(0x11000000),
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: widget.onTap,
            onTapDown: _handleTapDown,
            onTapCancel: _handleTapCancel,
            onTapUp: _handleTapUp,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              child: Row(
                children: [
                  _ColorBadge(color: widget.color),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.name,
                      style: TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: colors.onSurface,
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: selected ? 1 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.check_circle,
                      size: 22,
                      color: widget.color,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Icon(
                    Icons.chevron_right,
                    color: colors.onSurfaceVariant,
                    size: 22,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorBadge extends StatelessWidget {
  final Color color;
  const _ColorBadge({required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.5), width: 1),
      ),
      child: Center(
        child: Container(
          width: 18,
          height: 18,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
      ),
    );
  }
}
