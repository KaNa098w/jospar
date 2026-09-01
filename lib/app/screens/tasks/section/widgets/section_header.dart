import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';

class TaskSectionHeader extends StatelessWidget {
  final String title;
  final int completed;
  final int total;
  final bool expanded;
  final bool showCount;
  final bool showCompletedCount;
  final Color? titleColor;
  final Color? countColor;
  final VoidCallback onToggle;
  final VoidCallback? onCountTap;

  const TaskSectionHeader({
    super.key,
    required this.title,
    required this.completed,
    required this.total,
    required this.expanded,
    required this.onToggle,
    this.showCount = true,
    this.showCompletedCount = true,
    this.titleColor,
    this.countColor,
    this.onCountTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title.toUpperCase(),
            style: TextStyle(
              fontFamily: 'Oswald',
              fontWeight: FontWeight.w700,
              fontSize: 30,
              letterSpacing: -0.5,
              color: titleColor ??
                  (expanded
                      ? ThemeColors.primary
                      : ThemeColors.primary.withValues(alpha: 0.6)),
            ),
          ),
          if (showCount)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onCountTap,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFFD1D5DB)),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  showCompletedCount ? '$completed/$total' : '$total',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: countColor ?? ThemeColors.primary,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
