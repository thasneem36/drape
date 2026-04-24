// ─────────────────────────────────────────────────────────────
// Drape — Redesigned (Flutter port)
// Entry point. Wires theme, providers, and routes.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'theme/drape_theme.dart';
import 'data/cart_manager.dart';
import 'data/wishlist_manager.dart';
import 'core/routes.dart';
import 'screens/onboarding_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const DrapeApp());
}

class DrapeApp extends StatelessWidget {
  const DrapeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartManager()..seed()),
        ChangeNotifierProvider(create: (_) => WishlistManager()..seed()),
      ],
      child: MaterialApp(
        title: 'Drape',
        debugShowCheckedModeBanner: false,
        theme: DrapeTheme.light(),
        onGenerateRoute: AppRoutes.onGenerate,
        home: const OnboardingScreen(),
      ),
    );
  }
}
