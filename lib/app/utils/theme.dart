// theme.dart
import 'package:flutter/material.dart';

class ThemeColors {
  // ВАЖНО: делаем primary изменяемым (без const)
  static Color primary = const Color(0xFF0267AA);

  static const Color secondaryColor = Color(0xFF34C759);
  static const Color backgroundColor = Color(0xFFF5F5F5);
  static const Color accentColor = Color(0xFFFF9500);
  static const Color textColor = Color(0xFF000000);
  static Color grey = Colors.grey.shade400;

  static const Color orange = Colors.orange;
  static const transparent = Color(0x00000000);
  static const white = Color(0xFFFFFFFF);
  static const grey2 = Color(0xFFF5F5F5);
  static const greyForCommon = Color.fromARGB(255, 229, 228, 228);
  static const grey3 = Color(0xFFBDBDBD);
  static const grey4 = Color(0xFFd9d9d9);
  static const grey5 = Color(0xFF4F4F4F);

  static const grey6 = Color(0xFF9A9DA4);
  static const grey7 = Color(0xFFE7E7E9);
  static const greyShade = Color.fromARGB(255, 222, 221, 221);
  static const grey8 = Color(0xFF888B93);
  static const grey9 = Color(0xFFE8E7E7);
  static const greyForHint = Color.fromARGB(255, 218, 216, 216);
  static const blue = Colors.blue;
  static const redAccent = Color.fromARGB(255, 248, 88, 88);
  static const black2 = Color(0xFF4F4F4F);

  static const black = Colors.black87;
  static const grey10 = Color(0xFFE7E7E9);

  static const green1 = Colors.green;
  static const green = Color.fromARGB(255, 75, 212, 110);
  static const error = Color(0xFFE2100C);
  static const iBrandPrimary = Color(0xFF2B63F3);

  static const Color completedTaskColor = Color(0xFF4CD964);
  static const Color pendingTaskColor = Color(0xFFFF3B30);
  static const Color checkboxActiveColor = Color(0xFF34C759);
  static const Color checkboxInactiveColor = Color(0xFFC7C7CC);

  static const TextStyle headingTextStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: textColor,
  );

  static const TextStyle sectionTitleStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.black87, // не хардкодим primary, чтобы не ломать статику
  );

  static const TextStyle taskTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textColor,
  );

  static TextStyle completedTaskTextStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: grey,
    decoration: TextDecoration.lineThrough,
  );
}
