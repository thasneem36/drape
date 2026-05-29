// ─────────────────────────────────────────────────────────────
// Payments screen — list saved payment methods, add new, delete.
// All changes write through UserProfileManager → Firestore.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../data/user_profile_manager.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../shared/widgets/primary_button.dart';

class PaymentsScreen extends StatelessWidget {
  const PaymentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileManager>();
    final payments = profile.payments;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            // ── App bar ─────────────────────────────────────
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
                  Text('Payment Methods',
                      style: AppText.titleS.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 17)),
                ],
              ),
            ),

            // ── List ────────────────────────────────────────
            Expanded(
              child: payments.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(18, 4, 18, 120),
                      itemCount: payments.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (_, i) => _PaymentCard(
                        payment: payments[i],
                        onDelete: () => _confirmDelete(
                            context, profile, i,
                            label: payments[i].label),
                      ),
                    ),
            ),
          ],
        ),
      ),

      // ── Add button ────────────────────────────────────────
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 16),
          child: PrimaryButton(
            label: 'ADD PAYMENT METHOD',
            icon: Icons.add,
            onTap: () => _showAddSheet(context, profile),
          ),
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  void _showAddSheet(
      BuildContext context, UserProfileManager profile) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddPaymentSheet(profile: profile),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    UserProfileManager profile,
    int index, {
    required String label,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Remove payment method',
            style: AppText.titleS
                .copyWith(fontWeight: FontWeight.w600)),
        content: Text('Remove "$label"?',
            style: AppText.bodyS
                .copyWith(color: AppColors.muted)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: AppText.label
                    .copyWith(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Remove',
                style: AppText.label
                    .copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await profile.removePayment(index);
    }
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
              child: const Icon(Icons.credit_card_outlined,
                  size: 28, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Text('No payment methods',
                style: AppText.titleM
                    .copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text('Add a card to speed up checkout',
                style:
                    AppText.bodyS.copyWith(color: AppColors.muted)),
          ],
        ),
      );
}

// ── Payment card ──────────────────────────────────────────────

class _PaymentCard extends StatelessWidget {
  final Payment payment;
  final VoidCallback onDelete;
  const _PaymentCard(
      {required this.payment, required this.onDelete});

  IconData get _icon {
    switch (payment.brand.toLowerCase()) {
      case 'apple':
        return Icons.phone_iphone;
      case 'amex':
        return Icons.credit_card;
      default:
        return Icons.credit_card_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.line),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(_icon, size: 18, color: AppColors.ink),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(payment.label,
                    style: AppText.bodyS.copyWith(
                        fontWeight: FontWeight.w600)),
                const SizedBox(height: 3),
                Text(payment.detail,
                    style: AppText.caption
                        .copyWith(color: AppColors.muted)),
              ],
            ),
          ),
          GestureDetector(
            onTap: onDelete,
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: Colors.redAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.delete_outline,
                  size: 16, color: Colors.redAccent),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Add Payment bottom sheet ──────────────────────────────────

class _AddPaymentSheet extends StatefulWidget {
  final UserProfileManager profile;
  const _AddPaymentSheet({required this.profile});

  @override
  State<_AddPaymentSheet> createState() => _AddPaymentSheetState();
}

class _AddPaymentSheetState extends State<_AddPaymentSheet> {
  final _last4Ctrl = TextEditingController();
  final _expiryCtrl = TextEditingController();

  String _brand = 'visa';
  bool _saving = false;
  String? _error;

  static const _brands = [
    ('visa',       'Visa',        Icons.credit_card_outlined),
    ('mastercard', 'Mastercard',  Icons.credit_card_outlined),
    ('amex',       'Amex',        Icons.credit_card),
    ('apple',      'Apple Pay',   Icons.phone_iphone),
  ];

  bool get _isDigitalWallet => _brand == 'apple';

