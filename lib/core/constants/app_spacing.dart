import 'package:flutter/material.dart';

class AppSpacing {
  AppSpacing._();
  static const double s2  = 2,  s4  = 4,  s6  = 6,  s8  = 8,  s10 = 10;
  static const double s12 = 12, s14 = 14, s16 = 16, s18 = 18, s20 = 20;
  static const double s22 = 22, s24 = 24, s28 = 28, s32 = 32, s36 = 36;
  static const double s40 = 40, s48 = 48, s56 = 56, s64 = 64;
  static const EdgeInsets screenPadX = EdgeInsets.symmetric(horizontal: 18);
  static const EdgeInsets cardPad    = EdgeInsets.all(16);
}

class AppRadius {
  AppRadius._();
  static const double xs = 4, sm = 8, md = 10, base = 14, lg = 18;
  static const double xl = 22, xxl = 28, sheet = 32, pill = 999;
}

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

class AppMotion {
  AppMotion._();
  static const Duration fast     = Duration(milliseconds: 120);
  static const Duration base     = Duration(milliseconds: 200);
  static const Duration moderate = Duration(milliseconds: 280);
  static const Duration slow     = Duration(milliseconds: 500);
  static const Curve standard   = Cubic(0.2, 0.8, 0.2, 1);
  static const Curve decelerate = Cubic(0.0, 0.0, 0.2, 1);
  static const Curve emphasized = Cubic(0.2, 0.0, 0.0, 1);
}
