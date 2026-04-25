import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppText {
  AppText._();

  static TextStyle _serif(double size, {FontWeight w = FontWeight.w500, double h = 1.1, double ls = -0.02, bool italic = true}) =>
      GoogleFonts.fraunces(fontSize: size, fontWeight: w, height: h, letterSpacing: size * ls,
          fontStyle: italic ? FontStyle.italic : FontStyle.normal, color: AppColors.textPrimary);

  static TextStyle _sans(double size, {FontWeight w = FontWeight.w400, double h = 1.5, double ls = 0}) =>
      GoogleFonts.inter(fontSize: size, fontWeight: w, height: h, letterSpacing: ls, color: AppColors.textPrimary);

  static TextStyle _mono(double size, {FontWeight w = FontWeight.w500, double ls = 0.1}) =>
      GoogleFonts.jetBrainsMono(fontSize: size, fontWeight: w, letterSpacing: size * ls, color: AppColors.textPrimary);

  static TextStyle get displayXL  => _serif(48, w: FontWeight.w400, h: 1.02, ls: -0.03);
  static TextStyle get displayL   => _serif(40, h: 1.05, ls: -0.03);
  static TextStyle get displayM   => _serif(36, h: 1.00);
  static TextStyle get displayS   => _serif(34, h: 1.10);
  static TextStyle get titleXL    => _serif(30, h: 1.10);
  static TextStyle get titleL     => _serif(26, h: 1.15);
  static TextStyle get titleM     => _serif(22, h: 1.20, ls: -0.01);
  static TextStyle get titleS     => _serif(18, w: FontWeight.w600, h: 1.30, ls: -0.01, italic: false);
  static TextStyle get productName => _serif(15, w: FontWeight.w500, h: 1.25, ls: -0.01, italic: false);
  static TextStyle get bodyL      => _sans(15, w: FontWeight.w500, h: 1.55);
  static TextStyle get bodyM      => _sans(14, h: 1.60);
  static TextStyle get bodyS      => _sans(13, h: 1.55);
  static TextStyle get caption    => _sans(12, w: FontWeight.w500, h: 1.40);
  static TextStyle get label      => _sans(11, w: FontWeight.w600, h: 1.30, ls: 1.54);
  static TextStyle get eyebrow    => _sans(10, w: FontWeight.w600, h: 1.20, ls: 2.2).copyWith(color: AppColors.muted);
  static TextStyle get micro      => _sans(9,  w: FontWeight.w700, h: 1.20, ls: 1.8);
  static TextStyle get mono       => _mono(10);
}

typedef AppTextStyles = AppText;
