// ─────────────────────────────────────────────────────────────
// Checkout — address/payment lists come from Firestore (via
// UserProfileManager).  Cart metadata comes from CartManager.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/cart_manager.dart';
import '../data/models.dart';
import '../data/order_manager.dart';
import '../data/user_profile_manager.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/routes/app_routes.dart';
import '../shared/widgets/app_local_image.dart';
import '../shared/widgets/primary_button.dart';
import 'order_confirmation_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});
  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  int _addressIdx = 0;
  int _paymentIdx = 0;

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartManager>();
    final profile = context.watch<UserProfileManager>();
    final items = cart.items;
    final subtotal = cart.subtotal();
    final shipping = subtotal > 0 ? 9.99 : 0.0;
    final total = subtotal + shipping;
    final addresses = profile.addresses;
    final payments = profile.payments;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ──────────────────────────────────────
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
                  Text('Checkout',
                      style: AppText.titleS.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 17)),
                ],
              ),
            ),

            Expanded(
              child: items.isEmpty
                  ? _emptyCart(context)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                          18, 0, 18, 120),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          // ── Order summary ──────────────────
                          _sectionLabel('ORDER SUMMARY'),
                          const SizedBox(height: 12),
                          _orderSummaryCard(items),
                          const SizedBox(height: 24),

                          // ── Deliver to ─────────────────────
                          _sectionLabel('DELIVER TO'),
                          const SizedBox(height: 12),
                          if (addresses.isEmpty)
                            _noDataHint(
                                'No saved addresses. Add one in your Profile.')
                          else
                            ...List.generate(
                              addresses.length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 10),
                                child: _AddressCard(
                                  address: addresses[i],
                                  selected: i == _addressIdx,
                                  onTap: () => setState(
                                      () => _addressIdx = i),
                                ),
                              ),
                            ),
                          const SizedBox(height: 14),

                          // ── Pay with ───────────────────────
                          _sectionLabel('PAY WITH'),
                          const SizedBox(height: 12),
                          if (payments.isEmpty)
                            _noDataHint(
                                'No saved payment methods. Add one in your Profile.')
                          else
                            ...List.generate(
                              payments.length,
                              (i) => Padding(
                                padding: const EdgeInsets.only(
                                    bottom: 10),
                                child: _PaymentCard(
                                  payment: payments[i],
                                  selected: i == _paymentIdx,
                                  onTap: () => setState(
                                      () => _paymentIdx = i),
                                ),
                              ),
                            ),
                          const SizedBox(height: 24),

                          // ── Price breakdown ────────────────
                          _sectionLabel('PRICE BREAKDOWN'),
                          const SizedBox(height: 12),
                          _priceCard(subtotal, shipping, total),
                        ],
                      ),
                    ),
            ),

            // ── Confirm bar ─────────────────────────────────
            if (items.isNotEmpty && addresses.isNotEmpty)
              Container(
                padding: const EdgeInsets.fromLTRB(
                    18, 14, 18, 26),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0x00F4EFE7),
                      AppColors.bg,
                      AppColors.bg
                    ],
                    stops: [0, 0.4, 1],
                  ),
                ),
                child: PrimaryButton(
                  label:
                      'CONFIRM ORDER · \$${total.toStringAsFixed(2)}',
                  icon: Icons.check_circle_outline,
                  onTap: () => _confirmOrder(
                      context, cart, items, addresses, total),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmOrder(
    BuildContext context,
    CartManager cart,
    List<CartItem> items,
    List<Address> addresses,
    double total,
  ) async {
    final address    = addresses[_addressIdx];
    final addressStr = '${address.line1}, ${address.line2}';

    // Snapshot items before clearing the cart
    final snapshot = List<CartItem>.from(items);

    final orderId = await context
        .read<OrderManager>()
        .placeOrder(snapshot, addressStr, total);
    await cart.clear();

    if (!context.mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.orderConfirmation,
      (r) => r.settings.name == AppRoutes.home,
      arguments: OrderConfirmationArgs(
        orderId: orderId,
        items:   snapshot,
        total:   total,
        address: addressStr,
      ),
    );
  }

  Widget _sectionLabel(String text) =>
      Text(text, style: AppText.eyebrow.copyWith(letterSpacing: 1.4));

  Widget _noDataHint(String msg) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.base),
            border: Border.all(color: AppColors.line),
          ),
          child: Row(children: [
            const Icon(Icons.info_outline,
                size: 16, color: AppColors.muted),
            const SizedBox(width: 10),
            Expanded(
                child: Text(msg,
                    style: AppText.caption
                        .copyWith(color: AppColors.muted))),
          ]),
        ),
      );

  Widget _orderSummaryCard(List<CartItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final isLast = i == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    SizedBox(
                      width: 56,
                      height: 70,
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
                    Expanded(
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(item.brand.toUpperCase(),
                              style: AppText.eyebrow),
                          const SizedBox(height: 2),
                          Text(item.name,
                              style: AppText.productName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text(
                              '${item.size} · ${item.color} · Qty ${item.qty}',
                              style: AppText.caption.copyWith(
                                  color: AppColors.muted)),
                        ],
                      ),
                    ),
                    Text(
                        '\$${(item.price * item.qty).toStringAsFixed(0)}',
                        style: AppText.bodyS.copyWith(
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
              if (!isLast)
                const Divider(
                    height: 1,
                    indent: 82,
                    color: AppColors.line),
            ],
          );
        }),
      ),
    );
  }

  Widget _priceCard(
      double subtotal, double shipping, double total) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: [
          _priceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _priceRow('Shipping',
              shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(2)}'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, color: AppColors.line),
          ),
          _priceRow('Total', '\$${total.toStringAsFixed(2)}',
              bold: true),
        ],
      ),
    );
  }

  Widget _priceRow(String label, String value,
          {bool bold = false}) =>
      Row(
        children: [
          Text(label,
              style: bold
                  ? AppText.bodyM
                      .copyWith(fontWeight: FontWeight.w700)
                  : AppText.bodyS
                      .copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: bold
                  ? AppText.titleS
                      .copyWith(fontWeight: FontWeight.w700)
                  : AppText.bodyS
                      .copyWith(fontWeight: FontWeight.w600)),
        ],
      );

  Widget _emptyCart(BuildContext context) => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.shopping_bag_outlined,
                size: 48, color: AppColors.muted),
            const SizedBox(height: 16),
            Text('Your bag is empty',
                style: AppText.titleM
                    .copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text('Add items to continue',
                style: AppText.bodyS
                    .copyWith(color: AppColors.muted)),
            const SizedBox(height: 24),
            GestureDetector(
              onTap: () => Navigator.pushReplacementNamed(
                  context, AppRoutes.products),
              child: Text('Browse the shop',
                  style: AppText.bodyS.copyWith(
                    color: AppColors.accentInk,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  )),
            ),
          ],
        ),
      );
}

