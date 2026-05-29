// ─────────────────────────────────────────────────────────────
// Addresses screen — list saved addresses, add new, delete.
// All changes write through UserProfileManager → Firestore.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/models.dart';
import '../data/user_profile_manager.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../shared/widgets/primary_button.dart';

class AddressesScreen extends StatelessWidget {
  const AddressesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileManager>();
    final addresses = profile.addresses;

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
                  Text('Addresses',
                      style: AppText.titleS.copyWith(
                          fontWeight: FontWeight.w600, fontSize: 17)),
                ],
              ),
            ),

            // ── List ────────────────────────────────────────
            Expanded(
              child: addresses.isEmpty
                  ? _emptyState()
                  : ListView.separated(
                      padding:
                          const EdgeInsets.fromLTRB(18, 4, 18, 120),
                      itemCount: addresses.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(height: 12),
                      itemBuilder: (_, i) => _AddressCard(
                        address: addresses[i],
                        onDelete: () => _confirmDelete(
                            context, profile, i,
                            label: addresses[i].label),
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
            label: 'ADD NEW ADDRESS',
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
      builder: (_) => _AddAddressSheet(profile: profile),
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
        title: Text('Remove address',
            style: AppText.titleS
                .copyWith(fontWeight: FontWeight.w600)),
        content: Text(
            'Remove "$label" from your saved addresses?',
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
      await profile.removeAddress(index);
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
              child: const Icon(Icons.location_on_outlined,
                  size: 28, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Text('No saved addresses',
                style: AppText.titleM
                    .copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text('Add your first delivery address below',
                style:
                    AppText.bodyS.copyWith(color: AppColors.muted)),
          ],
        ),
      );
}

// ── Address card ─────────────────────────────────────────────

class _AddressCard extends StatelessWidget {
  final Address address;
  final VoidCallback onDelete;
  const _AddressCard(
      {required this.address, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
            color: address.isDefault
                ? AppColors.ink
                : AppColors.line,
            width: address.isDefault ? 1.5 : 1),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: address.isDefault
                  ? AppColors.ink
                  : AppColors.bg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.location_on_outlined,
                size: 18,
                color: address.isDefault
                    ? Colors.white
                    : AppColors.muted),
          ),
          const SizedBox(width: 14),
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
                            .withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(
                            AppRadius.xs),
                      ),
                      child: Text('DEFAULT',
                          style: AppText.micro.copyWith(
                              color: AppColors.sage,
                              fontSize: 8,
                              fontWeight: FontWeight.w700)),
                    ),
                  ],
                ]),
                const SizedBox(height: 3),
                Text(address.line1,
                    style: AppText.caption
                        .copyWith(color: AppColors.muted)),
                Text(address.line2,
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

// ── Add Address bottom sheet ──────────────────────────────────

class _AddAddressSheet extends StatefulWidget {
  final UserProfileManager profile;
  const _AddAddressSheet({required this.profile});

  @override
  State<_AddAddressSheet> createState() => _AddAddressSheetState();
}

class _AddAddressSheetState extends State<_AddAddressSheet> {
  final _line1Ctrl = TextEditingController();
  final _line2Ctrl = TextEditingController();
  final _customLabelCtrl = TextEditingController();

  String _selectedLabel = 'Home';
  bool _isDefault = false;
  bool _saving = false;
  String? _error;

  static const _labelPresets = ['Home', 'Work', 'Other'];

  @override
  void dispose() {
    _line1Ctrl.dispose();
    _line2Ctrl.dispose();
    _customLabelCtrl.dispose();
    super.dispose();
  }

  String get _effectiveLabel => _selectedLabel == 'Other'
      ? _customLabelCtrl.text.trim()
      : _selectedLabel;

  Future<void> _save() async {
    final line1 = _line1Ctrl.text.trim();
    final line2 = _line2Ctrl.text.trim();
    final label = _effectiveLabel;

    if (label.isEmpty) {
      setState(() => _error = 'Please enter an address label.');
      return;
    }
    if (line1.isEmpty) {
      setState(() => _error = 'Please enter a street address.');
      return;
    }
    if (line2.isEmpty) {
      setState(() =>
          _error = 'Please enter city, state and postcode.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await widget.profile.addAddress(Address(
        label,
        line1,
        line2,
        isDefault: _isDefault,
      ));
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
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
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

            Text('New Address',
                style: AppText.titleS.copyWith(
                    fontWeight: FontWeight.w600, fontSize: 18)),
            const SizedBox(height: 20),

            // ── Label chips ─────────────────────────────────
            Text('LABEL',
                style: AppText.eyebrow
                    .copyWith(color: AppColors.muted)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: _labelPresets.map((l) {
                final active = l == _selectedLabel;
                return GestureDetector(
                  onTap: () =>
                      setState(() => _selectedLabel = l),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
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
                    child: Text(l,
                        style: AppText.caption.copyWith(
                            color: active
                                ? Colors.white
                                : AppColors.textSecondary,
                            fontWeight: active
                                ? FontWeight.w600
                                : FontWeight.w400)),
                  ),
                );
              }).toList(),
            ),

            // Custom label field (only when "Other" is selected)
            if (_selectedLabel == 'Other') ...[
              const SizedBox(height: 12),
              _SheetField(
                  label: 'CUSTOM LABEL',
                  controller: _customLabelCtrl,
                  hint: 'e.g. Gym, Parent\'s house…'),
            ],

            const SizedBox(height: 18),

            // ── Address fields ───────────────────────────────
            _SheetField(
              label: 'STREET ADDRESS',
              controller: _line1Ctrl,
              hint: '123 Main Street, Apt 4B',
              keyboardType: TextInputType.streetAddress,
            ),
            const SizedBox(height: 14),
            _SheetField(
              label: 'CITY, STATE / POSTCODE',
              controller: _line2Ctrl,
              hint: 'New York, NY 10001',
            ),
            const SizedBox(height: 18),

            // ── Default toggle ───────────────────────────────
            GestureDetector(
              onTap: () =>
                  setState(() => _isDefault = !_isDefault),
              child: Row(children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: _isDefault
                        ? AppColors.ink
                        : AppColors.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                        color: _isDefault
                            ? AppColors.ink
                            : AppColors.lineStrong),
                  ),
                  child: _isDefault
                      ? const Icon(Icons.check,
                          size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 10),
                Text('Set as default address',
                    style: AppText.bodyS),
              ]),
            ),

            // ── Error ────────────────────────────────────────
            if (_error != null) ...[
              const SizedBox(height: 14),
              Text(_error!,
                  style: AppText.caption
                      .copyWith(color: Colors.redAccent)),
            ],

            const SizedBox(height: 24),
            PrimaryButton(
              label: _saving ? 'SAVING…' : 'SAVE ADDRESS',
              onTap: _saving ? null : _save,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared form field ─────────────────────────────────────────

class _SheetField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  const _SheetField({
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
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
