// ─────────────────────────────────────────────────────────────
// Notifications screen — toggle push-notification preferences.
// State is owned by NotificationPrefsManager (Provider) so the
// home-screen bell icon stays in sync automatically.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/notification_prefs_manager.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final mgr = context.watch<NotificationPrefsManager>();

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

            if (mgr.loading)
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
                          final key    = _keys[i];
                          final isLast = i == _keys.length - 1;
                          final val    = mgr.valueOf(key);
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
                                            BorderRadius.circular(10),
                                      ),
                                      child: Icon(_iconFor(key),
                                          size: 17,
                                          color: val
                                              ? AppColors.ink
                                              : AppColors.muted),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(_labels[key]!,
                                              style: AppText.bodyS.copyWith(
                                                fontWeight: FontWeight.w600,
                                                color: val
                                                    ? AppColors.ink
                                                    : AppColors.muted,
                                              )),
                                          const SizedBox(height: 2),
                                          Text(_subs[key]!,
                                              style: AppText.caption
                                                  .copyWith(
                                                      color: AppColors.muted)),
                                        ],
                                      ),
                                    ),
                                    Switch.adaptive(
                                      value: val,
                                      onChanged: (v) =>
                                          context.read<NotificationPrefsManager>()
                                              .toggle(key, v),
                                      activeTrackColor: AppColors.ink,
                                      activeThumbColor: Colors.white,
                                    ),
                                  ],
                                ),
                              ),
                              if (!isLast)
                                const Divider(
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

  static IconData _iconFor(String key) {
    switch (key) {
      case 'orderUpdates':   return Icons.inventory_2_outlined;
      case 'newArrivals':    return Icons.new_releases_outlined;
      case 'salesOffers':    return Icons.local_offer_outlined;
      case 'wishlistAlerts': return Icons.favorite_border;
      default:               return Icons.notifications_none;
    }
  }
}