  @override
  void dispose() {
    _last4Ctrl.dispose();
    _expiryCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final last4 = _last4Ctrl.text.trim();
    final expiry = _expiryCtrl.text.trim();

    if (!_isDigitalWallet) {
      if (last4.length != 4) {
        setState(
            () => _error = 'Enter the last 4 digits of your card.');
        return;
      }
      if (expiry.isEmpty) {
        setState(() => _error = 'Enter the card expiry (MM/YY).');
        return;
      }
    }

    final brandName =
        _brands.firstWhere((b) => b.$1 == _brand).$2;

    final String label;
    final String detail;

    if (_isDigitalWallet) {
      label = 'Apple Pay';
      detail = 'Touch ID or Face ID';
    } else {
      label = '$brandName Card';
      detail = 'ending in $last4  ·  exp $expiry';
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.profile.addPayment(
          Payment(label, detail, _brand));
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Could not save. Please try again.';
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.bg,
        borderRadius:
            BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(24, 8, 24, 24 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),

            Text('New Payment Method',
                style: AppText.titleS.copyWith(
                    fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 20),

            // ── Card type chips ──────────────────────────────
            Text('TYPE',
                style: AppText.eyebrow
                    .copyWith(color: AppColors.muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _brands.map((b) {
                final active = b.$1 == _brand;
                return GestureDetector(
                  onTap: () => setState(() => _brand = b.$1),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.ink
                          : AppColors.surface,
                      borderRadius:
                          BorderRadius.circular(AppRadius.pill),
                      border: Border.all(
                          color: active
                              ? AppColors.ink
                              : AppColors.line),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(b.$3,
                            size: 14,
                            color: active
                                ? Colors.white
                                : AppColors.muted),
                        const SizedBox(width: 6),
                        Text(b.$2,
                            style: AppText.caption.copyWith(
                                color: active
                                    ? Colors.white
                                    : AppColors.textSecondary,
                                fontWeight: active
                                    ? FontWeight.w600
                                    : FontWeight.w400)),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),

            // ── Card details (hidden for Apple Pay) ──────────
            if (!_isDigitalWallet) ...[
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: _SheetField(
                      label: 'LAST 4 DIGITS',
                      controller: _last4Ctrl,
                      hint: '4242',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(4),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _SheetField(
                      label: 'EXPIRY',
                      controller: _expiryCtrl,
                      hint: 'MM/YY',
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[\d/]')),
                        LengthLimitingTextInputFormatter(5),
                        _ExpiryFormatter(),
                      ],
                    ),
                  ),
                ],
              ),
            ] else ...[
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius:
                      BorderRadius.circular(AppRadius.base),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(children: [
                  const Icon(Icons.info_outline,
                      size: 15, color: AppColors.muted),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Apple Pay uses Touch ID or Face ID. No card details needed.',
                      style: AppText.caption
                          .copyWith(color: AppColors.muted),
                    ),
                  ),
                ]),
              ),
            ],

            // ── Error ────────────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!,
                  style: AppText.caption
                      .copyWith(color: Colors.redAccent)),
            ],

            const SizedBox(height: 24),
            PrimaryButton(
              label: _saving ? 'SAVING…' : 'SAVE PAYMENT METHOD',
              onTap: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Expiry auto-formatter (inserts "/" after MM) ───────────────

class _ExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue old, TextEditingValue val) {
    var text = val.text.replaceAll('/', '');
    if (text.length > 2) {
      text = '${text.substring(0, 2)}/${text.substring(2)}';
    }
    return val.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

// ── Shared form field ─────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  const _SheetField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  AppText.eyebrow.copyWith(color: AppColors.muted)),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius:
                  BorderRadius.circular(AppRadius.base),
              border: Border.all(color: AppColors.line),
            ),
            padding:
                const EdgeInsets.symmetric(horizontal: 14),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              inputFormatters: inputFormatters,
              style: AppText.bodyS,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppText.bodyS
                    .copyWith(color: AppColors.muted),
                border: InputBorder.none,
                isDense: true,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ],
      );
}
