// ─────────────────────────────────────────────────────────────
// Wishlist screen — saved items grid.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/dummy_data.dart';
import '../data/wishlist_manager.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/bottom_nav.dart';
import '../widgets/product_card.dart';
import '../widgets/scaffold.dart';
import '../core/routes.dart';
import 'empty_state.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wl = context.watch<WishlistManager>();
    final allIds = DummyData.products.map((p) => p.id).toSet();
    final saved = wl.ids
        .where((id) => allIds.contains(id))
        .map((id) => DummyData.byId(id))
        .toList();

    return DrapeScaffold(
      tab: TabItem.wishlist,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 14, 18, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('SAVED', style: AppText.eyebrow),
                const SizedBox(height: 2),
                Text('Your Wishlist',
                    style: AppText.titleL.copyWith(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Expanded(
            child: saved.isEmpty
                ? const EmptyState(
                    icon: Icons.favorite_border,
                    title: 'Nothing saved yet.',
                    sub: 'Tap the heart on any piece you love.',
                    cta: 'Browse the shop',
                    route: AppRoutes.products,
                  )
                : GridView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                    itemCount: saved.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.62,
                    ),
                    itemBuilder: (_, i) {
                      final p = saved[i];
                      return ProductCard(
                        product: p,
                        compact: true,
                        onTap: () => Navigator.pushNamed(
                            context, AppRoutes.pdp,
                            arguments: p),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
