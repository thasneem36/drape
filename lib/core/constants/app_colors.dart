import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Brand ────────────────────────────────────────────────────
  static const Color ink           = Color(0xFF1A1816);
  static const Color inkSoft       = Color(0xFF3A332D);
  static const Color accent        = Color(0xFF9B6B4A); // Mocha
  static const Color accentInk     = Color(0xFF6D4A31);
  static const Color accentSoft    = Color(0xFFE8D7C4);
  static const Color blush         = Color(0xFFD8B0A0);
  static const Color sage          = Color(0xFF8A9785);
  static const Color onAccent      = Color(0xFFFFFFFF);

  // ── Surfaces ─────────────────────────────────────────────────
  static const Color bg      = Color(0xFFF4EFE7);
  static const Color surface  = Color(0xFFFBF8F2);
  static const Color surface2 = Color(0xFFEEE7DB);
  static const Color surface3 = Color(0xFFE5DCCC);

  // ── Text ─────────────────────────────────────────────────────
  static const Color textPrimary   = Color(0xFF1A1816);
  static const Color textSecondary = Color(0xFF3A332D);
  static const Color textMuted     = Color(0xFF7A7269);
  static const Color textMuted2    = Color(0xFFA89F93);

  // ── Borders ──────────────────────────────────────────────────
  static const Color borderLine   = Color(0x141A1816); // rgba(26,24,22,0.08)
  static const Color borderStrong = Color(0x241A1816); // rgba(26,24,22,0.14)

  // ── Status ───────────────────────────────────────────────────
  static const Color success = Color(0xFF5B7A5B);
  static const Color error   = Color(0xFFB04D3C);
  static const Color info    = Color(0xFF4A6FA5);
  static const Color warning = Color(0xFFC98A3D);

  // ── Aliases (keep old names compiling while screens are migrated) ──
  static const Color primary             = ink;
  static const Color primaryDark         = inkSoft;
  static const Color secondary           = accentInk;
  static const Color secondaryContainer  = accentSoft;
  static const Color background          = bg;
  static const Color surfaceContainerLowest = surface;
  static const Color surfaceContainerLow   = surface2;
  static const Color surfaceContainer      = surface3;
  static const Color surfaceContainerHigh  = surface3;
  static const Color onSurface         = textPrimary;
  static const Color onSurfaceVariant  = textSecondary;
  static const Color outlineVariant    = borderLine;
  static const Color border            = borderStrong;

  // ── Short aliases used by lib/screens/** ───────────────────
  static const Color muted      = textMuted;
  static const Color line       = borderLine;
  static const Color lineStrong = borderStrong;

  // ── Color swatch map for product color dots ────────────────
  static const Map<String, Color> swatch = {
    'Black':      Color(0xFF1A1816),
    'Beige':      Color(0xFFD4C4A0),
    'Dusty Rose': Color(0xFFD8A0A0),
    'White':      Color(0xFFF5F0E8),
    'Camel':      Color(0xFFBFA57C),
    'Navy':       Color(0xFF1E2A4A),
    'Khaki':      Color(0xFF9C8E6E),
    'Olive':      Color(0xFF6E7A4A),
    'Cream':      Color(0xFFE9DCC4),
    'Grey':       Color(0xFF8A8A8A),
    'Pink':       Color(0xFFD88A87),
    'Yellow':     Color(0xFFE8C44A),
    'Blue':       Color(0xFF5A7AA0),
    'Tan':        Color(0xFFC4965A),
    'Burgundy':   Color(0xFF8C3A3A),
    'Brown':      Color(0xFF7A5A3A),
    'Light Blue': Color(0xFFA9BBCD),
  };
}
