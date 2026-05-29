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
import '../../screens/search_screen.dart';
import '../../screens/signup_screen.dart';
import '../../screens/addresses_screen.dart';
import '../../screens/payments_screen.dart';
import '../../screens/notifications_screen.dart';
import '../../screens/privacy_screen.dart';
import '../../screens/help_screen.dart';
import '../../screens/order_detail_screen.dart';
import '../../screens/order_confirmation_screen.dart';
import '../../screens/notification_inbox_screen.dart';
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
  static const String search        = '/search';
  static const String signup        = '/signup';
  static const String addresses     = '/addresses';
  static const String payments      = '/payments';
  static const String notifications = '/notifications';
  static const String privacy       = '/privacy';
  static const String help          = '/help';
  static const String orderDetail        = '/order-detail';
  static const String orderConfirmation    = '/order-confirmation';
  static const String notificationInbox   = '/notification-inbox';

  static Route<dynamic>? onGenerate(RouteSettings s) {
    switch (s.name) {
      case onboarding:   return _fade(const OnboardingScreen());
      case login:        return _fade(const LoginScreen());
      case home:         return _fade(const HomeScreen());
      case products:
        final cat = s.arguments as String?;
        return _fade(ProductListScreen(initialCategory: cat));
      case signup:       return _fade(const SignupScreen());
      case pdp:
        final p = s.arguments as Product?;
        return _fade(ProductDetailScreen(product: p ?? _placeholder));
      case cart:         return _fade(const CartScreen());
      case wishlist:     return _fade(const WishlistScreen());
      case profile:      return _fade(const ProfileScreen());
      case checkout:     return _fade(const CheckoutScreen());
      case orderHistory: return _fade(const OrderHistoryScreen());
      case search:       return _fade(const SearchScreen());
      case addresses:     return _fade(const AddressesScreen());
      case payments:      return _fade(const PaymentsScreen());
      case notifications: return _fade(const NotificationsScreen());
      case privacy:       return _fade(const PrivacyScreen());
      case help:          return _fade(const HelpScreen());
      case orderDetail:
        final o = s.arguments as Order?;
        if (o == null) return _fade(const HomeScreen());
        return _fade(OrderDetailScreen(order: o));
      case orderConfirmation:
        final a = s.arguments as OrderConfirmationArgs?;
        if (a == null) return _fade(const HomeScreen());
        return _fade(OrderConfirmationScreen(args: a));
      case notificationInbox:
        return _fade(const NotificationInboxScreen());
      default:            return _fade(const HomeScreen());
    }
  }

  static PageRoute<T> _fade<T>(Widget page) => PageRouteBuilder<T>(
        pageBuilder: (_, _, _) => page,
        transitionsBuilder: (_, anim, _, child) => FadeTransition(opacity: anim, child: child),
        transitionDuration: const Duration(milliseconds: 220),
      );

  static final _placeholder = Product(
    id: '', name: 'Product', brand: '', price: 0, cat: '',
    desc: '', sizes: const [], colors: const [],
    rating: 0, reviews: 0, tint: const [0xFF1A1816, 0xFF1A1816],
  );
}
