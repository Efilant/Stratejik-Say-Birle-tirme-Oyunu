import 'package:flutter/material.dart';

/// Sude : UI Tasarım
class AppColors {
  static const Color background = Color.fromARGB(255, 27, 17, 52);
  static const Color foreground = Color(0xFFFAFAFA);
  static const Color card = Color(0xFF1A1625);
  static const Color border = Color(0xFF272727);
  static const Color primary = Color(0xFFFFFFFF);

  static const Map<int, Color> blockColors = {
    1: Color.fromARGB(255, 0, 208, 255),
    2: Color.fromARGB(255, 255, 110, 146),
    3: Color.fromARGB(255, 255, 191, 0),
    4: Color.fromARGB(255, 0, 255, 64),
    5: Color.fromARGB(255, 217, 0, 255),
    6: Color.fromARGB(255, 255, 111, 0),
    7: Color.fromARGB(255, 0, 255, 191),
    8: Color.fromARGB(255, 255, 0, 51),
    9: Color.fromARGB(255, 81, 0, 255),
  };

  static Color getGlowColor(int value) {
    final baseColor = blockColors[value] ?? blockColors[1]!;
    return baseColor.withOpacity(0.5);
  }

  static Color emptyTileBg = Colors.white.withOpacity(0.05);
  static Color emptyTileBorder = Colors.white.withOpacity(0.1);
}
