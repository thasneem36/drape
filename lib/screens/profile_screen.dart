// ─────────────────────────────────────────────────────────────
// Profile screen — user data from Firebase Auth + Firestore via
// UserProfileManager.  Edits are saved back to Firestore.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/order_manager.dart';
import '../data/user_profile_manager.dart';
import '../data/wishlist_manager.dart';
import '../services/auth_service.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/routes/app_routes.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/drape_scaffold.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _editing = false;
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  late final TextEditingController _phoneCtrl;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController();
    _emailCtrl = TextEditingController();
    _phoneCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<UserProfileManager>();
    final wlCount = context.watch<WishlistManager>().count;
    final orderCount = context.watch<OrderManager>().count;

    final nameForInitials = _editing ? _nameCtrl.text : profile.name;
    final initials = nameForInitials.trim().isEmpty
        ? 'u'
        : nameForInitials
            .trim()
            .split(' ')
            .map((w) => w[0])
            .take(2)
            .join()
            .toLowerCase();

    return DrapeScaffold(
      tab: TabItem.profile,
      body: ListView(
        padding: const EdgeInsets.only(bottom: 120),
        children: [
          // ── Top bar ─────────────────────────────────────────
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
                        boxShadow: [BoxShadow(color: Color(0x14000000), blurRadius: 8, offset: Offset(0, 2))],
                      ),
                      child: const Icon(Icons.arrow_back, size: 20, color: AppColors.ink),
                    ),
                  ),
                ),
                Text('Account',
                    style: AppText.titleS.copyWith(fontWeight: FontWeight.w600, fontSize: 17)),
                if (_editing)
                  Align(
                    alignment: Alignment.centerRight,
                    child: GestureDetector(
                      onTap: () async {
                        await context.read<UserProfileManager>().save(
                          name: _nameCtrl.text.trim(),
                          email: _emailCtrl.text.trim(),
                          phone: _phoneCtrl.text.trim(),
                        );
                        if (mounted) setState(() => _editing = false);
                      },
                      child: Text('DONE',
                          style: AppText.label.copyWith(color: AppColors.accentInk, fontSize: 12)),
                    ),
                  ),
              ],
            ),
          ),

          // ── Dark hero card ───────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 24),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1A1816),
                borderRadius: BorderRadius.circular(20),
              ),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  Positioned(top: -30, right: -30,
                    child: Container(width: 140, height: 140,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06), width: 1)),
                    ),
                  ),
                  Positioned(top: 20, right: 20,
                    child: Container(width: 80, height: 80,
                      decoration: BoxDecoration(shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.04), width: 1)),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 52, height: 52,
                              decoration: const BoxDecoration(color: Color(0xFF8B6347), shape: BoxShape.circle),
                              alignment: Alignment.center,
                              child: Text(initials,
                                  style: AppText.titleS.copyWith(
                                      color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: _editing ? _editFields() : _displayInfo(profile),
                            ),
                            if (!_editing)
                              GestureDetector(
                                onTap: () {
                                  _nameCtrl.text  = profile.name;
                                  _emailCtrl.text = profile.email;
                                  _phoneCtrl.text = profile.phone;
                                  setState(() => _editing = true);
                                },
                                child: Container(
                                  width: 32, height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.08),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.edit_outlined, size: 15, color: Colors.white70),
                                ),
                              ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        decoration: BoxDecoration(color: const Color(0xFF2C251F), borderRadius: BorderRadius.circular(12)),
                        child: IntrinsicHeight(
                          child: Row(
                            children: [
                              _StatBox('$orderCount', 'ORDERS'),
                              _Divider(),
                              _StatBox('$wlCount', 'SAVED'),
                              _Divider(),
                              const _StatBox('850', 'POINTS'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── YOUR ACCOUNT ────────────────────────────────────
          _SectionLabel('YOUR ACCOUNT'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _MenuCard(items: [
              _MenuItem(
                icon: Icons.inventory_2_outlined,
                label: 'Orders',
                sub: '$orderCount orders',
                onTap: () => Navigator.pushNamed(context, AppRoutes.orderHistory),
              ),
              _MenuItem(
                icon: Icons.favorite_border,
                label: 'Saved pieces',
                sub: '$wlCount items',
                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.wishlist),
              ),
              _MenuItem(
                icon: Icons.location_on_outlined,
                label: 'Addresses',
                sub: profile.addresses.isEmpty
                    ? 'None saved'
                    : profile.addresses.map((a) => a.label).join(', '),
                onTap: () => Navigator.pushNamed(context, AppRoutes.addresses),
              ),
              _MenuItem(
                icon: Icons.credit_card_outlined,
                label: 'Payment methods',
                sub: profile.payments.isEmpty
                    ? 'None saved'
                    : profile.payments.first.detail,
                onTap: () => Navigator.pushNamed(context, AppRoutes.payments),
              ),
            ]),
          ),

          const SizedBox(height: 24),

          // ── SETTINGS ────────────────────────────────────────
          _SectionLabel('SETTINGS'),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: _MenuCard(items: [
              _MenuItem(
                icon: Icons.notifications_none_rounded,
                label: 'Notifications',
                sub: 'Personalised drops',
                onTap: () => Navigator.pushNamed(
                    context, AppRoutes.notifications),
              ),
              _MenuItem(
                icon: Icons.lock_outline,
                label: 'Privacy & Security',
                sub: 'Manage your data',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.privacy),
              ),
              _MenuItem(
                icon: Icons.help_outline_rounded,
                label: 'Help & Support',
                sub: 'FAQs and contact',
                onTap: () =>
                    Navigator.pushNamed(context, AppRoutes.help),
              ),
              _MenuItem(
                icon: Icons.logout,
                label: 'Sign Out',
                sub: profile.email,
                onTap: () {
                  context.read<AuthService>().signOut().then((_) {
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.onboarding, (_) => false);
                  });
                },
                destructive: true,
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _displayInfo(UserProfileManager profile) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('STUDIO MEMBER',
              style: AppText.micro.copyWith(
                  color: const Color(0xFFBFA58A), letterSpacing: 1.4, fontSize: 9)),
          const SizedBox(height: 4),
          Text(profile.name.isEmpty ? '—' : profile.name,
              style: AppText.titleM.copyWith(
                  color: Colors.white, fontStyle: FontStyle.italic, fontSize: 20)),
          const SizedBox(height: 2),
          Text(profile.email,
              style: AppText.caption.copyWith(color: Colors.white.withValues(alpha: 0.5))),
          if (profile.phone.isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(profile.phone,
                style: AppText.caption.copyWith(color: Colors.white.withValues(alpha: 0.4))),
          ],
        ],
      );

  Widget _editFields() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DarkField(label: 'NAME',  controller: _nameCtrl, onChanged: (_) => setState(() {})),
          const SizedBox(height: 8),
          _DarkField(label: 'EMAIL', controller: _emailCtrl),
          const SizedBox(height: 8),
          _DarkField(label: 'PHONE', controller: _phoneCtrl),
        ],
      );
}

