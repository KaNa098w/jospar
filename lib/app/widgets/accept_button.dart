import 'package:flutter/material.dart';
import 'package:jospar/app/utils/theme.dart';

class AcceptButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final double fontSize;
  final Color? color;

  AcceptButton(
      {Key? key,
      required this.text,
      required this.onPressed,
      this.padding = const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      this.borderRadius = 12,
      this.fontSize = 14,
      this.color})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Color effectiveColor = color ?? ThemeColors.primary;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: effectiveColor,
        foregroundColor: Colors.white,
        padding: padding,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0,
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
