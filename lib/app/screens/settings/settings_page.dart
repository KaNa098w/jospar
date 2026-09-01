import 'package:app_settings/app_settings.dart';
import 'package:flutter/material.dart';
import 'package:jospar/app/screens/settings/settings_pages/language_page.dart';
import 'package:jospar/app/screens/settings/settings_pages/politic_screen.dart';
import 'package:jospar/app/screens/settings/settings_pages/theme_page.dart';
import 'package:jospar/app/utils/custom_appbar.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: CustomAppBar(title: S.of(context).settings),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _SectionCard(
                  children: [
                    _SettingsTile(
                      icon: Icons.language,
                      text: "Язык",
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const LanguagePage()));
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.color_lens_outlined,
                      text: "Тема",
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const ThemePage()));
                      },
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_outlined,
                      text: "Уведомления",
                      onTap: () => AppSettings.openAppSettings(),
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_outlined,
                      text: "Политика конфиденциальности",
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => const PoliticScreen()));
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          FutureBuilder<PackageInfo>(
            future: _packageInfo,
            builder: (context, snapshot) {
              final info = snapshot.data;
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
                child: Text(
                  info == null
                      ? 'Версия'
                      : 'Версия ${info.version}  •  '
                          'Сборка ${info.buildNumber}',
                  key: const ValueKey('settings-app-version'),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 12,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

/// Обёртка для секции (группа пунктов в карточке)
class _SectionCard extends StatelessWidget {
  final List<Widget> children;
  const _SectionCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Material(
      color: colors.surface,
      elevation: 3,
      shadowColor: Colors.black12,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: List.generate(children.length, (i) {
          return Column(
            children: [
              children[i],
              if (i != children.length - 1)
                const Divider(
                  height: 1,
                  thickness: 0.6,
                  indent: 56,
                  color: Color(0xFFEAEAEA),
                ),
            ],
          );
        }),
      ),
    );
  }
}

/// Универсальный пункт меню
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: ThemeColors.primary.withValues(alpha: 0.1),
        child: Icon(icon, color: ThemeColors.primary),
      ),
      title: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
