// ─────────────────────────────────────────────────────────────
// Notification Inbox — activity feed opened from the home bell.
// Generates notification items from live order data + welcome
// message. Read-only, no extra Firestore writes needed.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/order_manager.dart';
import '../data/models.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/routes/app_routes.dart';

// ── Data model ────────────────────────────────────────────────

class _NotifItem {
  final String  id;
  final String  title;
  final String  subtitle;
  final String  timeLabel;   // formatted display string
  final DateTime time;
  final IconData icon;
  final Color   iconBg;
  final Color   iconColor;
  final String? routeName;   // optional tap destination
  final Object? routeArgs;

  const _NotifItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.timeLabel,
    required this.time,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.routeName,
    this.routeArgs,
  });
}

// ── Screen ────────────────────────────────────────────────────

class NotificationInboxScreen extends StatelessWidget {
  const NotificationInboxScreen({super.key});

  // ── Build notification list from orders ───────────────────

  List<_NotifItem> _buildItems(List<Order> orders) {
    final items = <_NotifItem>[];
    final now   = DateTime.now();

    // Welcome notification (always shown, oldest)
    items.add(_NotifItem(
      id:         'welcome',
      title:      'Welcome to Drape',
      subtitle:   'Discover pieces worth keeping. Start exploring.',
      timeLabel:  'Earlier',
      time:       DateTime(2000), // pins to bottom
      icon:       Icons.auto_awesome_rounded,
      iconBg:     const Color(0xFFF5E6D3),
      iconColor:  const Color(0xFF9B6B4A),
    ));

    // Order-derived notifications
    for (final order in orders) {
      final shortId = order.id.length > 6
          ? '#DR-${order.id.substring(order.id.length - 6).toUpperCase()}'
          : '#DR-${order.id.toUpperCase()}';

      final itemsLine = order.itemNames.isNotEmpty
          ? order.itemNames.where((n) => n.isNotEmpty).take(2).join(', ')
          : '${order.itemIds.length} item${order.itemIds.length == 1 ? '' : 's'}';

      // Parse dateStr for approximate time comparison
      // dateStr format: "Jun 05, 2025" — use for group label
      final timeLabel = _relativeDateLabel(order.date, now);

      // Order placed
      items.add(_NotifItem(
        id:         'placed_${order.id}',
        title:      'Order Placed — $shortId',
        subtitle:   '$itemsLine · \$${order.total.toStringAsFixed(2)}',
        timeLabel:  timeLabel,
        time:       _parseDate(order.date),
        icon:       Icons.shopping_bag_outlined,
        iconBg:     const Color(0xFFEAF4EA),
        iconColor:  const Color(0xFF4CAF50),
        routeName:  AppRoutes.orderDetail,
        routeArgs:  order,
      ));

      // Status update (if not still Processing)
      if (order.status != 'Processing') {
        IconData statusIcon;
        Color    statusBg;
        Color    statusColor;
        String   statusTitle;

        switch (order.status) {
          case 'Shipped':
            statusIcon  = Icons.local_shipping_outlined;
            statusBg    = const Color(0xFFE8F0FE);
            statusColor = const Color(0xFF4285F4);
            statusTitle = 'Order Shipped — $shortId';
            break;
          case 'Delivered':
            statusIcon  = Icons.inventory_2_outlined;
            statusBg    = const Color(0xFFF5E6D3);
            statusColor = const Color(0xFF9B6B4A);
            statusTitle = 'Order Delivered — $shortId';
            break;
          default:
            statusIcon  = Icons.info_outline;
            statusBg    = AppColors.bg;
            statusColor = AppColors.muted;
            statusTitle = '${order.status} — $shortId';
        }

        items.add(_NotifItem(
          id:         'status_${order.id}',
          title:      statusTitle,
          subtitle:   itemsLine,
          timeLabel:  timeLabel,
          time:       _parseDate(order.date).add(const Duration(hours: 2)),
          icon:       statusIcon,
          iconBg:     statusBg,
          iconColor:  statusColor,
          routeName:  AppRoutes.orderDetail,
          routeArgs:  order,
        ));
      }
    }

    // Sort newest first
    items.sort((a, b) => b.time.compareTo(a.time));
    return items;
  }

  // ── Date helpers ──────────────────────────────────────────

