import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models.dart';
import '../../data/wishlist_manager.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';
import 'app_local_image.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final VoidCallback? onTap;
  final bool compact;
  const ProductCard({super.key, required this.product, this.onTap, this.compact = false});

  @override
  Widget build(BuildContext context) {
    final wl    = context.watch<WishlistManager>();
    final saved = wl.contains(product.id);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 3 / 4,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ProductArt(product: product, fontSize: compact ? 15 : 20, borderRadius: BorderRadius.circular(AppRadius.lg)),
                Positioned(top: 12, left: 12, child: Row(children: [
                  if (product.isNew)  _Tag(label: 'NEW',  color: AppColors.ink,    fg: Colors.white),
                  if (product.isSale) _Tag(label: 'SALE', color: AppColors.accent, fg: Colors.white),
                ])),
                Positioned(
                  top: 10, right: 10,
                  child: _HeartBtn(active: saved, onTap: () => context.read<WishlistManager>().toggle(product.id)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(product.brand.toUpperCase(), style: AppText.eyebrow),
                  const SizedBox(height: 4),
                  Text(product.name, style: AppText.productName, maxLines: 1, overflow: TextOverflow.ellipsis),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 2, left: 8),
                child: Text('\$${product.price.toStringAsFixed(0)}',
                    style: AppText.bodyL.copyWith(fontWeight: FontWeight.w600)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;
  final Color color, fg;
  const _Tag({required this.label, required this.color, required this.fg});
  @override
  Widget build(BuildContext context) => Container(
        margin: const EdgeInsets.only(right: 6),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(AppRadius.pill)),
        child: Text(label, style: AppText.micro.copyWith(color: fg)),
      );
}

class _HeartBtn extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;
  const _HeartBtn({required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) => Material(
        color: Colors.white.withOpacity(0.92),
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 34, height: 34,
            child: Icon(active ? Icons.favorite : Icons.favorite_border, size: 16,
                color: active ? AppColors.accent : AppColors.ink),
          ),
        ),
      );
}
