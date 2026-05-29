// ─────────────────────────────────────────────────────────────
// Cart screen — reads product metadata directly from CartItem
// (stored in Firestore at add-to-cart time).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/cart_manager.dart';
import '../data/models.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/routes/app_routes.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/primary_button.dart';
import '../shared/widgets/app_local_image.dart';
import '../shared/widgets/drape_scaffold.dart';
import 'empty_state.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartManager>();
    final items = cart.items;
    final subtotal = cart.subtotal();
    final shipping = subtotal > 0 ? 9.99 : 0.0;
    final total = subtotal + shipping;

    return DrapeScaffold(
      tab: TabItem.cart,
      body: Column(
        children: [
          _AppBarRow(title: 'Your Bag'),
          Expanded(
            child: items.isEmpty
                ? const EmptyState(
                    icon: Icons.shopping_bag_outlined,
                    title: 'Your bag is quiet.',
                    sub: 'Add a piece you love.',
                    cta: 'Start shopping',
                    route: AppRoutes.products,
                  )
                : Stack(
                    children: [
                      ListView(
                        padding: const EdgeInsets.fromLTRB(
                            18, 4, 18, 220),
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 6, bottom: 16),
                            child: Text(
                              '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                              style: AppText.caption.copyWith(
                                  color: AppColors.muted),
                            ),
                          ),
                          ...List.generate(items.length, (i) {
                            final it = items[i];
                            return Padding(
                              padding: const EdgeInsets.only(
                                  bottom: 14),
                              child: _CartRow(
                                item: it,
                                onRemove: () => context
                                    .read<CartManager>()
                                    .removeAt(i),
                                onInc: () => context
                                    .read<CartManager>()
                                    .setQty(i, it.qty + 1),
                                onDec: () => context
                                    .read<CartManager>()
                                    .setQty(i, it.qty - 1),
                              ),
                            );
                          }),
                          const SizedBox(height: 4),
                          _PromoRow(),
                          const SizedBox(height: 22),
                          _SummaryCard(
                            subtotal: subtotal,
                            shipping: shipping,
                            total: total,
                          ),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: SafeArea(
                          top: false,
                          child: Container(
                            padding: const EdgeInsets.fromLTRB(
                                18, 16, 18, 10),
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Color(0x00F4EFE7),
                                  AppColors.bg,
                                  AppColors.bg,
                                ],
                                stops: [0, 0.35, 1],
                              ),
                            ),
                            child: PrimaryButton(
                              label:
                                  'CHECKOUT · \$${total.toStringAsFixed(2)}',
                              icon: Icons.arrow_forward,
                              onTap: () => Navigator.pushNamed(
                                  context, AppRoutes.checkout),
                            ),
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
}

class _AppBarRow extends StatelessWidget {
  final String title;
  const _AppBarRow({required this.title});
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
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
              child: Text(title,
                  style: AppText.titleS.copyWith(fontSize: 18)),
            ),
          ],
        ),
      );
}

/// Cart row — uses product metadata embedded in CartItem.
class _CartRow extends StatelessWidget {
  final CartItem item;
  final VoidCallback onRemove, onInc, onDec;
  const _CartRow({
    required this.item,
    required this.onRemove,
    required this.onInc,
    required this.onDec,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 86,
            height: 108,
            child: ProductThumbnail(
              imageUrl: item.imageUrl,
              fallbackLabel: item.name.isNotEmpty
                  ? item.name[0].toLowerCase()
                  : null,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(item.brand.toUpperCase(),
                              style: AppText.eyebrow),
                          const SizedBox(height: 3),
                          Text(
                            item.name,
                            style: AppText.productName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    InkWell(
                      onTap: onRemove,
                      customBorder: const CircleBorder(),
                      child: const SizedBox(
                        width: 28,
                        height: 28,
                        child: Icon(Icons.close,
                            size: 15, color: AppColors.muted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Wrap(
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    _Badge(label: 'Size ${item.size}'),
                    _Badge(
                      label: item.color,
                      swatch: AppColors.swatch[item.color],
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.lineStrong),
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                      ),
                      child: Row(
                        children: [
                          _roundBtn(Icons.remove, onDec),
                          SizedBox(
                            width: 22,
                            child: Center(
                              child: Text('${item.qty}',
                                  style: AppText.caption.copyWith(
                                      fontWeight: FontWeight.w700)),
                            ),
                          ),
                          _roundBtn(Icons.add, onInc),
                        ],
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '\$${(item.price * item.qty).toStringAsFixed(2)}',
                      style: AppText.bodyM.copyWith(
                          fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _roundBtn(IconData icon, VoidCallback onTap) =>
      InkWell(
        onTap: onTap,
        child: SizedBox(
            width: 28,
            height: 28,
            child: Icon(icon, size: 12)),
      );
}

class _Badge extends StatelessWidget {
  final String label;
  final Color? swatch;
  const _Badge({required this.label, this.swatch});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.ink.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppRadius.xs + 2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (swatch != null) ...[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                  color: swatch, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          Text(label,
              style: AppText.caption.copyWith(
                  color: AppColors.textSecondary, fontSize: 10.5)),
        ],
      ),
    );
  }
}

class _PromoRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface2,
        borderRadius: BorderRadius.circular(AppRadius.base),
        border:
            Border.all(color: AppColors.lineStrong),
      ),
      child: Row(
        children: [
          const Icon(Icons.auto_awesome,
              size: 16, color: AppColors.accentInk),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Members save 15% — join the Club',
              style: AppText.caption.copyWith(
                  color: AppColors.textSecondary, fontSize: 12.5),
            ),
          ),
          Text('APPLY',
              style: AppText.label.copyWith(
                  color: AppColors.accentInk, fontSize: 11)),
        ],
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final double subtotal, shipping, total;
  const _SummaryCard({
    required this.subtotal,
    required this.shipping,
    required this.total,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          summaryRow('Subtotal', subtotal),
          summaryRow('Shipping', shipping),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.line),
          ),
          summaryRow('Total', total, bold: true),
        ],
      ),
    );
  }
}

Widget summaryRow(String label, double value,
        {bool bold = false}) =>
    Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: bold
                ? AppText.bodyM
                    .copyWith(fontWeight: FontWeight.w700)
                : AppText.bodyS
                    .copyWith(color: AppColors.textSecondary),
          ),
          const Spacer(),
          Text(
            '\$${value.toStringAsFixed(2)}',
            style: bold
                ? AppText.titleM
                    .copyWith(fontWeight: FontWeight.w700)
                : AppText.bodyS
                    .copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
