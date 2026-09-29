import 'package:flutter/material.dart';

// Base Colors
const Color transparent = Color(0x00000000);
const Color white = Color(0xFFFFFFFF);
const Color black = Color(0xFF000000);
const Color redAlert = Color(0xFFD50000);
const Color greyHard = Color.fromARGB(255, 104, 109, 111);

// Financial Status Colors
const Color healthyGreen = Color(0xFF2ECC71);
const Color cautionOrange = Color(0xFFF39C12);
const Color unhealthyRed = Color(0xFFE74C3C);

// Primary Brand Colors (Vaeltryx-inspired)
const Color primaryColor = Color(0xFF4CAF90);
const Color secondaryColor = Color(0xFF7E57C2);
const Color tertiaryColor = Color(0xFFBA68C8);
const Color gray = Color(0xFF616161);

// Dark Background Colors (Vaeltryx palette)
const Color darkBackgroundColor = Color(0xFF0a0f16);
const Color grayDarkBackground = Color(0xFF101922);
const Color surfaceDark = Color(0xFF1e242b);
const Color borderDark = Color(0xFF283039);
const Color outlineColor = Color(0xFF3b4754);
const Color paleGrayColor = Color(0xFF9dabb9);

// Accent Colors
const Color accentTeal = Color(0xFF0bda5b);
const Color primaryBlueDark = Color(0xFF0b5ed7);
const Color purpleAccent = Color(0xFFBA68C8);
const Color orangeAccent = Color(0xFFFF9800);
const Color redAccentColor = Color(0xFFE53935);
const Color tealAccent = Color(0xFF0bda5b);

// Shadow Colors
const Color shadowLight = Color(0x40000000);
const Color shadowMedium = Color(0x1A000000);

// Text Colors (Dark Theme)
const Color textPrimaryDark = Colors.white;
const Color textSecondaryDark = Color(0xFF9dabb9);
const Color textDark = Color(0xFF757575);
const Color textMedium = Color(0xFF616161);

// Error Colors
const Color errorColor = Color(0xFFE53935);

// Hover Colors
Color hoverColorLight(final Color baseColor) =>
    baseColor.withValues(alpha: 0.6);
Color hoverColorExtraLight(final Color baseColor) =>
    baseColor.withValues(alpha: 0.2);

class LightColors {
  static const Color primary = Color(0xFF4CAF90);
  static const Color secondary = Color(0xFF2C3E50);
  static const Color accent = Color(0xFFF4B400);
  static const Color background = Color(0xFFF5F7FA);
  static const Color greyBackground = Color.fromARGB(255, 217, 217, 218);
  static const Color surface = Color(0xFFE1E8ED);
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF7B8A97);
}

// Dark Theme – Vaeltryx-Inspired
class DarkColors {
  static const Color primary = Color(0xFF4CAF90);
  static const Color secondary = Color(0xFF7E57C2);
  static const Color accent = Color(0xFF0bda5b);
  static const Color background = Color(0xFF0a0f16);
  static const Color surface = Color(0xFF1e242b);
  static const Color surfaceLight = Color(0xFF283039);
  static const Color border = Color(0xFF3b4754);
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9dabb9);
  static const Color greyBackground = Color(0xFF101922);
}
