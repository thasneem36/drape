import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_colors.dart';
import 'core/constants/app_text_styles.dart';
import 'core/constants/app_spacing.dart';
import 'core/routes/app_routes.dart';
import 'data/cart_manager.dart';
import 'data/notification_prefs_manager.dart';
import 'data/order_manager.dart';
import 'data/user_profile_manager.dart';
import 'data/wishlist_manager.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/auth_service.dart';

class DrapeApp extends StatelessWidget {
  const DrapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => CartManager()),
        ChangeNotifierProvider(create: (_) => WishlistManager()),
        ChangeNotifierProvider(create: (_) => OrderManager()),
        ChangeNotifierProvider(create: (_) => UserProfileManager()),
        ChangeNotifierProvider(create: (_) => NotificationPrefsManager()),
      ],
      child: MaterialApp(
        title: 'Drape',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        onGenerateRoute: AppRoutes.onGenerate,
        home: const _AuthGate(),
      ),
    );
  }

  ThemeData _buildTheme() {
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
        displayLarge: AppText.displayL,
        displayMedium: AppText.displayM,
        displaySmall: AppText.displayS,
        headlineLarge: AppText.titleXL,
        headlineMedium: AppText.titleL,
        headlineSmall: AppText.titleM,
        titleLarge: AppText.titleS,
        bodyLarge: AppText.bodyL,
        bodyMedium: AppText.bodyM,
        bodySmall: AppText.bodyS,
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
              borderRadius: BorderRadius.circular(AppRadius.base)),
          textStyle: AppText.label.copyWith(color: Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.ink,
          minimumSize: const Size.fromHeight(52),
          side: const BorderSide(color: AppColors.lineStrong),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.base)),
          textStyle: AppText.label,
        ),
      ),
      dividerTheme:
          const DividerThemeData(color: AppColors.line, thickness: 1, space: 1),
      splashFactory: InkSparkle.splashFactory,
      pageTransitionsTheme: const PageTransitionsTheme(builders: {
        TargetPlatform.iOS: _FadeUpBuilder(),
        TargetPlatform.android: _FadeUpBuilder(),
      }),
    );
  }
}

/// Redirects to HomeScreen if a user is signed in, otherwise
/// shows OnboardingScreen.  Handles app cold-start with an existing session.
class _AuthGate extends StatelessWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.data != null) {
          return const HomeScreen();
        }
        return const OnboardingScreen();
      },
    );
  }
}

class _FadeUpBuilder extends PageTransitionsBuilder {
  const _FadeUpBuilder();
  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext ctx,
    Animation<double> a,
    Animation<double> b,
    Widget child,
  ) {
    final curved =
        CurvedAnimation(parent: a, curve: AppMotion.decelerate);
    return FadeTransition(
      opacity: curved,
      child: SlideTransition(
        position:
            Tween(begin: const Offset(0, 0.015), end: Offset.zero)
                .animate(curved),
        child: child,
      ),
    );
  }
}
