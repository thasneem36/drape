// ─────────────────────────────────────────────────────────────
// Home — editorial header, hero carousel, categories,
// featured row, campaign strip, staggered new-arrivals grid.
// All product data streams from Firestore.
// ─────────────────────────────────────────────────────────────

import 'dart:async';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/cart_manager.dart';
import '../data/notification_prefs_manager.dart';
import '../data/models.dart';
import '../services/firestore_service.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_content.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/routes/app_routes.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/category_chip.dart';
import '../shared/widgets/product_card.dart';
import '../shared/widgets/drape_scaffold.dart';

// UI-only navigation categories — not stored in Firestore.
const _navCategories = [
  (id: 'all', name: 'All'),
  (id: 'women', name: 'Women'),
  (id: 'men', name: 'Men'),
  (id: 'kids', name: 'Kids'),
  (id: 'access', name: 'Accessories'),
  (id: 'sale', name: 'Sale'),
];

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int cat = 0;
  int offer = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(milliseconds: 4500), (_) {
      if (!mounted) return;
      setState(() => offer = (offer + 1) % kHeroBanners.length);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _showStory(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _StorySheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartManager>();
    final user = FirebaseAuth.instance.currentUser;
    final firstName = user?.displayName?.split(' ').first ?? 'there';

    return DrapeScaffold(
      tab: TabItem.home,
      body: StreamBuilder<List<Product>>(
        stream: FirestoreService.instance.getProducts(),
        builder: (context, snap) {
          final allProducts = snap.data ?? [];
          final featured =
              allProducts.where((p) => p.isNew || p.isSale).toList();
          final newArrivals = allProducts.where((p) => p.isNew).take(4).toList();

          void openPdp(Product p) =>
              Navigator.pushNamed(context, AppRoutes.pdp, arguments: p);

          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                  child: _header(context, cart.itemCount, firstName)),
              SliverToBoxAdapter(child: _searchBar(context)),
              SliverToBoxAdapter(child: _heroCard()),
              SliverToBoxAdapter(child: _categories()),
              if (featured.isNotEmpty)
                SliverToBoxAdapter(
                    child: _featuredRow(featured, openPdp)),
              SliverToBoxAdapter(child: _campaign()),
              if (newArrivals.isNotEmpty)
                SliverToBoxAdapter(
                    child: _newArrivals(newArrivals, openPdp)),
              const SliverToBoxAdapter(child: _Quote()),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          );
        },
      ),
    );
  }

  Widget _header(BuildContext ctx, int cartCount, String firstName) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('WELCOME BACK', style: AppText.eyebrow),
                const SizedBox(height: 2),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Hello, '),
                      TextSpan(
                        text: firstName,
                        style: AppText.titleL
                            .copyWith(fontStyle: FontStyle.italic),
                      ),
                    ],
                    style: AppText.titleL,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: () =>
                Navigator.pushNamed(ctx, AppRoutes.notificationInbox),
            child: Consumer<NotificationPrefsManager>(
              builder: (context, mgr, child) {
                final allOff = mgr.allDisabled;
                return Container(
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
                  child: Icon(
                    allOff
                        ? Icons.notifications_off_outlined
                        : Icons.notifications_none_rounded,
                    size: 20,
                    color: allOff ? AppColors.muted : AppColors.ink,
                  ),
                );
              },
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: () => Navigator.pushNamed(ctx, AppRoutes.cart),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
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
                  child: const Icon(Icons.shopping_bag_outlined,
                      size: 20, color: AppColors.ink),
                ),
                if (cartCount > 0)
                  Positioned(
                    top: -2,
                    right: -2,
                    child: Container(
                      constraints:
                          const BoxConstraints(minWidth: 18, minHeight: 18),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 5, vertical: 1),
                      decoration: BoxDecoration(
                        color: AppColors.accent,
                        borderRadius:
                            BorderRadius.circular(AppRadius.pill),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      alignment: Alignment.center,
                      child: Text('$cartCount',
                          style: AppText.micro
                              .copyWith(color: Colors.white, fontSize: 9)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBar(BuildContext context) => GestureDetector(
        onTap: () => Navigator.pushNamed(context, AppRoutes.search),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.base),
              border: Border.all(color: AppColors.line),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 17, color: AppColors.muted),
                const SizedBox(width: 10),
                Text(
                  'Search curated collections…',
                  style: AppText.bodyS.copyWith(color: AppColors.muted),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.line),
                    borderRadius: BorderRadius.circular(AppRadius.xs),
                  ),
                  child: Text('⌘K', style: AppText.mono),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _heroCard() {
    final o = kHeroBanners[offer];
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 600),
        height: 200,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: o.bg,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppRadius.xl),
          boxShadow: AppShadows.md,
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // ── Photo on the right (with left-fade so text stays readable) ──
              if (o.imageUrl.isNotEmpty)
                Positioned(
                  top: 0, right: 0, bottom: 0,
                  width: 160,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CachedNetworkImage(
                        imageUrl: o.imageUrl,
                        fit: BoxFit.cover,
                        placeholder: (_, _) => const SizedBox.shrink(),
                        errorWidget: (_, _, _) => const SizedBox.shrink(),
                      ),
                      // Gradient fade: left edge blends into card background
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: [
                              o.bg.first,
                              o.bg.first.withValues(alpha: 0.0),
                            ],
                            stops: const [0.0, 0.45],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // ── Decorative rings (only show when there is no image) ──
              if (o.imageUrl.isEmpty) ...[
                Positioned(top: -40, right: -40, child: _Ring(140, o.accent, 0.25)),
                Positioned(top: 30, right: 60, child: _Ring(80, o.accent, 0.18)),
              ],

              // ── Text + buttons ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      o.eyebrow.toUpperCase(),
                      style: AppText.eyebrow.copyWith(color: o.accent),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      o.title,
                      style: AppText.titleXL.copyWith(
                        color: Colors.white,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      o.sub,
                      style: AppText.bodyS.copyWith(color: Colors.white70),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Material(
                          color: Colors.white,
                          shape: const StadiumBorder(),
                          child: InkWell(
                            customBorder: const StadiumBorder(),
                            onTap: () => Navigator.pushNamed(
                                context, AppRoutes.products),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 18, vertical: 10),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text('EXPLORE',
                                      style: AppText.label
                                          .copyWith(color: AppColors.ink)),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.arrow_forward,
                                      size: 13, color: AppColors.ink),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: List.generate(kHeroBanners.length, (i) {
                            return AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.only(left: 6),
                              height: 6,
                              width: i == offer ? 22 : 6,
                              decoration: BoxDecoration(
                                color: i == offer
                                    ? Colors.white
                                    : Colors.white38,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categories() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 24, 18, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SHOP BY CATEGORY', style: AppText.eyebrow),
            const SizedBox(height: 12),
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _navCategories.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (_, i) => PillChip(
                  label: _navCategories[i].name,
                  selected: i == cat,
                  dense: true,
                  onTap: () {
                    setState(() => cat = i);
                    Navigator.pushNamed(
                      context,
                      AppRoutes.products,
                      arguments: _navCategories[i].name,
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      );

  Widget _featuredRow(
      List<Product> featured, void Function(Product) onTap) {
    return Padding(
      padding: const EdgeInsets.only(top: 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('THIS WEEK', style: AppText.eyebrow),
                      const SizedBox(height: 2),
                      Text('Featured Edit',
                          style: AppText.titleL
                              .copyWith(fontStyle: FontStyle.italic)),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.pushNamed(context, AppRoutes.products),
                  child: Text('VIEW ALL',
                      style: AppText.label.copyWith(
                        color: AppColors.accentInk,
                        decoration: TextDecoration.underline,
                      )),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 360,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 18),
              itemCount: featured.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: 14),
              itemBuilder: (_, i) => SizedBox(
                width: 220,
                child: ProductCard(
                  product: featured[i],
                  onTap: () => onTap(featured[i]),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _campaign() => Padding(
        padding: const EdgeInsets.fromLTRB(18, 28, 18, 0),
        child: Container(
          height: 200,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF1A1816), Color(0xFF2C251F)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppRadius.xl),
            boxShadow: AppShadows.md,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xl),
            child: Stack(
              fit: StackFit.expand,
              children: [
                // ── Photo on the right ──────────────────────────────────
                if (kCampaignImageUrl.isNotEmpty)
                  Positioned(
                    top: 0, right: 0, bottom: 0,
                    width: 160,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: kCampaignImageUrl,
                          fit: BoxFit.cover,
                          placeholder: (_, _) => const SizedBox.shrink(),
                          errorWidget: (_, _, _) => const SizedBox.shrink(),
                        ),
                        // Fade left edge into card background
                        const DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              colors: [Color(0xFF1A1816), Colors.transparent],
                              stops: [0.0, 0.45],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // ── Decorative rings (only when no image) ──────────────
                if (kCampaignImageUrl.isEmpty) ...[
                  Positioned(
                      top: 0, right: -40,
                      child: _Ring(220, AppColors.accent, 0.25)),
                  Positioned(
                      top: 30, right: 10,
                      child: _Ring(140, AppColors.accent, 0.18)),
                ],

                // ── Text + button ───────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.all(28),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('THE QUIET EDIT',
                          style: AppText.eyebrow
                              .copyWith(color: AppColors.accentSoft)),
                      const SizedBox(height: 6),
                      SizedBox(
                        width: 210,
                        child: Text(
                          'Made slowly. Worn for years.',
                          style: AppText.titleXL.copyWith(
                            color: Colors.white,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      GestureDetector(
                        onTap: () => _showStory(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 9),
                          decoration: BoxDecoration(
                            border: Border.all(
                                color: Colors.white.withValues(alpha: 0.4)),
                            borderRadius:
                                BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Text('READ THE STORY →',
                              style: AppText.label
                                  .copyWith(color: Colors.white)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _newArrivals(
      List<Product> items, void Function(Product) onTap) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('JUST IN', style: AppText.eyebrow),
          const SizedBox(height: 2),
          Text('New Arrivals',
              style:
                  AppText.titleL.copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: 16),
          GridView.builder(
            physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: items.length,
            gridDelegate:
                const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 20,
              childAspectRatio: 0.62,
            ),
            itemBuilder: (_, i) {
              final p = items[i];
              return Padding(
                padding: EdgeInsets.only(top: i % 2 == 1 ? 24 : 0),
                child: ProductCard(
                  product: p,
                  onTap: () => onTap(p),
                  compact: true,
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Ring extends StatelessWidget {
  final double size;
  final Color color;
  final double alpha;
  const _Ring(this.size, this.color, this.alpha);
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
              color: color.withValues(alpha: alpha), width: 1.5),
        ),
      );
}

class _Quote extends StatelessWidget {
  const _Quote();
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 44, 18, 10),
        child: Column(
          children: [
            Text(
              '"Drape is the quiet confidence\nof made-to-last things."',
              textAlign: TextAlign.center,
              style: AppText.titleM.copyWith(
                color: AppColors.muted,
                fontStyle: FontStyle.italic,
                height: 1.4,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 12),
            Text('— THE STUDIO', style: AppText.eyebrow),
          ],
        ),
      );
}

// ── The Quiet Edit — editorial story sheet ────────────────────

class _StorySheet extends StatelessWidget {
  const _StorySheet();

  static const _paragraphs = [
    'There is a particular kind of clothing that asks nothing of you. '
        'It does not demand attention or announce itself. It simply fits — '
        'into your day, your life, your sense of who you are.',
    'The Quiet Edit is our answer to a wardrobe that lasts. Not a '
        'capsule, not a trend. A considered selection of pieces made '
        'slowly, from materials chosen for how they age: linen that '
        'softens with every wash, cashmere that holds its shape across '
        'seasons, wool that weathers years without apology.',
    'We work with a small number of independent makers. Each piece is '
        'produced in limited runs. When it is gone, it is gone — because '
        'quality has never been about volume.',
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1A1816),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 8, 28, 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36, height: 4,
              margin: const EdgeInsets.only(bottom: 28),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          Text('THE QUIET EDIT',
              style: AppText.eyebrow
                  .copyWith(color: AppColors.accentSoft, letterSpacing: 2)),
          const SizedBox(height: 10),
          Text('Made slowly.\nWorn for years.',
              style: AppText.titleXL.copyWith(
                  color: Colors.white, fontStyle: FontStyle.italic)),
          const SizedBox(height: 28),

          ..._paragraphs.map((p) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(p,
                    style: AppText.bodyS.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
                        height: 1.75)),
              )),

          const SizedBox(height: 8),
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
              Navigator.pushNamed(context, AppRoutes.products);
            },
            child: Container(
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(AppRadius.base),
              ),
              alignment: Alignment.center,
              child: Text('SHOP THE EDIT',
                  style: AppText.label
                      .copyWith(color: AppColors.ink)),
            ),
          ),
        ],
      ),
    );
  }
}
