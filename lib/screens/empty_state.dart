// ─────────────────────────────────────────────────────────────
// Empty-state placeholder.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title, sub;
  final String? cta;
  final String? route;
  const EmptyState({super.key, required this.icon, required this.title, required this.sub, this.cta, this.route});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 60),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72, height: 72,
            decoration: BoxDecoration(
              color: AppColors.surface,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.line),
            ),
            child: Icon(icon, size: 28, color: AppColors.muted),
          ),
          const SizedBox(height: 20),
          Text(title, style: AppText.titleM.copyWith(fontStyle: FontStyle.italic)),
          const SizedBox(height: 6),
          Text(sub, style: AppText.bodyS.copyWith(color: AppColors.muted)),
          if (cta != null) ...[
            const SizedBox(height: 20),
            OutlinedButton(
              onPressed: () => route != null ? Navigator.pushNamed(context, route!) : null,
              child: Text(cta!.toUpperCase()),
            ),
          ],
        ],
      ),
    );
  }
}
