import 'package:flutter/material.dart';
import '../../screens/onboarding_screen.dart';
import '../../screens/login_screen.dart';
import '../../screens/home_screen.dart';
import '../../screens/product_list_screen.dart';
import '../../screens/product_detail_screen.dart';
import '../../screens/cart_screen.dart';
import '../../screens/wishlist_screen.dart';
import '../../screens/profile_screen.dart';
import '../../screens/checkout_screen.dart';
import '../../screens/order_history_screen.dart';
import '../../data/models.dart';

class AppRoutes {
  AppRoutes._();

  static const String onboarding    = '/';
  static const String login         = '/login';
  static const String home          = '/home';
  static const String products      = '/products';
  static const String pdp           = '/pdp';
  static const String cart          = '/cart';
  static const String wishlist      = '/wishlist';
  static const String profile       = '/profile';
  static const String checkout      = '/checkout';
  static const String orderHistory  = '/orders';

  static Route<dynamic>? onGenerate(RouteSettings s) {
    switch (s.name) {
      case onboarding:   return _fade(const OnboardingScreen());
      case login:        return _fade(const LoginScreen());
      case home:         return _fade(const HomeScreen());
      case products:     return _fade(const ProductListScreen());
      case pdp:
        final p = s.arguments as Product?;
        return _fade(ProductDetailScreen(product: p ?? _placeholder));
      case cart:         return _fade(const CartScreen());
      case wishlist:     return _fade(const WishlistScreen());
      case profile:      return _fade(const ProfileScreen());
      case checkout:     return _fade(const CheckoutScreen());
      case orderHistory: return _fade(const OrderHistoryScreen());
      default:           return _fade(const HomeScreen());
    }
  }

  static PageRoute<T> _fade<T>(Widget page) => PageRouteBuilder<T>(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, anim, __, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      );

  static final _placeholder = Product(
    id: '', name: 'Product', brand: '', price: 0, cat: '',
    desc: '', sizes: const [], colors: const [],
    rating: 0, reviews: 0, tint: const [0xFF1A1816, 0xFF1A1816],
  );
}
