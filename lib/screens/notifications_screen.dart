// ─────────────────────────────────────────────────────────────
// Notifications screen — toggle push-notification preferences.
// Preferences are stored in users/{uid}.notifPrefs in Firestore.
// ─────────────────────────────────────────────────────────────

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});
  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  static const _keys = [
    'orderUpdates',
    'newArrivals',
    'salesOffers',
    'wishlistAlerts',
  ];

  static const _labels = {
    'orderUpdates':   'Order Updates',
    'newArrivals':    'New Arrivals',
    'salesOffers':    'Sales & Offers',
    'wishlistAlerts': 'Wishlist Alerts',
  };

  static const _subs = {
    'orderUpdates':   'Shipping and delivery notifications',
    'newArrivals':    'Be the first to see new pieces',
    'salesOffers':    'Exclusive discounts and events',
    'wishlistAlerts': 'Price drops on saved items',
  };

  final Map<String, bool> _prefs = {
    for (final k in _keys) k: true,
  };

  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPrefs();
  }

  Future<void> _loadPrefs() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      setState(() => _loading = false);
      return;
    }
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();
      if (doc.exists) {
        final raw =
            (doc.data()?['notifPrefs'] as Map<String, dynamic>?) ?? {};
        for (final k in _keys) {
          if (raw.containsKey(k)) _prefs[k] = (raw[k] as bool?) ?? true;
        }
      }
    } catch (_) {}
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _toggle(String key, bool val) async {
    setState(() => _prefs[key] = val);
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .set({'notifPrefs': Map<String, bool>.from(_prefs)},
              SetOptions(merge: true));
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
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
                  Text('Notifications',
                      style: AppText.titleS.copyWith(
                          fontWeight: FontWeight.w600, fontSize: 17)),
                ],
              ),
            ),

            if (_loading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
                  children: [
                    // ── Section label ──────────────────────────
                    Text('PUSH NOTIFICATIONS',
                        style: AppText.eyebrow
                            .copyWith(letterSpacing: 1.4)),
                    const SizedBox(height: 10),

                    // ── Toggles card ───────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.circular(AppRadius.lg),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Column(
                        children: List.generate(_keys.length, (i) {
                          final key = _keys[i];
                          final isLast = i == _keys.length - 1;
                          return Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                    16, 12, 12, 12),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 36,
                                      height: 36,
                                      decoration: BoxDecoration(
                                        color: AppColors.bg,
                                        borderRadius:
                                            BorderRadius.circular(
                                                10),
                                      ),
                                      child: Icon(_iconFor(key),
                                          size: 17,
                                          color: AppColors.ink),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(_labels[key]!,
                                              style: AppText.bodyS
                                                  .copyWith(
                                                      fontWeight:
                                                          FontWeight
                                                              .w600)),
                                          const SizedBox(height: 2),
                                          Text(_subs[key]!,
                                              style: AppText.caption
                                                  .copyWith(
                                                      color: AppColors
                                                          .muted)),
                                        ],
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: _prefs[key]!,
                                      onChanged: (v) =>
                                          _toggle(key, v),
                                      activeTrackColor: AppColors.ink,
                                      activeThumbColor: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                Divider(
                                    height: 1,
                                    indent: 64,
                                    color: AppColors.line),
                            ],
                          );
                        }),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Text(
                      'You can change these at any time. Some '
                      'order-related notifications may still be sent '
                      'for active orders regardless of this setting.',
                      style: AppText.caption
                          .copyWith(color: AppColors.muted),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  IconData _iconFor(String key) {
    switch (key) {
      case 'orderUpdates':
        return Icons.inventory_2_outlined;
      case 'newArrivals':
        return Icons.new_releases_outlined;
      case 'salesOffers':
        return Icons.local_offer_outlined;
      case 'wishlistAlerts':
        return Icons.favorite_border;
      default:
        return Icons.notifications_none;
    }
  }
}
