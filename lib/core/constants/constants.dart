import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';

class Constants {
  static const title = "Jospar";
  static const baseUrl = "https://jospar.kz/api";

  static String localeLabel(String code) {
    switch (code) {
      case 'ru':
        return 'RU';
      case 'kk':
        return 'KK';
      case 'en':
        return 'EN';
      default:
        return code.toUpperCase();
    }
  }
}

// где-нибудь рядом (например, в add_task_modal.dart наверху)
enum Urgency { low, medium, high }

Urgency? nextUrgency(Urgency? u) {
  if (u == null) return Urgency.low;
  if (u == Urgency.low) return Urgency.medium;
  if (u == Urgency.medium) return Urgency.high;
  return null; // high -> null
}

Color urgencyColor(Urgency? u) {
  if (u == Urgency.low) return Colors.green; // жёлтый
  if (u == Urgency.medium) return Colors.amber; // «полу-красный»
  if (u == Urgency.high) return Colors.red; // красный
  return ThemeColors.primary; // обычный
}

String? urgencyToApi(Urgency? u) {
  if (u == Urgency.low) return 'low';
  if (u == Urgency.medium) return 'medium';
  if (u == Urgency.high) return 'high';
  return null;
}

Urgency? urgencyFromApi(String? value) {
  switch (value?.toLowerCase()) {
    case 'low':
      return Urgency.low;
    case 'medium':
      return Urgency.medium;
    case 'high':
    case 'hight':
      return Urgency.high;
    default:
      return null;
  }
}

// Яркий фон по уровню (для невыполненных)
Color? _urgencyBg(String? u, bool isCompleted) {
  if (isCompleted || u == null) return null;
  switch (u.toLowerCase()) {
    case 'low':
      return const Color(0xFFFFF59D); // ярко-жёлтый (Yellow 300)
    case 'medium':
      return const Color(0xFFFFB74D); // ярко-оранжевый (Orange 300)
    case 'high':
    case 'hight': // на всякий случай
      return const Color(0xFFFF8A80); // ярко-красный (Red 200)
  }
  return null;
}

// Соответствующий бордер
Color _urgencyBorder(String? u) {
  switch ((u ?? '').toLowerCase()) {
    case 'low':
      return const Color(0xFFFBC02D); // Yellow 700
    case 'medium':
      return const Color(0xFFF57C00); // Orange 800
    case 'high':
    case 'hight':
      return const Color(0xFFD32F2F); // Red 700
    default:
      return const Color(0xFFE5E7EB); // тонкий серый по умолчанию
  }
}
