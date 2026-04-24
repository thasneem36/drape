// ─────────────────────────────────────────────────────────────
// Product Detail — hero + pinned sheet with size/color/actions.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart' hide ColorSwatch;
import 'package:provider/provider.dart';
import '../data/cart_manager.dart';
import '../data/models.dart';
import '../data/wishlist_manager.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';
import '../widgets/buttons.dart';
import '../widgets/chips.dart';
import '../widgets/product_art.dart';
import '../core/routes.dart';

class ProductDetailScreen extends StatefulWidget {
  final Product product;
  const ProductDetailScreen({super.key, required this.product});
  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int sizeIdx = 1;
  int colorIdx = 0;
  int qty = 1;
  bool descOpen = true;
  bool careOpen = false;
  bool showToast = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.product;
    final wl = context.watch<WishlistManager>();
    final saved = wl.contains(p.id);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Stack(
        children: [
          // Hero
          Positioned(
            top: 0, left: 0, right: 0, height: 430,
            child: ProductArt(
              product: p,
              borderRadius: BorderRadius.zero,
              fontSize: 32,
            ),
          ),
          // AppBar overlay
          Positioned(
            top: 0, left: 0, right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.maybePop(context),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
                        ),
                        child: const Icon(Icons.arrow_back, size: 20, color: AppColors.ink),
                      ),
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.read<WishlistManager>().toggle(p.id),
                      child: Container(
                        width: 44, height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.85),
                          shape: BoxShape.circle,
                          boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
                        ),
                        child: Icon(
                          saved ? Icons.favorite : Icons.favorite_border,
                          size: 20,
                          color: saved ? AppColors.accent : AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Detail sheet
          Positioned.fill(
            top: 380,
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.sheet)),
                boxShadow: AppShadows.sheet,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(22, 14, 22, 160),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44, height: 4,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Text(p.brand.toUpperCase(),
                        style: AppText.eyebrow.copyWith(letterSpacing: 2.4)),
                    const SizedBox(height: 6),
                    Text(p.name,
                        style: AppText.titleXL.copyWith(fontStyle: FontStyle.italic)),
                    const SizedBox(height: 14),
                    Row(children: [
                      _stars(p.rating),
                      const SizedBox(width: 8),
                      Text('${p.rating} · ${p.reviews} reviews',
                          style: AppText.caption.copyWith(color: AppColors.muted)),
                      const Spacer(),
                      Text('\$${p.price.toStringAsFixed(0)}',
                          style: AppText.titleM.copyWith(fontWeight: FontWeight.w700)),
                    ]),
                    const SizedBox(height: 28),
                    _sizeSection(p),
                    const SizedBox(height: 24),
                    _colorSection(p),
                    const SizedBox(height: 28),
                    _expander('DESCRIPTION', descOpen, p.desc,
                        () => setState(() => descOpen = !descOpen)),
                    _expander('COMPOSITION & CARE', careOpen,
                        'Available in ${p.colors.join(', ')}. Sizes: ${p.sizes.join(', ')}. Dry clean recommended. Handle with care.',
                        () => setState(() => careOpen = !careOpen)),
                    const SizedBox(height: 18),
                    _shippingCard(),
                  ],
                ),
              ),
            ),
          ),
          // Bottom bar
          Positioned(
            bottom: 0, left: 0, right: 0,
            child: _bottomBar(p),
          ),
          if (showToast)
            Positioned(
              bottom: 130,
              left: 0, right: 0,
              child: Center(child: _toast()),
            ),
        ],
      ),
    );
  }

  Widget _stars(double rating) {
    return Row(mainAxisSize: MainAxisSize.min, children: List.generate(5, (i) {
      return Icon(Icons.star,
          size: 13,
          color: i < rating.floor() ? AppColors.accent : Colors.black.withOpacity(0.15));
    }));
  }

  Widget _sizeSection(Product p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text('SELECT SIZE', style: AppText.eyebrow),
            const Spacer(),
            Text('Size guide', style: AppText.caption.copyWith(
              color: AppColors.accentInk,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            )),
          ]),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: [
              for (int i = 0; i < p.sizes.length; i++)
                SizeChip(label: p.sizes[i], selected: i == sizeIdx, onTap: () => setState(() => sizeIdx = i)),
            ],
          ),
        ],
      );

  Widget _colorSection(Product p) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('COLOR — ${p.colors[colorIdx]}', style: AppText.eyebrow),
          const SizedBox(height: 12),
          Row(children: [
            for (int i = 0; i < p.colors.length; i++) ...[
              ColorSwatch(
                color: AppColors.swatch[p.colors[i]] ?? const Color(0xFFCCCCCC),
                selected: i == colorIdx,
                onTap: () => setState(() => colorIdx = i),
              ),
              const SizedBox(width: 10),
            ]
          ]),
        ],
      );

  Widget _expander(String title, bool open, String content, VoidCallback onTap) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: Column(
        children: [
          InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Row(
                children: [
                  Expanded(child: Text(title, style: AppText.label)),
                  AnimatedRotation(
                    turns: open ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(Icons.keyboard_arrow_down, size: 20),
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Text(content,
                  style: AppText.bodyS.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.7,
                    fontWeight: FontWeight.w300,
                  )),
            ),
            crossFadeState: open ? CrossFadeState.showSecond : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ],
      ),
    );
  }

  Widget _shippingCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface2,
          borderRadius: BorderRadius.circular(AppRadius.base),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(
              color: AppColors.ink.withOpacity(0.06),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: const Icon(Icons.local_shipping_outlined, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Complimentary shipping', style: AppText.bodyS.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text('Arrives in 2–4 business days · 30-day returns',
                    style: AppText.caption.copyWith(color: AppColors.muted)),
              ],
            ),
          ),
        ]),
      );

  Widget _bottomBar(Product p) {
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter, end: Alignment.bottomCenter,
          colors: [Color(0x00F4EFE7), AppColors.bg, AppColors.bg],
          stops: [0, 0.4, 1],
        ),
      ),
      child: Row(children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            border: Border.all(color: AppColors.lineStrong),
            borderRadius: BorderRadius.circular(AppRadius.base),
          ),
          padding: const EdgeInsets.all(4),
          child: Row(children: [
            _qtyBtn(Icons.remove, () => setState(() => qty = (qty - 1).clamp(1, 99))),
            SizedBox(width: 28, child: Center(
              child: Text('$qty', style: AppText.bodyM.copyWith(fontWeight: FontWeight.w700)),
            )),
            _qtyBtn(Icons.add, () => setState(() => qty += 1)),
          ]),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: PrimaryButton(
            label: 'ADD · \$${(p.price * qty).toStringAsFixed(0)}',
            icon: Icons.shopping_bag_outlined,
            onTap: () {
              context.read<CartManager>()
                  .add(p, p.sizes[sizeIdx], p.colors[colorIdx], qty: qty);
              setState(() => showToast = true);
              Future.delayed(const Duration(milliseconds: 1600), () {
                if (mounted) setState(() => showToast = false);
              });
            },
          ),
        ),
      ]),
    );
  }

  Widget _qtyBtn(IconData icon, VoidCallback onTap) => InkWell(
        onTap: onTap,
        child: SizedBox(width: 38, height: 44, child: Icon(icon, size: 16)),
      );

  Widget _toast() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.ink,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          boxShadow: AppShadows.floating,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check, color: Colors.white, size: 15),
          const SizedBox(width: 8),
          Text('Added to bag', style: AppText.caption.copyWith(color: Colors.white)),
        ]),
      );
}
