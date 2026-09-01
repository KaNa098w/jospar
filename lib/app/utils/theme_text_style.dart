import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';

abstract class ThemeTextMontserratMedium {
  static const FontWeight fontWeight = FontWeight.w500;
  static const String fontFamily = "Roboto";
  static const Color fontColor = ThemeColors.white;

  static final TextStyle size9 = TextStyle(
    color: fontColor,
    fontWeight: fontWeight,
    fontFamily: fontFamily,
    fontStyle: FontStyle.normal,
    letterSpacing: 0.2,
    height: 1.4,
    fontSize: 9,
  );
}

abstract class ThemeTextMontserratBold {
  static const FontWeight fontWeight = FontWeight.w700;
  static const String fontFamily = "Roboto";
  static Color fontColor = ThemeColors.black;

  static final TextStyle size21 = TextStyle(
    color: fontColor,
    fontWeight: fontWeight,
    fontFamily: fontFamily,
    fontStyle: FontStyle.normal,
    letterSpacing: 0.3,
    height: 1.4,
    fontSize: 21,
  );

  static final TextStyle size18 = size21.copyWith(fontSize: 18);
  static final TextStyle size22 =
      size21.copyWith(fontSize: 22, letterSpacing: 0.2);
  static final TextStyle size24 =
      size21.copyWith(fontSize: 24, letterSpacing: 0.2);

  /// Позволяет быстрoе переопределение основных параметров
  static TextStyle copyWith({
    double fontSize = 21,
    // Color color = fontColor,
    TextDecoration decoration = TextDecoration.none,
  }) {
    return size21.copyWith(
      fontSize: fontSize,
      // color: color,
      decoration: decoration,
    );
  }
}

abstract class ThemeTextRobotoMedium {
  static const FontWeight fontWeight = FontWeight.w500;
  static const String fontFamily = "Roboto";
  static const Color fontColor = ThemeColors.white;

  static final TextStyle size15 = TextStyle(
    color: fontColor,
    fontWeight: fontWeight,
    fontFamily: fontFamily,
    fontStyle: FontStyle.normal,
    letterSpacing: 0.2,
    height: 1.4,
    fontSize: 15,
  );
}

abstract class ThemeTextRobotoRegular {
  static const FontWeight fontWeight = FontWeight.w400;
  static const String fontFamily = "Roboto";
  static const Color fontColor = ThemeColors.grey5;

  static final TextStyle size11 = TextStyle(
    color: fontColor,
    fontWeight: fontWeight,
    fontFamily: fontFamily,
    fontStyle: FontStyle.normal,
    letterSpacing: 0.2,
    height: 1.4,
    fontSize: 11,
  );
}

String getInitialFormattedNumber(String format, String str) {
  if (str.isEmpty) return '';
  var mask = format;
  for (var char in str.split('')) {
    mask = mask.replaceFirst('x', char);
  }
  return mask.replaceAll('x', '');
}
