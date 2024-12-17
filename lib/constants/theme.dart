import 'package:flutter/material.dart';

class ThemeColors {
  // Основная цветовая палитра
  static const Color primary = Colors.lightBlue;
  static const Color secondaryColor = Color(0xFF34C759); // Зеленый
  static const Color backgroundColor = Color(0xFFF5F5F5); // Светлый фон
  static const Color accentColor = Color(0xFFFF9500); // Оранжевый
  static const Color textColor = Color(0xFF000000); // Черный текст
  static const Color grey = Color(0xFF8E8E93); // Серый текст
  static const Color orange = Colors.orange;

  // Цвета для состояния
  static const Color completedTaskColor =
      Color(0xFF4CD964); // Зеленый (задачи выполнены)
  static const Color pendingTaskColor =
      Color(0xFFFF3B30); // Красный (задачи просрочены)
  static const Color checkboxActiveColor =
      Color(0xFF34C759); // Зеленый активного чекбокса
  static const Color checkboxInactiveColor =
      Color(0xFFC7C7CC); // Серый неактивного чекбокса

  // Основной стиль текста
  static const TextStyle headingTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: primary,
  );

  static const TextStyle taskTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textColor,
  );

  static const TextStyle completedTaskTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: grey,
    decoration: TextDecoration.lineThrough,
  );
}
