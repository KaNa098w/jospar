import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';

class CalendarBadge extends StatelessWidget {
  const CalendarBadge({
    super.key,
    required this.date,
    required this.onTap,
  });

  final DateTime date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final day = date.day.toString();
    return InkWell(
      borderRadius: BorderRadius.circular(8),
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: ThemeColors.primary.withOpacity(0.08),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: ThemeColors.primary, width: 1),
        ),
        child: Text(
          day,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: ThemeColors.primary,
          ),
        ),
      ),
    );
  }
}
