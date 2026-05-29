// ─────────────────────────────────────────────────────────────
// Privacy & Security screen — change password (Firebase reset
// email), sign out all devices, data info, delete account.
// ─────────────────────────────────────────────────────────────

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../core/routes/app_routes.dart';
import '../services/auth_service.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.only(bottom: 48),
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
                  Text('Privacy & Security',
                      style: AppText.titleS.copyWith(
                          fontWeight: FontWeight.w600, fontSize: 17)),
                ],
              ),
            ),

            // ── ACCOUNT SECURITY ──────────────────────────────
            _SectionLabel('ACCOUNT SECURITY'),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _MenuCard(
                items: [
                  _MenuItem(
                    icon: Icons.lock_reset_outlined,
                    label: 'Change Password',
                    sub: 'Send a reset link to your email',
                    onTap: () => _sendPasswordReset(context),
                  ),
                  _MenuItem(
                    icon: Icons.logout,
                    label: 'Sign Out All Devices',
                    sub: 'Ends your current session',
                    onTap: () {
                      context.read<AuthService>().signOut().then((_) {
                        if (!context.mounted) return;
                        Navigator.of(context).pushNamedAndRemoveUntil(
                            AppRoutes.onboarding, (_) => false);
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── YOUR DATA ─────────────────────────────────────
            _SectionLabel('YOUR DATA'),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _InfoCard(
                items: const [
                  _InfoRow(
                    Icons.storage_outlined,
                    'What we store',
                    'Your name, email, addresses, payment methods, '
                        'orders and wishlist items.',
                  ),
                  _InfoRow(
                    Icons.share_outlined,
                    'Data sharing',
                    'We never sell your personal data to '
                        'third parties.',
                  ),
                  _InfoRow(
                    Icons.security_outlined,
                    'Security',
                    'All data is encrypted in transit and at rest '
                        'via Google Firebase.',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── DANGER ZONE ───────────────────────────────────
            _SectionLabel('DANGER ZONE'),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: _MenuCard(
                items: [
                  _MenuItem(
                    icon: Icons.person_remove_outlined,
                    label: 'Delete Account',
                    sub: 'Permanently removes all your data',
                    onTap: () => _confirmDeleteAccount(context),
                    destructive: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ───────────────────────────────────────────────

  Future<void> _sendPasswordReset(BuildContext context) async {
    final email =
        FirebaseAuth.instance.currentUser?.email;
    if (email == null) return;
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: email);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.ink,
          content: Text(
            'Reset link sent to $email',
            style: AppText.bodyS.copyWith(color: Colors.white),
          ),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      _showErrorSnack(context, 'Could not send reset email.');
    }
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg)),
        title: Text('Delete account?',
            style: AppText.titleS
                .copyWith(fontWeight: FontWeight.w600)),
        content: Text(
          'This will permanently delete your account, all orders '
          'and saved data. This action cannot be undone.',
          style: AppText.bodyS.copyWith(color: AppColors.muted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style:
                    AppText.label.copyWith(color: AppColors.muted)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Delete',
                style: AppText.label
                    .copyWith(color: Colors.redAccent)),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    try {
      await FirebaseAuth.instance.currentUser?.delete();
      if (!context.mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
          AppRoutes.onboarding, (_) => false);
    } on FirebaseAuthException catch (e) {
      if (!context.mounted) return;
      _showErrorSnack(
        context,
        e.code == 'requires-recent-login'
            ? 'Please sign out and back in before deleting.'
            : 'Could not delete account. Please try again.',
      );
    }
  }

  void _showErrorSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.error,
        content:
            Text(msg, style: AppText.bodyS.copyWith(color: Colors.white)),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);
  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 0, 18, 0),
        child: Text(text,
            style: AppText.eyebrow.copyWith(letterSpacing: 1.4)),
      );
}

class _MenuItem {
  final IconData icon;
  final String label, sub;
  final VoidCallback onTap;
  final bool destructive;
  const _MenuItem({
    required this.icon,
    required this.label,
    required this.sub,
    required this.onTap,
    this.destructive = false,
  });
}

class _MenuCard extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuCard({required this.items});

  @override
  Widget build(BuildContext context) => Container(
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
                InkWell(
                  onTap: item.onTap,
                  borderRadius: BorderRadius.vertical(
                    top: i == 0
                        ? const Radius.circular(AppRadius.lg)
                        : Radius.zero,
                    bottom: isLast
                        ? const Radius.circular(AppRadius.lg)
                        : Radius.zero,
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.bg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(item.icon,
                              size: 18,
                              color: item.destructive
                                  ? Colors.redAccent
                                  : AppColors.ink),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(item.label,
                                  style: AppText.bodyS.copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: item.destructive
                                        ? Colors.redAccent
                                        : AppColors.ink,
                                  )),
                              const SizedBox(height: 2),
                              Text(item.sub,
                                  style: AppText.caption.copyWith(
                                      color: AppColors.muted)),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right,
                            size: 18, color: AppColors.muted),
                      ],
                    ),
                  ),
                ),
                if (!isLast)
                  Divider(
                      height: 1, indent: 64, color: AppColors.line),
              ],
            );
          }),
        ),
      );
}

class _InfoRow {
  final IconData icon;
  final String title, body;
  const _InfoRow(this.icon, this.title, this.body);
}

class _InfoCard extends StatelessWidget {
  final List<_InfoRow> items;
  const _InfoCard({required this.items});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.line),
        ),
        child: Column(
          children: List.generate(items.length, (i) {
            final row = items[i];
            return Padding(
              padding: EdgeInsets.only(top: i > 0 ? 14 : 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(row.icon, size: 16, color: AppColors.muted),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.title,
                            style: AppText.bodyS.copyWith(
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 3),
                        Text(row.body,
                            style: AppText.caption
                                .copyWith(color: AppColors.muted)),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      );
}
