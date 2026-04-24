// ─────────────────────────────────────────────────────────────
// ThemeData — composes tokens + typography into a Material 3 theme.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'tokens.dart';
import 'typography.dart';

class DrapeTheme {
  DrapeTheme._();

  static ThemeData light() {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      scaffoldBackgroundColor: AppColors.bg,
      colorScheme: const ColorScheme.light(
        primary: AppColors.ink,
        onPrimary: Colors.white,
        secondary: AppColors.accent,
        onSecondary: Colors.white,
        tertiary: AppColors.blush,
        onTertiary: AppColors.ink,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
        surfaceContainerLowest: AppColors.surface,
        surfaceContainerLow: AppColors.surface2,
        surfaceContainer: AppColors.surface3,
        outline: AppColors.lineStrong,
        outlineVariant: AppColors.line,
        error: AppColors.error,
      ),
      textTheme: TextTheme(
        displayLarge:  AppText.displayL,
        displayMedium: AppText.displayM,
        displaySmall:  AppText.displayS,
        headlineLarge: AppText.titleXL,
        headlineMedium: AppText.titleL,
        headlineSmall: AppText.titleM,
        titleLarge: AppText.titleS,
        bodyLarge:  AppText.bodyL,
        bodyMedium: AppText.bodyM,
        bodySmall:  AppText.bodyS,
        labelLarge: AppText.label,
        labelMedium: AppText.caption,
        labelSmall: AppText.micro,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: AppText.titleS,
        iconTheme: const IconThemeData(color: AppColors.ink, size: 20),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.ink,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.base),
          ),
          textStyle: AppText.label.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.lineStrong),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.base),
          ),
          textStyle: AppText.label,
        ),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.iOS:     _FadeUpPageTransitionsBuilder(),
        TargetPlatform.android: _FadeUpPageTransitionsBuilder(),
      }),
    );
  }
}

/// Subtle fade+rise transition to match the prototype's page change feel.
class _FadeUpPageTransitionsBuilder extends PageTransitionsBuilder {
  const _FadeUpPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(PageRoute<T> route, BuildContext ctx,
      Animation<double> a, Animation<double> b, Widget child) {
    final curved = CurvedAnimation(parent: a, curve: AppMotion.decelerate);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position: Tween(begin: const Offset(0, 0.015), end: Offset.zero).animate(curved),
        child: child,
      ),
    );
  }
}
