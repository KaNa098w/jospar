import 'package:flutter/material.dart';
import 'package:jospar/core/l10n/s.dart';
import 'package:jospar/core/services/share_delivery_mode.dart';

Future<ShareDeliveryMode?> showShareDeliverySheet(BuildContext context) {
  return showModalBottomSheet<ShareDeliveryMode>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (sheetContext) => _ShareDeliverySheet(
      onSelected: (mode) => Navigator.pop(sheetContext, mode),
    ),
  );
}

class _ShareDeliverySheet extends StatelessWidget {
  const _ShareDeliverySheet({required this.onSelected});

  final ValueChanged<ShareDeliveryMode> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return SafeArea(
      top: false,
      bottom: false,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          20,
          10,
          20,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x24000000),
              blurRadius: 28,
              offset: Offset(0, -8),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 42,
                height: 5,
                decoration: BoxDecoration(
                  color: colors.outlineVariant,
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              S.of(context).howToSendTask,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              S.of(context).subtasksIncluded,
              style: TextStyle(
                color: colors.onSurfaceVariant,
                fontSize: 14,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),
            _DeliveryOption(
              icon: Icons.groups_2_rounded,
              label: S.of(context).workTogether,
              description: S.of(context).workTogetherHint,
              color: colors.primary,
              backgroundColor: colors.primary.withValues(alpha: .07),
              onTap: () => onSelected(ShareDeliveryMode.collaborate),
            ),
            const SizedBox(height: 10),
            _DeliveryOption(
              icon: Icons.copy_all_outlined,
              label: S.of(context).sendAsCopy,
              description: S.of(context).sendAsCopyHint,
              color: const Color(0xFF667085),
              backgroundColor: const Color(0xFFF6F7F9),
              onTap: () => onSelected(ShareDeliveryMode.duplicate),
            ),
          ],
        ),
      ),
    );
  }
}

class _DeliveryOption extends StatelessWidget {
  const _DeliveryOption({
    required this.icon,
    required this.label,
    required this.description,
    required this.color,
    required this.backgroundColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color color;
  final Color backgroundColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(18),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .82),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 23),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: TextStyle(
                        color: color,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                        fontSize: 13,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, color: color, size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
