import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jospar/app/screens/settings/settings_page.dart';
import 'package:jospar/app/screens/drawer/widgets/user_avatar.dart';
import 'package:jospar/core/models/auth_response.dart';

class DrawerHeaderBar extends StatelessWidget {
  const DrawerHeaderBar({
    super.key,
    required this.hpad,
    required this.onAuthTap,
    required this.user,
    this.onAnyTap,
  });

  final double hpad;
  final VoidCallback onAuthTap;
  final VoidCallback? onAnyTap;
  final User? user;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: hpad),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            tooltip: 'Настройки',
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
            icon: SvgPicture.asset(
              'assets/icons/settings.svg',
              width: 24,
              height: 24,
              colorFilter: ColorFilter.mode(
                Colors.grey.shade700,
                BlendMode.srcIn,
              ),
            ),
          ),
          IconButton(
            tooltip: user == null ? 'Авторизация' : 'Профиль',
            onPressed: onAuthTap,
            icon: user == null
                ? const Icon(Icons.login_rounded, size: 25)
                : UserAvatar(
                    user: user!,
                    radius: 17,
                  ),
          ),
        ],
      ),
    );
  }
}
