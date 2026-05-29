// ─────────────────────────────────────────────────────────────
// Order History — reads live from OrderManager (Firestore stream).
// Product names are stored inside each Order.itemNames — no
// secondary product lookup required.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/routes/app_routes.dart';
import '../data/models.dart';
import '../data/order_manager.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/drape_scaffold.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderManager>().orders;

    return DrapeScaffold(
      tab: TabItem.profile,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── App bar ─────────────────────────────────────────
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
                Text('Orders',
                    style: AppText.titleS.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 17)),
              ],
            ),
          ),

          // ── Title ───────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ORDER HISTORY',
                    style: AppText.eyebrow
                        .copyWith(letterSpacing: 1.4)),
                const SizedBox(height: 4),
                Text(
                    '${orders.length} ${orders.length == 1 ? 'order' : 'orders'}',
                    style: AppText.bodyS
                        .copyWith(color: AppColors.muted)),
              ],
            ),
          ),

          // ── List ────────────────────────────────────────────
          Expanded(
            child: orders.isEmpty
                ? _emptyState()
                : ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        18, 0, 18, 120),
                    itemCount: orders.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: 12),
                    itemBuilder: (_, i) => _OrderCard(
                          order: orders[i],
                          onTap: () => Navigator.pushNamed(
                            context,
                            AppRoutes.orderDetail,
                            arguments: orders[i],
                          ),
                        ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() => Center(
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
              child: const Icon(Icons.receipt_long_outlined,
                  size: 28, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Text('No orders yet',
                style: AppText.titleM
                    .copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text('Your placed orders will appear here',
                style: AppText.bodyS
                    .copyWith(color: AppColors.muted)),
          ],
        ),
      );
}

class _OrderCard extends StatelessWidget {
  final Order order;
  final VoidCallback? onTap;
  const _OrderCard({required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    final statusColor = switch (order.status) {
      'Delivered' => const Color(0xFF4CAF50),
      'Shipped' => AppColors.accentInk,
      'Processing' => AppColors.accent,
      _ => AppColors.muted,
    };

    // Use stored item names — no product lookup needed.
    final names = order.itemNames.isNotEmpty
        ? order.itemNames
            .where((n) => n.isNotEmpty)
            .join(', ')
        : order.itemIds.length == 1
            ? '1 item'
            : '${order.itemIds.length} items';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Order header
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(order.id, style: AppText.label),
                    const SizedBox(height: 2),
                    Text(order.date,
                        style: AppText.caption
                            .copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius:
                      BorderRadius.circular(AppRadius.pill),
                ),
                child: Text(order.status,
                    style: AppText.micro.copyWith(
                        color: statusColor,
                        fontWeight: FontWeight.w700)),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 12),

          // Product names
          Text(
            names,
            style: AppText.bodyS
                .copyWith(color: AppColors.textSecondary),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),

          // Footer
          Row(
            children: [
              const Icon(Icons.location_on_outlined,
                  size: 13, color: AppColors.muted),
              const SizedBox(width: 4),
              Expanded(
                child: Text(order.address,
                    style: AppText.caption
                        .copyWith(color: AppColors.muted),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ),
              Text(
                '\$${order.total.toStringAsFixed(2)}',
                style: AppText.bodyS
                    .copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(width: 6),
              const Icon(Icons.chevron_right,
                  size: 16, color: AppColors.muted),
            ],
          ),
        ],
      ),
    );
  }
}
