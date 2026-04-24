// ─────────────────────────────────────────────────────────────
// Bottom nav tab bar — floating cream pill style.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/cart_manager.dart';
import '../data/wishlist_manager.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../core/routes.dart';

enum TabItem { home, shop, wishlist, cart, profile }

class DrapeBottomNav extends StatelessWidget {
  final TabItem current;
  const DrapeBottomNav({super.key, required this.current});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartManager>();
    final wl = context.watch<WishlistManager>();

    final items = [
      (TabItem.home,     Icons.home_outlined,         'HOME',  AppRoutes.home),
      (TabItem.shop,     Icons.grid_view_outlined,    'SHOP',  AppRoutes.products),
      (TabItem.cart,     Icons.shopping_bag_outlined, 'BAG',   AppRoutes.cart),
      (TabItem.wishlist, Icons.favorite_border,       'SAVED', AppRoutes.wishlist),
      (TabItem.profile,  Icons.person_outline,        'YOU',   AppRoutes.profile),
    ];

    return SafeArea(
      bottom: true,
      child: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 12),
        child: Container(
          height: 64,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFEBE2D9),
            borderRadius: BorderRadius.circular(32),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: items.map((t) {
              final active = t.$1 == current;
              String? badge;
              if (t.$1 == TabItem.cart && cart.itemCount > 0) badge = '${cart.itemCount}';
              if (t.$1 == TabItem.wishlist && wl.count > 0) badge = '${wl.count}';

              return Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () {
                    if (active) return;
                    Navigator.of(context).pushReplacementNamed(t.$4);
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        width: 28, height: 26,
                        child: Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.center,
                          children: [
                            Icon(
                              t.$2,
                              size: 24,
                              color: active ? AppColors.ink : AppColors.ink.withOpacity(0.5),
                            ),
                            if (badge != null)
                              Positioned(
                                top: -4, right: -6,
                                child: Container(
                                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.inkSoft,
                                    borderRadius: BorderRadius.circular(AppRadius.pill),
                                    border: Border.all(color: const Color(0xFFEBE2D9), width: 1.5),
                                  ),
                                  alignment: Alignment.center,
                                  child: Text(badge,
                                      style: AppText.micro.copyWith(
                                        color: Colors.white,
                                        fontSize: 9,
                                        fontWeight: FontWeight.bold,
                                      )),
                                ),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(t.$3,
                          style: AppText.micro.copyWith(
                            color: active ? AppColors.ink : AppColors.ink.withOpacity(0.5),
                            fontSize: 9,
                            fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                            letterSpacing: 0.5,
                          )),
                      if (active)
                        Container(
                          margin: const EdgeInsets.only(top: 2),
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: AppColors.accent,
                            shape: BoxShape.circle,
                          ),
                        )
                      else
                        const SizedBox(height: 6),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
