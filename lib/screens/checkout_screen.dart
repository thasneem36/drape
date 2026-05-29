// ─────────────────────────────────────────────────────────────
// Checkout — inline address + payment forms when none saved.
// Saved items show as selectable cards + "+ Add New" button.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int  _addressIdx     = 0;
  int  _paymentIdx     = 0;
  bool _showAddrForm   = false;
  bool _showPayForm    = false;
  bool _placing        = false;

  // ── Confirm order ────────────────────────────────────────────

  Future<void> _confirmOrder(
    CartManager cart,
    List<CartItem> items,
    List<Address> addresses,
    double total,
  ) async {
    if (_placing) return;
    setState(() => _placing = true);
    try {
      final address    = addresses[_addressIdx];
      final addressStr = '${address.line1}, ${address.line2}';
      final snapshot   = List<CartItem>.from(items);

      final orderId = await context
          .read<OrderManager>()
          .placeOrder(snapshot, addressStr, total);
      await cart.clear();

      if (!mounted) return;
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
    } catch (e) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not place order. Please try again.')),
      );
    }
  }

  // ── Save helpers ─────────────────────────────────────────────

  Future<void> _saveAddress(Address addr) async {
    final mgr    = context.read<UserProfileManager>();
    final newIdx = mgr.addresses.length;
    await mgr.addAddress(addr);
    if (!mounted) return;
    setState(() {
      _addressIdx   = newIdx;
      _showAddrForm = false;
    });
  }

  Future<void> _savePayment(Payment pay) async {
    final mgr    = context.read<UserProfileManager>();
    final newIdx = mgr.payments.length;
    await mgr.addPayment(pay);
    if (!mounted) return;
    setState(() {
      _paymentIdx  = newIdx;
      _showPayForm = false;
    });
  }

  // ── Build ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final cart      = context.watch<CartManager>();
    final profile   = context.watch<UserProfileManager>();
    final items     = cart.items;
    final subtotal  = cart.subtotal();
    final shipping  = subtotal > 0 ? 9.99 : 0.0;
    final total     = subtotal + shipping;
    final addresses = profile.addresses;
    final payments  = profile.payments;

    // Guard: if selected index is out-of-range after a remove
    if (_addressIdx >= addresses.length && addresses.isNotEmpty) {
      _addressIdx = addresses.length - 1;
    }
    if (_paymentIdx >= payments.length && payments.isNotEmpty) {
      _paymentIdx = payments.length - 1;
    }

    final canOrder = items.isNotEmpty &&
        addresses.isNotEmpty &&
        payments.isNotEmpty;

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
                        width: 44, height: 44,
                        decoration: const BoxDecoration(
                          color: Colors.white, shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 8, offset: Offset(0, 2))],
                        ),
                        child: const Icon(Icons.arrow_back,
                            size: 20, color: AppColors.ink),
                      ),
                    ),
                  ),
                  Text('Checkout',
                      style: AppText.titleS
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 17)),
                ],
              ),
            ),

            Expanded(
              child: items.isEmpty
                  ? _emptyCart(context)
                  : SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 120),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // ── Order summary ────────────────
                          _sectionLabel('ORDER SUMMARY'),
                          const SizedBox(height: 12),
                          _orderSummaryCard(items),
                          const SizedBox(height: 24),

                          // ── Deliver to ───────────────────
                          _sectionLabel('DELIVER TO'),
                          const SizedBox(height: 12),
                          _AddressSection(
                            addresses:    addresses,
                            selectedIdx:  _addressIdx,
                            showForm:     _showAddrForm,
                            onSelect:     (i) => setState(() {
                              _addressIdx   = i;
                              _showAddrForm = false;
                            }),
                            onAddTap:     () => setState(
                                () => _showAddrForm = !_showAddrForm),
                            onSave:       _saveAddress,
                          ),
                          const SizedBox(height: 24),

                          // ── Pay with ─────────────────────
                          _sectionLabel('PAY WITH'),
                          const SizedBox(height: 12),
                          _PaymentSection(
                            payments:    payments,
                            selectedIdx: _paymentIdx,
                            showForm:    _showPayForm,
                            onSelect:    (i) => setState(() {
                              _paymentIdx  = i;
                              _showPayForm = false;
                            }),
                            onAddTap:    () => setState(
                                () => _showPayForm = !_showPayForm),
                            onSave:      _savePayment,
                          ),
                          const SizedBox(height: 24),

                          // ── Price breakdown ──────────────
                          _sectionLabel('PRICE BREAKDOWN'),
                          const SizedBox(height: 12),
                          _priceCard(subtotal, shipping, total),
                        ],
                      ),
                    ),
            ),

            // ── Confirm bar ──────────────────────────────────
            if (canOrder)
              Container(
                padding: const EdgeInsets.fromLTRB(18, 14, 18, 26),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0x00F4EFE7), AppColors.bg, AppColors.bg],
                    stops: [0, 0.4, 1],
                  ),
                ),
                child: PrimaryButton(
                  label: _placing
                      ? 'PLACING ORDER…'
                      : 'CONFIRM ORDER · \$${total.toStringAsFixed(2)}',
                  icon: _placing ? null : Icons.check_circle_outline,
                  onTap: _placing
                      ? null
                      : () => _confirmOrder(
                          context.read<CartManager>(), items, addresses, total),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────────

  Widget _sectionLabel(String text) =>
      Text(text, style: AppText.eyebrow.copyWith(letterSpacing: 1.4));

  Widget _orderSummaryCard(List<CartItem> items) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final item   = items[i];
          final isLast = i == items.length - 1;
          return Column(children: [
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(children: [
                SizedBox(
                  width: 56, height: 70,
                  child: ProductThumbnail(
                    imageUrl: item.imageUrl,
                    fallbackLabel: item.name.isNotEmpty
                        ? item.name[0].toLowerCase()
                        : null,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.brand.toUpperCase(),
                          style: AppText.eyebrow),
                      const SizedBox(height: 2),
                      Text(item.name,
                          style: AppText.productName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 4),
                      Text('${item.size} · ${item.color} · Qty ${item.qty}',
                          style: AppText.caption
                              .copyWith(color: AppColors.muted)),
                    ],
                  ),
                ),
                Text('\$${(item.price * item.qty).toStringAsFixed(0)}',
                    style: AppText.bodyS
                        .copyWith(fontWeight: FontWeight.w700)),
              ]),
            ),
            if (!isLast)
              const Divider(height: 1, indent: 82, color: AppColors.line),
          ]);
        }),
      ),
    );
  }

  Widget _priceCard(double subtotal, double shipping, double total) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(children: [
        _priceRow('Subtotal', '\$${subtotal.toStringAsFixed(2)}'),
        const SizedBox(height: 10),
        _priceRow('Shipping',
            shipping == 0 ? 'Free' : '\$${shipping.toStringAsFixed(2)}'),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 12),
          child: Divider(height: 1, color: AppColors.line),
        ),
        _priceRow('Total', '\$${total.toStringAsFixed(2)}', bold: true),
      ]),
    );
  }

  Widget _priceRow(String label, String value, {bool bold = false}) => Row(
        children: [
          Text(label,
              style: bold
                  ? AppText.bodyM.copyWith(fontWeight: FontWeight.w700)
                  : AppText.bodyS.copyWith(color: AppColors.textSecondary)),
          const Spacer(),
          Text(value,
              style: bold
                  ? AppText.titleS.copyWith(fontWeight: FontWeight.w700)
                  : AppText.bodyS.copyWith(fontWeight: FontWeight.w600)),
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
                style: AppText.titleM.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text('Add items to continue',
                style: AppText.bodyS.copyWith(color: AppColors.muted)),
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

// ═══════════════════════════════════════════════════════════════
// ADDRESS SECTION
// ═══════════════════════════════════════════════════════════════

class _AddressSection extends StatelessWidget {
  final List<Address> addresses;
  final int selectedIdx;
  final bool showForm;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddTap;
  final Future<void> Function(Address) onSave;

  const _AddressSection({
    required this.addresses,
    required this.selectedIdx,
    required this.showForm,
    required this.onSelect,
    required this.onAddTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    if (addresses.isEmpty && !showForm) {
      // ── No addresses — show inline form immediately ──
      return _AddressForm(onSave: onSave);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Saved address cards
        ...List.generate(addresses.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _AddressCard(
            address:  addresses[i],
            selected: i == selectedIdx,
            onTap:    () => onSelect(i),
          ),
        )),

        // "+ Add New Address" button or inline form
        if (showForm) ...[
          const SizedBox(height: 4),
          _AddressForm(onSave: onSave, compact: true),
        ] else
          _AddNewButton(
            label: '+ Add New Address',
            onTap: onAddTap,
          ),
      ],
    );
  }
}

// ── Inline address form ───────────────────────────────────────

class _AddressForm extends StatefulWidget {
  final Future<void> Function(Address) onSave;
  final bool compact;
  const _AddressForm({required this.onSave, this.compact = false});

  @override
  State<_AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<_AddressForm> {
  final _line1Ctrl  = TextEditingController();
  final _line2Ctrl  = TextEditingController();
  String _label     = 'Home';
  bool   _saving    = false;
  String? _error;

  static const _labels = ['Home', 'Work', 'Other'];

  @override
  void dispose() {
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final line1 = _line1Ctrl.text.trim();
    final line2 = _line2Ctrl.text.trim();
    if (line1.isEmpty || line2.isEmpty) {
      setState(() => _error = 'Please fill in both address fields.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    await widget.onSave(Address(_label, line1, line2));
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.compact) ...[
            Text('Add Delivery Address',
                style: AppText.bodyS.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
          ],

          // Label chips
          Row(
            children: _labels.map((l) {
              final sel = l == _label;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: GestureDetector(
                  onTap: () => setState(() => _label = l),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: sel ? AppColors.ink : AppColors.bg,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                        color: sel ? AppColors.ink : AppColors.line,
                      ),
                    ),
                    child: Text(l,
                        style: AppText.caption.copyWith(
                          color: sel ? Colors.white : AppColors.muted,
                          fontWeight: FontWeight.w600,
                        )),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Line 1
          _FormField(
            controller: _line1Ctrl,
            hint: 'Street address',
            icon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 10),

          // Line 2
          _FormField(
            controller: _line2Ctrl,
            hint: 'City, State ZIP  (e.g. New York, NY 10001)',
            icon: Icons.map_outlined,
          ),

          // Error
          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: AppText.caption.copyWith(color: Colors.redAccent)),
          ],

          const SizedBox(height: 14),
          PrimaryButton(
            label: _saving ? 'SAVING…' : 'SAVE & USE THIS ADDRESS',
            icon: _saving ? null : Icons.check_rounded,
            onTap: _saving ? null : _submit,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// PAYMENT SECTION
// ═══════════════════════════════════════════════════════════════

class _PaymentSection extends StatelessWidget {
  final List<Payment> payments;
  final int selectedIdx;
  final bool showForm;
  final ValueChanged<int> onSelect;
  final VoidCallback onAddTap;
  final Future<void> Function(Payment) onSave;

  const _PaymentSection({
    required this.payments,
    required this.selectedIdx,
    required this.showForm,
    required this.onSelect,
    required this.onAddTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    if (payments.isEmpty && !showForm) {
      return _PaymentForm(onSave: onSave);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...List.generate(payments.length, (i) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: _PaymentCard(
            payment:  payments[i],
            selected: i == selectedIdx,
            onTap:    () => onSelect(i),
          ),
        )),

        if (showForm) ...[
          const SizedBox(height: 4),
          _PaymentForm(onSave: onSave, compact: true),
        ] else
          _AddNewButton(
            label: '+ Add New Payment Method',
            onTap: onAddTap,
          ),
      ],
    );
  }
}

// ── Inline payment form ───────────────────────────────────────

class _PaymentForm extends StatefulWidget {
  final Future<void> Function(Payment) onSave;
  final bool compact;
  const _PaymentForm({required this.onSave, this.compact = false});

  @override
  State<_PaymentForm> createState() => _PaymentFormState();
}

class _PaymentFormState extends State<_PaymentForm> {
  final _last4Ctrl    = TextEditingController();
  final _nicknameCtrl = TextEditingController();
  String _brand       = 'visa';
  bool   _saving      = false;
  String? _error;

  static const _brands = ['visa', 'mastercard', 'amex', 'other'];
  static const _brandLabels = {
    'visa':       'Visa',
    'mastercard': 'Mastercard',
    'amex':       'Amex',
    'other':      'Other',
  };

  @override
  void initState() {
    super.initState();
    _last4Ctrl.addListener(_autoNickname);
  }

  void _autoNickname() {
    // Auto-fill nickname when last4 is typed and nickname is empty
    if (_nicknameCtrl.text.isEmpty) {
      setState(() {}); // re-render hint
    }
  }

  String get _suggestedNickname =>
      'My ${_brandLabels[_brand] ?? 'Card'}';

  @override
  void dispose() {
    _last4Ctrl.removeListener(_autoNickname);
    _last4Ctrl.dispose();
    _nicknameCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final last4    = _last4Ctrl.text.trim();
    final nickname = _nicknameCtrl.text.trim().isEmpty
        ? _suggestedNickname
        : _nicknameCtrl.text.trim();

    if (last4.length != 4) {
      setState(() => _error = 'Please enter the last 4 digits of your card.');
      return;
    }
    setState(() { _saving = true; _error = null; });

    final brandLabel = _brandLabels[_brand] ?? 'Card';
    final detail     = '**** $last4 · $brandLabel';
    await widget.onSave(Payment(nickname, detail, _brand));
    if (mounted) setState(() => _saving = false);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.ink.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.compact) ...[
            Text('Add Payment Method',
                style: AppText.bodyS.copyWith(fontWeight: FontWeight.w600)),
            const SizedBox(height: 14),
          ],

          // Brand chips
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _brands.map((b) {
              final sel = b == _brand;
              return GestureDetector(
                onTap: () => setState(() => _brand = b),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 7),
                  decoration: BoxDecoration(
                    color: sel ? AppColors.ink : AppColors.bg,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                    border: Border.all(
                        color: sel ? AppColors.ink : AppColors.line),
                  ),
                  child: Text(_brandLabels[b]!,
                      style: AppText.caption.copyWith(
                        color: sel ? Colors.white : AppColors.muted,
                        fontWeight: FontWeight.w600,
                      )),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 12),

          // Last 4 digits
          _FormField(
            controller: _last4Ctrl,
            hint: 'Last 4 digits',
            icon: Icons.credit_card_outlined,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(4),
            ],
          ),
          const SizedBox(height: 10),

          // Nickname
          _FormField(
            controller: _nicknameCtrl,
            hint: _suggestedNickname,
            icon: Icons.label_outline,
          ),

          if (_error != null) ...[
            const SizedBox(height: 10),
            Text(_error!,
                style: AppText.caption.copyWith(color: Colors.redAccent)),
          ],

          const SizedBox(height: 14),
          PrimaryButton(
            label: _saving ? 'SAVING…' : 'SAVE & USE THIS CARD',
            icon: _saving ? null : Icons.check_rounded,
            onTap: _saving ? null : _submit,
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════
// SHARED SMALL WIDGETS
// ═══════════════════════════════════════════════════════════════

// ── Address card ──────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final Address address;
  final bool selected;
  final VoidCallback onTap;
  const _AddressCard(
      {required this.address, required this.selected, required this.onTap});

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
            borderRadius: BorderRadius.circular(AppRadius.base),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: selected ? AppColors.ink : AppColors.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.location_on_outlined,
                  size: 18,
                  color: selected ? Colors.white : AppColors.muted),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Text(address.label,
                        style: AppText.bodyS
                            .copyWith(fontWeight: FontWeight.w600)),
                    if (address.isDefault) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.sage.withValues(alpha: 0.2),
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
              const Icon(Icons.check_circle, size: 20, color: AppColors.ink),
          ]),
        ),
      );
}

// ── Payment card ──────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final Payment payment;
  final bool selected;
  final VoidCallback onTap;
  const _PaymentCard(
      {required this.payment, required this.selected, required this.onTap});

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
            borderRadius: BorderRadius.circular(AppRadius.base),
            border: Border.all(
              color: selected ? AppColors.ink : AppColors.line,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                color: selected ? AppColors.ink : AppColors.bg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                payment.brand == 'apple'
                    ? Icons.phone_iphone
                    : Icons.credit_card_outlined,
                size: 18,
                color: selected ? Colors.white : AppColors.muted,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(payment.label,
                      style: AppText.bodyS
                          .copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 2),
                  Text(payment.detail,
                      style:
                          AppText.caption.copyWith(color: AppColors.muted)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 20, color: AppColors.ink),
          ]),
        ),
      );
}

// ── "+ Add New" button ────────────────────────────────────────

class _AddNewButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddNewButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppRadius.base),
            border: Border.all(
                color: AppColors.lineStrong, style: BorderStyle.solid),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.add, size: 16, color: AppColors.muted),
              const SizedBox(width: 6),
              Text(label,
                  style: AppText.caption.copyWith(
                    color: AppColors.muted,
                    fontWeight: FontWeight.w600,
                  )),
            ],
          ),
        ),
      );
}

// ── Generic form field ────────────────────────────────────────

class _FormField extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;

  const _FormField({
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.bg,
          borderRadius: BorderRadius.circular(AppRadius.base),
          border: Border.all(color: AppColors.line),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          Icon(icon, size: 16, color: AppColors.muted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: AppText.bodyS,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppText.bodyS.copyWith(color: AppColors.muted),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 13),
              ),
            ),
          ),
        ]),
      );
}
