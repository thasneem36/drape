import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_spacing.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool expanded;
  final bool dark;
  const PrimaryButton({super.key, required this.label, this.onTap, this.icon, this.expanded = true, this.dark = true});

  @override
  Widget build(BuildContext context) {
    final bg = dark ? AppColors.ink : AppColors.surface;
    final fg = dark ? Colors.white : AppColors.ink;
    final child = Material(
      color: bg,
      borderRadius: BorderRadius.circular(AppRadius.base),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.base),
        child: Container(
          height: 52,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.base),
            boxShadow: AppShadows.cta,
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(label, style: AppText.label.copyWith(color: fg)),
              if (icon != null) ...[const SizedBox(width: 10), Icon(icon, color: fg, size: 16)],
            ],
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class GhostButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback? onTap;
  final bool expanded;
  const GhostButton({super.key, required this.label, this.icon, this.onTap, this.expanded = true});

  @override
  Widget build(BuildContext context) {
    final child = Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: AppColors.lineStrong),
        borderRadius: BorderRadius.circular(AppRadius.base),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.base),
        child: SizedBox(
          height: 48,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[Icon(icon, size: 16, color: AppColors.ink), const SizedBox(width: 10)],
                Text(label, style: AppText.label),
              ],
            ),
          ),
        ),
      ),
    );
    return expanded ? SizedBox(width: double.infinity, child: child) : child;
  }
}

class IconPill extends StatelessWidget {
  final IconData icon;
  final VoidCallback? onTap;
  final Color? bg;
  final Color? fg;
  final double size;
  final String? badge;
  const IconPill({super.key, required this.icon, this.onTap, this.bg, this.fg, this.size = 44, this.badge});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size, height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Material(
            color: bg ?? AppColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              side: const BorderSide(color: AppColors.line),
            ),
            child: InkWell(
              customBorder: const CircleBorder(),
              onTap: onTap,
              child: Icon(icon, size: 18, color: fg ?? AppColors.ink),
            ),
          ),
          if (badge != null)
            Positioned(
              top: -2, right: -2,
              child: Container(
                constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                  border: Border.all(color: AppColors.surface, width: 1.5),
                ),
                alignment: Alignment.center,
                child: Text(badge!, style: AppText.micro.copyWith(color: Colors.white, fontSize: 9)),
              ),
            ),
        ],
      ),
    );
  }
}