  /// Parses "Jun 05, 2025" → DateTime (approximate; day precision is enough)
  static DateTime _parseDate(String dateStr) {
    try {
      const months = {
        'Jan': 1, 'Feb': 2, 'Mar': 3, 'Apr': 4,
        'May': 5, 'Jun': 6, 'Jul': 7, 'Aug': 8,
        'Sep': 9, 'Oct': 10, 'Nov': 11, 'Dec': 12,
      };
      final parts = dateStr.replaceAll(',', '').split(' ');
      final month = months[parts[0]] ?? 1;
      final day   = int.tryParse(parts[1]) ?? 1;
      final year  = int.tryParse(parts[2]) ?? DateTime.now().year;
      return DateTime(year, month, day);
    } catch (_) {
      return DateTime.now();
    }
  }

  static String _relativeDateLabel(String dateStr, DateTime now) {
    final date = _parseDate(dateStr);
    final diff = now.difference(date).inDays;
    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    if (diff <= 7) return 'This Week';
    return dateStr; // e.g. "Jun 05, 2025"
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final orders = context.watch<OrderManager>().orders;
    final items  = _buildItems(orders);

    // Group by timeLabel preserving order
    final groups = <String, List<_NotifItem>>{};
    for (final item in items) {
      groups.putIfAbsent(item.timeLabel, () => []).add(item);
    }

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
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(
                              color: Color(0x14000000),
                              blurRadius: 8,
                              offset: Offset(0, 2))],
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

            // ── Feed ─────────────────────────────────────────
            Expanded(
              child: items.isEmpty
                  ? _emptyState()
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(18, 0, 18, 40),
                      itemCount: _countRows(groups),
                      itemBuilder: (context, index) =>
                          _buildRow(context, index, groups),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Row builder (headers + items) ───────────────────────

  int _countRows(Map<String, List<_NotifItem>> groups) {
    // Each group contributes 1 header + N items
    return groups.entries
        .fold(0, (sum, e) => sum + 1 + e.value.length);
  }

  Widget _buildRow(BuildContext context, int index,
      Map<String, List<_NotifItem>> groups) {
    int cursor = 0;
    for (final entry in groups.entries) {
      if (index == cursor) {
        // Section header
        return _SectionHeader(label: entry.key);
      }
      cursor++;
      final itemIndex = index - cursor;
      if (itemIndex < entry.value.length) {
        return _NotifTile(
          item: entry.value[itemIndex],
          isLast: itemIndex == entry.value.length - 1,
          onTap: entry.value[itemIndex].routeName != null
              ? () => Navigator.pushNamed(
                    context,
                    entry.value[itemIndex].routeName!,
                    arguments: entry.value[itemIndex].routeArgs,
                  )
              : null,
        );
      }
      cursor += entry.value.length;
    }
    return const SizedBox.shrink();
  }

  Widget _emptyState() => Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72, height: 72,
              decoration: BoxDecoration(
                color: AppColors.surface,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.line),
              ),
              child: const Icon(Icons.notifications_none_rounded,
                  size: 32, color: AppColors.muted),
            ),
            const SizedBox(height: 20),
            Text('All caught up',
                style: AppText.titleM.copyWith(fontStyle: FontStyle.italic)),
            const SizedBox(height: 8),
            Text('Your activity will appear here.',
                style: AppText.bodyS.copyWith(color: AppColors.muted)),
          ],
        ),
      );
}

// ── Section header ────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 20, 0, 8),
        child: Text(
          label.toUpperCase(),
          style: AppText.eyebrow.copyWith(
              letterSpacing: 1.4, color: AppColors.muted),
        ),
      );
}

// ── Notification tile ─────────────────────────────────────────

class _NotifTile extends StatelessWidget {
  final _NotifItem item;
  final bool isLast;
  final VoidCallback? onTap;
  const _NotifTile(
      {required this.item, required this.isLast, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            color: Colors.transparent,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon badge
                Container(
                  width: 44, height: 44,
                  decoration: BoxDecoration(
                    color: item.iconBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(item.icon, size: 20, color: item.iconColor),
                ),
                const SizedBox(width: 14),

                // Text
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: AppText.bodyS.copyWith(
                                  fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (onTap != null)
                            const Icon(Icons.chevron_right,
                                size: 16, color: AppColors.muted),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        item.subtitle,
                        style: AppText.caption
                            .copyWith(color: AppColors.muted),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          const Divider(height: 1, indent: 58, color: AppColors.line),
      ],
    );
  }
}
