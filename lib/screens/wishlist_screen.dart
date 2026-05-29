import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../data/wishlist_manager.dart';
import '../services/firestore_service.dart';
import '../core/constants/app_text_styles.dart';
import '../core/routes/app_routes.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/product_card.dart';
import '../shared/widgets/drape_scaffold.dart';
import 'empty_state.dart';

class WishlistScreen extends StatelessWidget {
  const WishlistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final wl = context.watch<WishlistManager>();

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
                    style: AppText.titleL
                        .copyWith(fontStyle: FontStyle.italic)),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Product>>(
              stream: FirestoreService.instance.getProducts(),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting &&
                    !snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final saved = (snap.data ?? [])
                    .where((p) => wl.contains(p.id))
                    .toList();

                if (saved.isEmpty) {
                  return const EmptyState(
                    icon: Icons.favorite_border,
                    title: 'Nothing saved yet.',
                    sub: 'Tap the heart on any piece you love.',
                    cta: 'Browse the shop',
                    route: AppRoutes.products,
                  );
                }

                return GridView.builder(
                  padding:
                      const EdgeInsets.fromLTRB(16, 8, 16, 100),
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
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
