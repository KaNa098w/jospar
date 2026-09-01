import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jospar/core/l10n/s.dart';

class TrashEntry extends StatelessWidget {
  final double hpad;
  final VoidCallback? onTap;

  const TrashEntry({super.key, required this.hpad, this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: hpad, vertical: 12),
        child: Row(
          children: [
            SvgPicture.asset(
              'assets/icons/trash.svg',
              width: 17,
              height: 17,
              colorFilter: ColorFilter.mode(
                colors.onSurfaceVariant,
                BlendMode.srcIn,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              S.of(context).screenCart,
              style: TextStyle(
                fontSize: 16,
                color: colors.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
