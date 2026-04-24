import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// All letter-spacing values are converted from em to logical pixels:
//   letterSpacingPx = em * fontSize

class AppTextStyles {
  AppTextStyles._();

  // ── Display — Fraunces italic ────────────────────────────────
  static TextStyle displayXL = GoogleFonts.fraunces(
    fontSize: 48, height: 1.02, fontWeight: FontWeight.w400,
    fontStyle: FontStyle.italic, letterSpacing: -1.44,
  );
  static TextStyle displayL = GoogleFonts.fraunces(
    fontSize: 40, height: 1.05, fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic, letterSpacing: -1.20,
  );
  static TextStyle displayM = GoogleFonts.fraunces(
    fontSize: 36, height: 1.00, fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic, letterSpacing: -0.72,
  );
  static TextStyle displayS = GoogleFonts.fraunces(
    fontSize: 34, height: 1.10, fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic, letterSpacing: -0.68,
  );

  // ── Title — Fraunces italic ──────────────────────────────────
  static TextStyle titleXL = GoogleFonts.fraunces(
    fontSize: 30, height: 1.10, fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic, letterSpacing: -0.60,
  );
  static TextStyle titleL = GoogleFonts.fraunces(
    fontSize: 26, height: 1.15, fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic, letterSpacing: -0.52,
  );
  static TextStyle titleM = GoogleFonts.fraunces(
    fontSize: 22, height: 1.20, fontWeight: FontWeight.w500,
    fontStyle: FontStyle.italic, letterSpacing: -0.22,
  );
  static TextStyle titleS = GoogleFonts.fraunces(
    fontSize: 18, height: 1.30, fontWeight: FontWeight.w600,
    letterSpacing: -0.18,
  );

  // ── Body — Inter ─────────────────────────────────────────────
  static TextStyle bodyL = GoogleFonts.inter(
    fontSize: 15, height: 1.55, fontWeight: FontWeight.w500,
    letterSpacing: -0.15,
  );
  static TextStyle bodyM = GoogleFonts.inter(
    fontSize: 14, height: 1.60, fontWeight: FontWeight.w400,
  );
  static TextStyle bodyS = GoogleFonts.inter(
    fontSize: 13, height: 1.55, fontWeight: FontWeight.w400,
  );
  static TextStyle caption = GoogleFonts.inter(
    fontSize: 12, height: 1.40, fontWeight: FontWeight.w500,
  );

  // ── Utility — Inter uppercase ────────────────────────────────
  static TextStyle label = GoogleFonts.inter(
    fontSize: 11, height: 1.30, fontWeight: FontWeight.w600,
    letterSpacing: 1.54,
  );
  static TextStyle eyebrow = GoogleFonts.inter(
    fontSize: 10, height: 1.20, fontWeight: FontWeight.w600,
    letterSpacing: 2.20,
  );
  static TextStyle micro = GoogleFonts.inter(
    fontSize: 9, height: 1.20, fontWeight: FontWeight.w700,
    letterSpacing: 1.80,
  );

  // ── Mono — JetBrains Mono ────────────────────────────────────
  static TextStyle mono = GoogleFonts.jetBrainsMono(
    fontSize: 10, height: 1.20, fontWeight: FontWeight.w500,
    letterSpacing: 1.00,
  );

  // ── Aliases used by lib/screens/** ──────────────────────
  static TextStyle productName = GoogleFonts.fraunces(
    fontSize: 15, height: 1.30, fontWeight: FontWeight.w500,
    letterSpacing: -0.15,
  );
}