// ── Widgets ──────────────────────────────────────────────────

class _DarkField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  const _DarkField({required this.label, required this.controller, this.onChanged});
  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppText.micro.copyWith(
              color: const Color(0xFFBFA58A), letterSpacing: 1.2, fontSize: 8)),
          const SizedBox(height: 4),
          Container(
            height: 36,
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: AppText.bodyS.copyWith(color: Colors.white, fontSize: 13),
              decoration: const InputDecoration(
                border: InputBorder.none, isDense: true,
                contentPadding: EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      );
}

class _StatBox extends StatelessWidget {
  final String value, label;
  const _StatBox(this.value, this.label);
  @override
  Widget build(BuildContext context) => Expanded(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14),
          child: Column(children: [
            Text(value, style: AppText.titleM.copyWith(
                color: Colors.white, fontWeight: FontWeight.w700, fontSize: 22)),
            const SizedBox(height: 2),
            Text(label, style: AppText.micro.copyWith(
                color: Colors.white.withValues(alpha: 0.45), letterSpacing: 1.2, fontSize: 9)),
          ]),
        ),
      );
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(width: 1, color: Colors.white.withValues(alpha: 0.08));
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
        child: Text(text, style: AppText.eyebrow.copyWith(letterSpacing: 1.4)),
      );
}

class _MenuItem {
  final IconData icon;
  final String label, sub;
  final VoidCallback onTap;
  final bool destructive;
  const _MenuItem({
    required this.icon, required this.label, required this.sub,
    required this.onTap, this.destructive = false,
  });
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});
  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            final item = items[i];
            final isLast = i == items.length - 1;
            return Column(
              children: [
                InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: i == 0 ? const Radius.circular(16) : Radius.zero,
                    bottom: isLast ? const Radius.circular(16) : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.bg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(item.icon, size: 18,
                            color: item.destructive ? Colors.redAccent : AppColors.ink),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(item.label, style: AppText.bodyS.copyWith(
                              fontWeight: FontWeight.w600,
                              color: item.destructive ? Colors.redAccent : AppColors.ink,
                            )),
                            const SizedBox(height: 2),
                            Text(item.sub, style: AppText.caption.copyWith(color: AppColors.muted)),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 18, color: AppColors.muted),
                    ]),
                  ),
                ),
                if (!isLast)
                  Divider(height: 1, indent: 64, endIndent: 0, color: AppColors.line),
              ],
            );
          }),
        ),
      );
}
