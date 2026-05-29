// ─────────────────────────────────────────────────────────────
// Product List — staggered grid. Products stream from Firestore.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../data/models.dart';
import '../services/firestore_service.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/routes/app_routes.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/category_chip.dart';
import '../shared/widgets/product_card.dart';
import '../shared/widgets/drape_scaffold.dart';

// ── Sort options ──────────────────────────────────────────────

enum _SortBy { featured, priceAsc, priceDesc, rating, newest }

extension _SortByLabel on _SortBy {
  String get label => switch (this) {
        _SortBy.featured  => 'Featured',
        _SortBy.priceAsc  => 'Price: Low to High',
        _SortBy.priceDesc => 'Price: High to Low',
        _SortBy.rating    => 'Top Rated',
        _SortBy.newest    => 'New Arrivals First',
      };
}

// ── Screen ────────────────────────────────────────────────────

class ProductListScreen extends StatefulWidget {
  final String? initialCategory;
  const ProductListScreen({super.key, this.initialCategory});
  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  // Material chip index (0 = All, 1–4 = specific material)
  int _materialIdx = 0;
  static const _materials = ['All', 'Silk', 'Cashmere', 'Linen', 'Wool'];

  // Category comes only from route arg — chips don't override it
  String _category = 'All';

  _SortBy _sort = _SortBy.featured;

  @override
  void initState() {
    super.initState();
    final cat = widget.initialCategory;
    if (cat != null && cat != 'All') _category = cat;
  }

  List<Product> _applyFilters(List<Product> all) {
    var pool = List<Product>.from(all);

    // 1. Category filter (from route arg)
    if (_category != 'All') {
      if (_category == 'Sale') {
        pool = pool.where((p) => p.isSale).toList();
      } else {
        pool = pool
            .where((p) => p.cat.toLowerCase() == _category.toLowerCase())
            .toList();
      }
    }

    // 2. Material chip filter (text search in name + desc)
    if (_materialIdx > 0) {
      final kw = _materials[_materialIdx].toLowerCase();
      pool = pool
          .where((p) =>
              p.name.toLowerCase().contains(kw) ||
              p.desc.toLowerCase().contains(kw))
          .toList();
    }

    // 3. Sort
    switch (_sort) {
      case _SortBy.featured:
        break; // keep Firestore order
      case _SortBy.priceAsc:
        pool.sort((a, b) => a.price.compareTo(b.price));
      case _SortBy.priceDesc:
        pool.sort((a, b) => b.price.compareTo(a.price));
      case _SortBy.rating:
        pool.sort((a, b) => b.rating.compareTo(a.rating));
      case _SortBy.newest:
        // New arrivals first, then rest in original order
        final newOnes = pool.where((p) => p.isNew).toList();
        final rest    = pool.where((p) => !p.isNew).toList();
        pool = [...newOnes, ...rest];
    }

    return pool;
  }

  Future<void> _showSortSheet() async {
    final picked = await showModalBottomSheet<_SortBy>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _SortSheet(current: _sort),
    );
    if (picked != null && mounted) setState(() => _sort = picked);
  }

  @override
  Widget build(BuildContext context) {
    void openPdp(Product p) =>
        Navigator.pushNamed(context, AppRoutes.pdp, arguments: p);

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
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: const Icon(Icons.arrow_back,
                        size: 20, color: AppColors.ink),
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.cart),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Color(0x14000000),
                            blurRadius: 8,
                            offset: Offset(0, 2))
                      ],
                    ),
                    child: const Icon(Icons.shopping_bag_outlined,
                        size: 20, color: AppColors.ink),
                  ),
                ),
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
                final products = _applyFilters(snap.data ?? []);

                return CustomScrollView(
                  slivers: [
                    SliverToBoxAdapter(child: _title()),
                    SliverToBoxAdapter(child: _filterChips()),
                    SliverToBoxAdapter(
                        child: _countRow(products.length)),
                    if (products.isEmpty)
                      SliverFillRemaining(
                        hasScrollBody: false,
                        child: Center(
                          child: Text(
                            'No products found',
                            style: AppText.bodyS
                                .copyWith(color: AppColors.textSecondary),
                          ),
                        ),
                      )
                    else
                      SliverPadding(
                        padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
                        sliver: SliverGrid(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 14,
                            mainAxisSpacing: 20,
                            childAspectRatio: 0.58,
                          ),
                          delegate: SliverChildBuilderDelegate(
                            (ctx, i) {
                              final p = products[i];
                              return Padding(
                                padding: EdgeInsets.only(
                                    top: i % 2 == 1 ? 24 : 0),
                                child: ProductCard(
                                    product: p,
                                    onTap: () => openPdp(p),
                                    compact: true),
                              );
                            },
                            childCount: products.length,
                          ),
                        ),
                      ),
                  ],
                );
              },
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
                  Text('SPRING COLLECTION 2026',
                      style: AppText.eyebrow),
                  const SizedBox(height: 4),
                  Text('The Shop',
                      style: AppText.displayM
                          .copyWith(fontStyle: FontStyle.italic)),
                ],
              ),
            ),
            Container(
              width: 44,
              height: 44,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Color(0x14000000),
                      blurRadius: 8,
                      offset: Offset(0, 2))
                ],
              ),
              child: const Icon(Icons.tune_rounded,
                  size: 20, color: AppColors.ink),
            ),
          ],
        ),
      );

  Widget _filterChips() => SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: _materials.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) => PillChip(
            label: _materials[i],
            selected: i == _materialIdx,
            dense: true,
            onTap: () => setState(() => _materialIdx = i),
          ),
        ),
      );

  Widget _countRow(int n) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 10),
        child: Row(
          children: [
            Text('$n ${n == 1 ? 'piece' : 'pieces'}',
                style: AppText.bodyS.copyWith(color: AppColors.muted)),
            const Spacer(),
            GestureDetector(
              onTap: _showSortSheet,
              child: Row(children: [
                Text('Sort · ${_sort.label}',
                    style: AppText.caption
                        .copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(width: 4),
                const Icon(Icons.keyboard_arrow_down,
                    size: 14, color: AppColors.ink),
              ]),
            ),
          ],
        ),
      );
}

// ── Sort bottom sheet ─────────────────────────────────────────

class _SortSheet extends StatelessWidget {
  final _SortBy current;
  const _SortSheet({required this.current});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Sort by',
              style: AppText.titleS
                  .copyWith(fontWeight: FontWeight.w600, fontSize: 17)),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.line),
            ),
            child: Column(
              children: List.generate(_SortBy.values.length, (i) {
                final opt = _SortBy.values[i];
                final isLast = i == _SortBy.values.length - 1;
                final selected = opt == current;
                return Column(children: [
                  InkWell(
                    onTap: () => Navigator.pop(context, opt),
                    borderRadius: BorderRadius.vertical(
                      top: i == 0 ? const Radius.circular(AppRadius.lg) : Radius.zero,
                      bottom: isLast ? const Radius.circular(AppRadius.lg) : Radius.zero,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 15),
                      child: Row(children: [
                        Expanded(
                          child: Text(opt.label,
                              style: AppText.bodyS.copyWith(
                                fontWeight: selected
                                    ? FontWeight.w700
                                    : FontWeight.w400,
                                color: selected
                                    ? AppColors.ink
                                    : AppColors.textSecondary,
                              )),
                        ),
                        if (selected)
                          const Icon(Icons.check,
                              size: 16, color: AppColors.ink),
                      ]),
                    ),
                  ),
                  if (!isLast)
                    const Divider(height: 1, color: AppColors.line),
                ]);
              }),
            ),
          ),
        ],
      ),
    );
  }
}
