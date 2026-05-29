// ─────────────────────────────────────────────────────────────
// Order Detail — shows the full per-item breakdown, status
// timeline, delivery address and price summary for one order.
// Data lives entirely in the Order object (no extra Firestore
// read needed — all item metadata was stored at order-placement).
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/routes/app_routes.dart';
import '../data/models.dart';
import '../shared/widgets/app_local_image.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

  // ── Status pipeline ───────────────────────────────────────
  static const _stages = ['Processing', 'Shipped', 'Delivered'];

  int get _stageIndex =>
      _stages.indexOf(order.status).clamp(0, _stages.length - 1);

  @override
  Widget build(BuildContext context) {
    final shipping = 9.99;
    final subtotal = order.total - shipping;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    onTap: () => Navigator.maybePop(context),
                    child: Align(
                      alignment: Alignment.centerLeft,
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
                  ),
                  Text('Order Details',
                      style: AppText.titleS.copyWith(
                          fontWeight: FontWeight.w600, fontSize: 17)),
                ],
              ),
            ),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 0, 18, 48),
                children: [
                  // ── Order ID + date ────────────────────────
                  _metaRow(),
                  const SizedBox(height: 20),

                  // ── Status timeline ────────────────────────
                  _statusTimeline(),
                  const SizedBox(height: 28),

                  // ── Items ──────────────────────────────────
                  _sectionLabel('ORDER ITEMS'),
                  const SizedBox(height: 10),
                  _itemsCard(context),
                  const SizedBox(height: 24),

                  // ── Delivery address ───────────────────────
                  _sectionLabel('DELIVERY ADDRESS'),
                  const SizedBox(height: 10),
                  _addressCard(),
                  const SizedBox(height: 24),

                  // ── Price breakdown ────────────────────────
                  _sectionLabel('PRICE BREAKDOWN'),
                  const SizedBox(height: 10),
                  _priceCard(subtotal, shipping),
                  const SizedBox(height: 28),

                  // ── Help button ────────────────────────────
                  GestureDetector(
                    onTap: () =>
                        Navigator.pushNamed(context, AppRoutes.help),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.base),
                        border: Border.all(color: AppColors.line),
                      ),
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.help_outline_rounded,
                              size: 16, color: AppColors.muted),
                          const SizedBox(width: 8),
                          Text('Need help with this order?',
                              style: AppText.bodyS.copyWith(
                                  color: AppColors.muted,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Order meta ────────────────────────────────────────────

  Widget _metaRow() {
    final statusColor = _statusColor(order.status);
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(order.id,
                  style: AppText.label.copyWith(letterSpacing: 0.5)),
              const SizedBox(height: 3),
              Text(order.date,
                  style: AppText.caption
                      .copyWith(color: AppColors.muted)),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(AppRadius.pill),
          ),
          child: Text(order.status,
              style: AppText.label.copyWith(
                  color: statusColor,
                  letterSpacing: 0.8)),
        ),
      ],
    );
  }

  // ── Status timeline ───────────────────────────────────────

  Widget _statusTimeline() {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: List.generate(_stages.length * 2 - 1, (i) {
          if (i.isOdd) {
            // Connector line
            final stageIdx = i ~/ 2;
            final done = stageIdx < _stageIndex;
            return Expanded(
              child: Container(
                height: 2,
                color: done ? AppColors.ink : AppColors.line,
              ),
            );
          }
          final stageIdx = i ~/ 2;
          final done = stageIdx <= _stageIndex;
          final active = stageIdx == _stageIndex;
          return Column(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: done ? AppColors.ink : AppColors.bg,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: done
                        ? AppColors.ink
                        : AppColors.lineStrong,
                    width: active ? 2 : 1,
                  ),
                ),
                child: done
                    ? Icon(
                        active
                            ? Icons.radio_button_checked
                            : Icons.check,
                        size: 14,
                        color: Colors.white,
                      )
                    : null,
              ),
              const SizedBox(height: 6),
              Text(
                _stages[stageIdx],
                style: AppText.micro.copyWith(
                  color: done ? AppColors.ink : AppColors.muted,
                  fontWeight:
                      active ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 9,
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ── Items card ────────────────────────────────────────────

  Widget _itemsCard(BuildContext context) {
    if (order.orderItems.isEmpty) {
      // Fallback: no full item data (older orders stored before v2)
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: order.itemNames
              .where((n) => n.isNotEmpty)
              .map((n) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(n, style: AppText.bodyS),
                  ))
              .toList(),
        ),
      );
    }
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: List.generate(order.orderItems.length, (i) {
          final item = order.orderItems[i];
          final isLast = i == order.orderItems.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Thumbnail
                    SizedBox(
                      width: 60,
                      height: 76,
                      child: ProductThumbnail(
                        imageUrl: item.imageUrl,
                        fallbackLabel: item.name.isNotEmpty
                            ? item.name[0].toLowerCase()
                            : null,
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Details
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          if (item.brand.isNotEmpty)
                            Text(item.brand.toUpperCase(),
                                style: AppText.eyebrow),
                          const SizedBox(height: 2),
                          Text(item.name,
                              style: AppText.productName,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 6),
                          Text(
                            [
                              if (item.size.isNotEmpty) item.size,
                              if (item.color.isNotEmpty) item.color,
                              'Qty ${item.qty}',
                            ].join(' · '),
                            style: AppText.caption.copyWith(
                                color: AppColors.muted),
                          ),
                        ],
                      ),
                    ),
                    // Price
                    Text(
                      '\$${(item.price * item.qty).toStringAsFixed(0)}',
                      style: AppText.bodyS
                          .copyWith(fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 1, indent: 86, color: AppColors.line),
            ],
          );
        }),
      ),
    );
  }

  // ── Address card ──────────────────────────────────────────

  Widget _addressCard() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.location_on_outlined,
                  size: 17, color: AppColors.muted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                order.address.isEmpty ? '—' : order.address,
                style: AppText.bodyS
                    .copyWith(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      );

  // ── Price card ────────────────────────────────────────────

  Widget _priceCard(double subtotal, double shipping) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: [
            _priceRow('Subtotal',
                '\$${subtotal.toStringAsFixed(2)}'),
            const SizedBox(height: 10),
            _priceRow('Shipping',
                '\$${shipping.toStringAsFixed(2)}'),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, color: AppColors.line),
            ),
            _priceRow(
              'Total',
              '\$${order.total.toStringAsFixed(2)}',
              bold: true,
            ),
          ],
        ),
      );

  Widget _priceRow(String label, String value,
          {bool bold = false}) =>
      Row(
        children: [
          Text(label,
              style: bold
                  ? AppText.bodyM
                      .copyWith(fontWeight: FontWeight.w700)
                  : AppText.bodyS.copyWith(
                      color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: bold
                  ? AppText.titleS
                      .copyWith(fontWeight: FontWeight.w700)
                  : AppText.bodyS
                      .copyWith(fontWeight: FontWeight.w600)),
        ],
      );

  // ── Helpers ───────────────────────────────────────────────

  Widget _sectionLabel(String text) =>
      Text(text, style: AppText.eyebrow.copyWith(letterSpacing: 1.4));

  Color _statusColor(String status) => switch (status) {
        'Delivered' => const Color(0xFF4CAF50),
        'Shipped'   => AppColors.accentInk,
        'Processing' => AppColors.accent,
        _            => AppColors.muted,
      };
}