// ── Address Card ─────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onTap;
  const _AddressCard(
      {required this.address,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.ink.withValues(alpha: 0.04)
                : AppColors.surface,
            borderRadius:
                BorderRadius.circular(AppRadius.base),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.ink
                      : AppColors.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.location_on_outlined,
                    size: 18,
                    color: selected
                        ? Colors.white
                        : AppColors.muted),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Text(address.label,
                          style: AppText.bodyS.copyWith(
                              fontWeight: FontWeight.w600)),
                      if (address.isDefault) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.sage
                                .withValues(alpha: 0.2),
                            borderRadius:
                                BorderRadius.circular(AppRadius.xs),
                          ),
                          child: Text('DEFAULT',
                              style: AppText.micro.copyWith(
                                  color: AppColors.sage,
                                  fontSize: 8,
                                  fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ]),
                    const SizedBox(height: 2),
                    Text('${address.line1}, ${address.line2}',
                        style: AppText.caption
                            .copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle,
                    size: 20, color: AppColors.ink),
            ],
          ),
        ),
      );
}

// ── Payment Card ─────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final Payment payment;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentCard(
      {required this.payment,
      required this.selected,
      required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: selected
                ? AppColors.ink.withValues(alpha: 0.04)
                : AppColors.surface,
            borderRadius:
                BorderRadius.circular(AppRadius.base),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.ink
                      : AppColors.bg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  payment.brand == 'apple'
                      ? Icons.phone_iphone
                      : Icons.credit_card_outlined,
                  size: 18,
                  color: selected
                      ? Colors.white
                      : AppColors.muted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(payment.label,
                        style: AppText.bodyS.copyWith(
                            fontWeight: FontWeight.w600)),
                    const SizedBox(height: 2),
                    Text(payment.detail,
                        style: AppText.caption
                            .copyWith(color: AppColors.muted)),
                  ],
                ),
              ),
              if (selected)
                const Icon(Icons.check_circle,
                    size: 20, color: AppColors.ink),
            ],
          ),
        ),
      );
}
