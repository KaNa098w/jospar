import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/app/screens/drawer/widgets/user_avatar.dart';
import 'package:jospar/core/models/auth_response.dart';

class DrawerAccountSection extends StatelessWidget {
  const DrawerAccountSection({
    super.key,
    required this.user,
    required this.onOpen,
    this.onLogout,
  });

  final User? user;
  final VoidCallback onOpen;
  final VoidCallback? onLogout;

  @override
  Widget build(BuildContext context) {
    if (user == null) {
      return Card(
        margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
        elevation: 0,
        color: ThemeColors.primary.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: ListTile(
          leading: CircleAvatar(
            backgroundColor: ThemeColors.primary,
            foregroundColor: Colors.white,
            child: const Icon(Icons.person_add_alt_1),
          ),
          title: const Text(
            'Войти или зарегистрироваться',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          subtitle: const Text('Для синхронизации и совместных задач'),
          trailing: const Icon(Icons.chevron_right),
          onTap: onOpen,
        ),
      );
    }

    final fullName = '${user!.firstName ?? ''} ${user!.lastName ?? ''}'.trim();
    final contact = (user!.phoneNumber ?? user!.email ?? '').trim();

    return Card(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      elevation: 0,
      color: const Color(0xFFF7F8FC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE7E9F2)),
      ),
      child: ListTile(
        leading: UserAvatar(user: user!, radius: 20, fontSize: 15),
        title: Text(
          fullName.isEmpty ? 'Мой профиль' : fullName,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: contact.isEmpty
            ? const Text('Профиль')
            : Text(
                contact,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        onTap: onOpen,
        trailing: IconButton(
          tooltip: 'Выйти из аккаунта',
          icon: const Icon(Icons.logout_rounded, color: Colors.redAccent),
          onPressed: onLogout,
        ),
      ),
    );
  }
}
