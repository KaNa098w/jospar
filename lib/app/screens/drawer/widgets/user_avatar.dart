import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';
import 'package:jospar/core/models/auth_response.dart';

class UserAvatar extends StatelessWidget {
  const UserAvatar({
    super.key,
    required this.user,
    required this.radius,
    this.fontSize = 13,
  });

  final User user;
  final double radius;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final avatarUrl = user.avatarUrl?.trim();
    final fallback = Container(
      color: ThemeColors.primary,
      alignment: Alignment.center,
      child: Text(
        _initials(user),
        style: TextStyle(
          color: Colors.white,
          fontSize: fontSize,
          fontWeight: FontWeight.w800,
        ),
      ),
    );

    return SizedBox.square(
      dimension: radius * 2,
      child: ClipOval(
        child: avatarUrl == null || avatarUrl.isEmpty
            ? fallback
            : Image.network(
                avatarUrl,
                key: ValueKey('user-avatar-$avatarUrl'),
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => fallback,
              ),
      ),
    );
  }

  String _initials(User user) {
    final first = (user.firstName ?? '').trim();
    final last = (user.lastName ?? '').trim();
    final firstInitial = first.isEmpty ? '' : first.characters.first;
    final lastInitial = last.isEmpty ? '' : last.characters.first;
    final initials = '$firstInitial$lastInitial'.toUpperCase();
    if (initials.isNotEmpty) return initials;
    final email = (user.email ?? '').trim();
    return email.isEmpty ? 'Я' : email.characters.first.toUpperCase();
  }
}
