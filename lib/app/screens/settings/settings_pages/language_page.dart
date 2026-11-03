import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/constants/local_provider.dart';
import 'package:provider/provider.dart';

import 'package:jospar/app/utils/custom_appbar.dart';
import 'package:jospar/core/l10n/s.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = context.watch<LocaleProvider>();
    final currentCode = localeProvider.locale.languageCode;

    const languages = [
      {'code': 'ru', 'label': 'Русский', 'emoji': '🇷🇺'},
      {'code': 'kk', 'label': 'Қазақша', 'emoji': '🇰🇿'},
      {'code': 'en', 'label': 'English', 'emoji': '🇬🇧'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: S.of(context).language),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SizedBox(height: 4),
          ...languages.map((lang) {
            final code = lang['code']!;
            final isSelected = code == currentCode;

            return _LanguageOptionTile(
              emoji: lang['emoji']!,
              label: lang['label']!,
              selected: isSelected,
              onTap: () async {
                await localeProvider.setLocale(Locale(code));
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            );
          }),
        ],
      ),
    );
  }
}

class _LanguageOptionTile extends StatefulWidget {
  final String emoji;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageOptionTile({
    required this.emoji,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  State<_LanguageOptionTile> createState() => _LanguageOptionTileState();
}

class _LanguageOptionTileState extends State<_LanguageOptionTile>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 160));
  late final Animation<double> _scale = Tween(begin: 1.0, end: 0.98)
      .animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

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

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          decoration: BoxDecoration(
            color: selected
                ? ThemeColors.primary.withValues(alpha: 0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(16),
            // border: Border.all(
            //   color: selected ? theme.colorScheme.primary.withOpacity(0.35) : const Color(0xFFECECEC),
            //   width: 1,
            // ),
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
                  // Иконка-флажок
                  _EmojiBadge(emoji: widget.emoji),
                  const SizedBox(width: 12),

                  // Название языка
                  Expanded(
                    child: Text(
                      widget.label,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ),

                  // Индикатор выбранного
                  AnimatedOpacity(
                    opacity: selected ? 1 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.check_circle,
                      size: 22,
                      color: ThemeColors.primary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.chevron_right, color: Colors.grey, size: 22),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EmojiBadge extends StatelessWidget {
  final String emoji;
  const _EmojiBadge({required this.emoji});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 38,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: ThemeColors.primary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        emoji,
        style: const TextStyle(fontSize: 20),
      ),
    );
  }
}
