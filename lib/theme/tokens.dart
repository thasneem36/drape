// ─────────────────────────────────────────────────────────────
// Color, typography, spacing, radius, shadow tokens
// Ports drape-design-tokens.json into Dart constants.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';

/// Brand colors.
class AppColors {
  AppColors._();

  // Brand
  static const ink         = Color(0xFF1A1816);
  static const inkSoft     = Color(0xFF3A332D);
  static const accent      = Color(0xFF9B6B4A);
  static const accentInk   = Color(0xFF6D4A31);
  static const accentSoft  = Color(0xFFE8D7C4);
  static const blush       = Color(0xFFD8B0A0);
  static const sage        = Color(0xFF8A9785);

  // Surface
  static const bg          = Color(0xFFF4EFE7);
  static const surface     = Color(0xFFFBF8F2);
  static const surface2    = Color(0xFFEEE7DB);
  static const surface3    = Color(0xFFE5DCCC);

  // Text
  static const textPrimary   = Color(0xFF1A1816);
  static const textSecondary = Color(0xFF3A332D);
  static const muted         = Color(0xFF7A7269);
  static const muted2        = Color(0xFFA89F93);

  // Border (ARGB with alpha)
  static const line        = Color(0x141A1816); // 8%
  static const lineStrong  = Color(0x241A1816); // 14%

  // Status
  static const success     = Color(0xFF5B7A5B);
  static const error       = Color(0xFFB04D3C);
  static const info        = Color(0xFF4A6FA5);
  static const warning     = Color(0xFFC98A3D);

  // Hero gradient presets
  static const heroDark  = [Color(0xFF3D3328), Color(0xFF1F1A14)];
  static const heroMocha = [Color(0xFF8C5A3E), Color(0xFF5E3A26)];
  static const heroSage  = [Color(0xFF3A4A3F), Color(0xFF1E2A22)];

  /// Named product color → swatch map.
  static const swatch = <String, Color>{
    'Black':      Color(0xFF1C1A18),
    'Beige':      Color(0xFFE5DACE),
    'Dusty Rose': Color(0xFFD8B0A0),
    'White':      Color(0xFFF5F1EA),
    'Camel':      Color(0xFFB8956A),
    'Navy':       Color(0xFF1F2A44),
    'Khaki':      Color(0xFFC3B091),
    'Olive':      Color(0xFF6B7A3A),
    'Cream':      Color(0xFFF0E7D5),
    'Grey':       Color(0xFF9E9E9E),
    'Pink':       Color(0xFFF0C6C1),
    'Tan':        Color(0xFFB8956A),
    'Burgundy':   Color(0xFF6D2B2B),
    'Brown':      Color(0xFF6B4A34),
    'Blue':       Color(0xFF5B7FB5),
    'Yellow':     Color(0xFFE9C76B),
    'Light Blue': Color(0xFFBBCFDB),
  };
}

/// Spacing scale (2px unit).
class AppSpacing {
  AppSpacing._();
  static const double s2  = 2, s4  = 4, s6  = 6, s8  = 8, s10 = 10;
  static const double s12 = 12, s14 = 14, s16 = 16, s18 = 18, s20 = 20;
  static const double s22 = 22, s24 = 24, s28 = 28, s32 = 32, s36 = 36;
  static const double s40 = 40, s48 = 48, s56 = 56, s64 = 64;

  // Semantic
  static const EdgeInsets screenPadX = EdgeInsets.symmetric(horizontal: 18);
  static const EdgeInsets cardPad    = EdgeInsets.all(16);
}

/// Corner radii.
class AppRadius {
  AppRadius._();
  static const double xs = 4, sm = 8, md = 10, base = 14, lg = 18;
  static const double xl = 22, xxl = 28, sheet = 32, pill = 999;
}

/// Shadows.
class AppShadows {
  AppShadows._();

  static const List<BoxShadow> sm = [
    BoxShadow(color: Color(0x0A1A1816), blurRadius: 2,  offset: Offset(0, 1)),
    BoxShadow(color: Color(0x081A1816), blurRadius: 6,  offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> md = [
    BoxShadow(color: Color(0x0D1A1816), blurRadius: 6,  offset: Offset(0, 2)),
    BoxShadow(color: Color(0x0F1A1816), blurRadius: 28, offset: Offset(0, 12)),
  ];
  static const List<BoxShadow> lg = [
    BoxShadow(color: Color(0x141A1816), blurRadius: 16, offset: Offset(0, 6)),
    BoxShadow(color: Color(0x1A1A1816), blurRadius: 60, offset: Offset(0, 24)),
  ];
  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0x2E1A1816), blurRadius: 32, offset: Offset(0, 14)),
  ];
  static const List<BoxShadow> sheet = [
    BoxShadow(color: Color(0x1A1A1816), blurRadius: 50, offset: Offset(0, -20)),
  ];
  static const List<BoxShadow> cta = [
    BoxShadow(color: Color(0x401A1816), blurRadius: 24, offset: Offset(0, 10)),
  ];
  static const List<BoxShadow> floating = [
    BoxShadow(color: Color(0x1F1A1816), blurRadius: 30, offset: Offset(0, 10)),
    BoxShadow(color: Color(0x0D1A1816), blurRadius: 6,  offset: Offset(0, 2)),
  ];
  static const List<BoxShadow> hero = [
    BoxShadow(color: Color(0x381A1816), blurRadius: 120, offset: Offset(0, 60)),
  ];
}

/// Motion tokens.
class AppMotion {
  AppMotion._();
  static const Duration fast       = Duration(milliseconds: 120);
  static const Duration base       = Duration(milliseconds: 200);
  static const Duration moderate   = Duration(milliseconds: 280);
  static const Duration slow       = Duration(milliseconds: 500);

  static const Curve standard    = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve decelerate  = Cubic(0.0, 0.0, 0.2, 1);
  static const Curve emphasized  = Cubic(0.2, 0.0, 0.0, 1);
}
