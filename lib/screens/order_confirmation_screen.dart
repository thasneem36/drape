// ─────────────────────────────────────────────────────────────
// Order Confirmation — shown immediately after checkout.
// Receives [OrderConfirmationArgs] via route arguments.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../data/models.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/routes/app_routes.dart';
import '../shared/widgets/app_local_image.dart';
import '../shared/widgets/primary_button.dart';

// ── Route args ────────────────────────────────────────────────

class OrderConfirmationArgs {
  final String orderId;
  final List<CartItem> items;
  final double total;
  final String address;

  const OrderConfirmationArgs({
    required this.orderId,
    required this.items,
    required this.total,
    required this.address,
  });
}

// ── Screen ────────────────────────────────────────────────────

class OrderConfirmationScreen extends StatefulWidget {
  final OrderConfirmationArgs args;
  const OrderConfirmationScreen({super.key, required this.args});

  @override
  State<OrderConfirmationScreen> createState() =>
      _OrderConfirmationScreenState();
}

class _OrderConfirmationScreenState
    extends State<OrderConfirmationScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut);
    _fade  = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    // Slight delay so screen has painted before the pop animation fires
    Future.delayed(const Duration(milliseconds: 120), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  // Short display ID: last 6 chars, upper-cased, prefixed #DR-
  String get _shortId {
    final id = widget.args.orderId;
    final suffix = id.length > 6 ? id.substring(id.length - 6) : id;
    return '#DR-${suffix.toUpperCase()}';
  }

  // Estimated delivery window: +5 to +7 calendar days from now
  String get _deliveryWindow {
    final now = DateTime.now();
    final from = now.add(const Duration(days: 5));
    final to   = now.add(const Duration(days: 7));
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final fromStr = '${months[from.month - 1]} ${from.day}';
    final toStr   = '${months[to.month - 1]} ${to.day}';
    return '$fromStr – $toStr';
  }

  @override
  Widget build(BuildContext context) {
    final args = widget.args;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ── Animated check badge ──────────────────────
              ScaleTransition(
                scale: _scale,
                child: FadeTransition(
                  opacity: _fade,
                  child: Container(
                    width: 88,
                    height: 88,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 44,
                      color: Color(0xFF4CAF50),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // ── Heading ───────────────────────────────────
              Text(
                'Order Confirmed!',
                style: AppText.displayL.copyWith(fontSize: 26),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Your style is on its way.',
                style: AppText.bodyS.copyWith(color: AppColors.muted),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),

              // ── Short order ID ────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.line),
                ),
                child: Text(
                  _shortId,
                  style: AppText.eyebrow.copyWith(
                    letterSpacing: 1.6,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Order card ────────────────────────────────
              _OrderCard(args: args, deliveryWindow: _deliveryWindow),
              const SizedBox(height: 16),

              // ── Price card ────────────────────────────────
              _PriceCard(total: args.total),
              const SizedBox(height: 36),

              // ── CTAs ──────────────────────────────────────
              PrimaryButton(
                label: 'TRACK ORDER',
                icon: Icons.local_shipping_outlined,
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.orderHistory,
                  (r) => r.settings.name == AppRoutes.home,
                ),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => Navigator.pushNamedAndRemoveUntil(
                  context,
                  AppRoutes.home,
                  (r) => false,
                ),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(color: AppColors.lineStrong),
                  ),
                  child: Text(
                    'CONTINUE SHOPPING',
                    style: AppText.label.copyWith(letterSpacing: 1.1),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Order summary card ────────────────────────────────────────

class _OrderCard extends StatelessWidget {
  final OrderConfirmationArgs args;
  final String deliveryWindow;
  const _OrderCard({required this.args, required this.deliveryWindow});

  @override
  Widget build(BuildContext context) {
    final items = args.items;
    // Show up to 4 thumbnails, then "+N more"
    const maxThumbs = 4;
    final visible = items.take(maxThumbs).toList();
    final extra   = items.length - visible.length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnails row
          Row(
            children: [
              ...visible.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: SizedBox(
                    width: 52,
                    height: 64,
                    child: ProductThumbnail(
                      imageUrl: item.imageUrl,
                      fallbackLabel: item.name.isNotEmpty
                          ? item.name[0].toLowerCase()
                          : null,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                ),
              ),
              if (extra > 0)
                Container(
                  width: 52,
                  height: 64,
                  decoration: BoxDecoration(
                    color: AppColors.bg,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: AppColors.line),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '+$extra',
                    style: AppText.label.copyWith(color: AppColors.muted),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: 14),

          // Delivery row
          _InfoRow(
            icon: Icons.local_shipping_outlined,
            label: 'Estimated delivery',
            value: deliveryWindow,
          ),
          const SizedBox(height: 10),

          // Address row
          _InfoRow(
            icon: Icons.location_on_outlined,
            label: 'Shipping to',
            value: args.address,
            valueMaxLines: 2,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final int valueMaxLines;
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueMaxLines = 1,
  });

  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: AppColors.muted),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: AppText.eyebrow.copyWith(color: AppColors.muted)),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: AppText.bodyS.copyWith(fontWeight: FontWeight.w600),
                  maxLines: valueMaxLines,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      );
}

// ── Price card ────────────────────────────────────────────────

class _PriceCard extends StatelessWidget {
  final double total;
  const _PriceCard({required this.total});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Text('Total paid',
              style: AppText.bodyS.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(
            '\$${total.toStringAsFixed(2)}',
            style: AppText.titleS.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
