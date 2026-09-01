import 'dart:math';
import 'package:flutter/services.dart';

class PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    String digits = newValue.text.replaceAll(RegExp(r'\D'), '');

    // Пусто — ничего не подставляем
    if (digits.isEmpty) {
      return const TextEditingValue(
        text: '',
        selection: TextSelection.collapsed(offset: 0),
      );
    }

    // Нормализуем 8xxxxxxxxxxx -> 7xxxxxxxxxxx (11 цифр)
    if (digits.startsWith('8') && digits.length >= 11) {
      digits = '7' + digits.substring(1);
    }

    // Если номер действительно казахстанский (начинается с 7) — применяем маску +7 XXX XXX-XX-XX
    if (digits.startsWith('7')) {
      if (digits.length > 11) digits = digits.substring(0, 11);

      String formatted = '+7';
      if (digits.length > 1) {
        formatted += ' ${digits.substring(1, min(4, digits.length))}';
      }
      if (digits.length > 4) {
        formatted += ' ${digits.substring(4, min(7, digits.length))}';
      }
      if (digits.length > 7) {
        formatted += '-${digits.substring(7, min(9, digits.length))}';
      }
      if (digits.length > 9) {
        formatted += '-${digits.substring(9, min(11, digits.length))}';
      }

      return TextEditingValue(
        text: formatted,
        selection: TextSelection.collapsed(offset: formatted.length),
      );
    }

    // Иначе — не навязываем +7, показываем просто цифры
    return TextEditingValue(
      text: digits,
      selection: TextSelection.collapsed(offset: digits.length),
    );
  }
}
