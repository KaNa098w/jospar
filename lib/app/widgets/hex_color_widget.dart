import 'dart:ui';

Color _parseHex(String? hex) {
  if (hex == null || hex.isEmpty) return const Color(0xFFCCCCCC);
  var s = hex.trim();
  if (s.startsWith('#')) s = s.substring(1);
  if (s.length == 6) s = 'FF$s';
  try {
    return Color(int.parse(s, radix: 16));
  } catch (_) {
    return const Color(0xFFCCCCCC);
  }
}
