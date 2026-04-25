import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import '../core/constants/app_spacing.dart';
import '../data/dummy_data.dart';
import '../shared/widgets/bottom_nav_bar.dart';
import '../shared/widgets/drape_scaffold.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final orders = DummyData.orders;
    return DrapeScaffold(
      tab: TabItem.profile,
      body: Column(
        children: [
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
                Text('Orders', style: AppText.titleS.copyWith(fontWeight: FontWeight.w600, fontSize: 17)),
              ],
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 120),
              itemCount: orders.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (_, i) {
                final o = orders[i];
                final statusColor = switch (o.status) {
                  'Delivered'  => const Color(0xFF4CAF50),
                  'Shipped'    => AppColors.accentInk,
                  _            => AppColors.muted,
                };
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.base),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(children: [
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(o.id, style: AppText.label),
                        const SizedBox(height: 2),
                        Text(o.date, style: AppText.caption.copyWith(color: AppColors.muted)),
                        const SizedBox(height: 2),
                        Text(o.address, style: AppText.caption.copyWith(color: AppColors.muted)),
                      ]),
                    ),
                    Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                      Text('\$${o.total.toStringAsFixed(2)}',
                          style: AppText.bodyS.copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(o.status,
                          style: AppText.micro.copyWith(color: statusColor, fontWeight: FontWeight.w700)),
                    ]),
                  ]),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
