// ─────────────────────────────────────────────────────────────
// Product List — staggered grid of all products.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../data/dummy_data.dart';
import '../data/models.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/routes/app_routes.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/primary_button.dart';
import '../shared/widgets/category_chip.dart';
import '../shared/widgets/product_card.dart';
import '../shared/widgets/drape_scaffold.dart';

class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  int filter = 0;
  final filters = const ['All Items', 'Silk', 'Cashmere', 'Linen', 'Wool'];

  @override
  Widget build(BuildContext context) {
    final products = DummyData.products;
    void openPdp(Product p) => Navigator.pushNamed(context, AppRoutes.pdp, arguments: p);

    return DrapeScaffold(
      tab: TabItem.shop,
      body: Column(
        children: [
          // App bar row
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 10, 18, 6),
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => Navigator.maybePop(context),
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: const Icon(Icons.arrow_back, size: 20, color: AppColors.ink),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, AppRoutes.cart),
                  child: Container(
                    width: 44, height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
                    ),
                    child: const Icon(Icons.shopping_bag_outlined, size: 20, color: AppColors.ink),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: _title()),
                SliverToBoxAdapter(child: _filterChips()),
                SliverToBoxAdapter(child: _countRow(products.length)),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 30),
                  sliver: SliverGrid(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 20,
                      childAspectRatio: 0.58,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (ctx, i) {
                        final p = products[i];
                        return Padding(
                          padding: EdgeInsets.only(top: i % 2 == 1 ? 24 : 0),
                          child: ProductCard(product: p, onTap: () => openPdp(p), compact: true),
                        );
                      },
                      childCount: products.length,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _title() => Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('SPRING COLLECTION 2026', style: AppText.eyebrow),
                  const SizedBox(height: 4),
                  Text('The Shop',
                      style: AppText.displayM.copyWith(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            Container(
              width: 44, height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
              ),
              child: const Icon(Icons.tune_rounded, size: 20, color: AppColors.ink),
            ),
          ],
        ),
      );

  Widget _filterChips() => SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: filters.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (_, i) => PillChip(
            label: filters[i],
            selected: i == filter,
            dense: true,
            onTap: () => setState(() => filter = i),
          ),
        ),
      );

  Widget _countRow(int n) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
        child: Row(
          children: [
            Text('$n pieces', style: AppText.bodyS.copyWith(color: AppColors.muted)),
            const Spacer(),
            Row(children: [
              Text('Sort · Featured', style: AppText.caption),
              const SizedBox(width: 4),
              const Icon(Icons.keyboard_arrow_down, size: 14, color: AppColors.ink),
            ]),
          ],
        ),
      );
}
