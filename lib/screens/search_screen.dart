import 'package:flutter/material.dart';
import '../data/models.dart';
import '../services/firestore_service.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/routes/app_routes.dart';
import '../shared/widgets/product_card.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final _ctrl = TextEditingController();
  final _focus = FocusNode();
  String _query = '';
  String _activeCategory = 'All';

  static const _categories = [
    'All', 'Women', 'Men', 'Kids', 'Accessories', 'Sale'
  ];

  List<Product> _applyFilters(List<Product> pool) {
    var results = pool;
    if (_activeCategory != 'All') {
      if (_activeCategory == 'Sale') {
        results = results.where((p) => p.isSale).toList();
      } else {
        results = results
            .where((p) => p.cat == _activeCategory)
            .toList();
      }
    }
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) return results;
    return results
        .where((p) =>
            p.name.toLowerCase().contains(q) ||
            p.brand.toLowerCase().contains(q) ||
            p.cat.toLowerCase().contains(q) ||
            p.desc.toLowerCase().contains(q))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _focus.requestFocus());
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEmpty =
        _query.trim().isEmpty && _activeCategory == 'All';

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _searchBar(context),
            _categoryChips(),
            Expanded(
              child: isEmpty
                  ? _emptyIdle()
                  : StreamBuilder<List<Product>>(
                      stream:
                          FirestoreService.instance.getProducts(),
                      builder: (context, snap) {
                        if (snap.connectionState ==
                                ConnectionState.waiting &&
                            !snap.hasData) {
                          return const Center(
                              child:
                                  CircularProgressIndicator());
                        }
                        final results =
                            _applyFilters(snap.data ?? []);
                        if (results.isEmpty) {
                          return _emptyNoResults();
                        }
                        return _grid(results);
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchBar(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 18, 8),
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
            const SizedBox(width: 12),
            Expanded(
              child: Container(
                height: 48,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppRadius.base),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.search,
                        size: 18, color: AppColors.muted),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: _ctrl,
                        focusNode: _focus,
                        style: AppText.bodyS,
                        decoration: InputDecoration(
                          hintText: 'Search styles, brands…',
                          hintStyle: AppText.bodyS
                              .copyWith(color: AppColors.muted),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (v) =>
                            setState(() => _query = v),
                        textInputAction: TextInputAction.search,
                      ),
                    ),
                    if (_query.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _ctrl.clear();
                          setState(() => _query = '');
                        },
                        child: const Icon(Icons.close,
                            size: 16, color: AppColors.muted),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      );

  Widget _categoryChips() => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 18),
          itemCount: _categories.length,
          separatorBuilder: (_, _) => const SizedBox(width: 8),
          itemBuilder: (_, i) {
            final cat = _categories[i];
            final active = cat == _activeCategory;
            return GestureDetector(
              onTap: () =>
                  setState(() => _activeCategory = cat),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                    horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: active ? AppColors.ink : AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppRadius.pill),
                  border: Border.all(
                      color:
                          active ? AppColors.ink : AppColors.line),
                ),
                child: Text(
                  cat,
                  style: AppText.caption.copyWith(
                    color: active
                        ? Colors.white
                        : AppColors.textSecondary,
                    fontWeight: active
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ),
            );
          },
        ),
      );

  Widget _grid(List<Product> products) => GridView.builder(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 40),
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 14,
          mainAxisSpacing: 20,
          childAspectRatio: 0.58,
        ),
        itemCount: products.length,
        itemBuilder: (ctx, i) {
          final p = products[i];
          return Padding(
            padding: EdgeInsets.only(top: i % 2 == 1 ? 24 : 0),
            child: ProductCard(
              product: p,
              compact: true,
              onTap: () => Navigator.pushNamed(ctx, AppRoutes.pdp,
                  arguments: p),
            ),
          );
        },
      );

  Widget _emptyIdle() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(Icons.search,
                    size: 28, color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              Text('Discover your style',
                  style: AppText.titleM
                      .copyWith(fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              Text(
                'Search by name, brand, or category',
                style: AppText.bodyS
                    .copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );

  Widget _emptyNoResults() => Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.line),
                ),
                child: const Icon(Icons.search_off,
                    size: 28, color: AppColors.muted),
              ),
              const SizedBox(height: 20),
              Text('No results for "$_query"',
                  style: AppText.titleM
                      .copyWith(fontStyle: FontStyle.italic)),
              const SizedBox(height: 8),
              Text(
                'Try a different keyword or browse categories',
                style: AppText.bodyS
                    .copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
}
