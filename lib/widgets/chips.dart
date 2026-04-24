// ─────────────────────────────────────────────────────────────
// Chips — pill-style with selectable/solid/outline variants.
// ─────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../theme/tokens.dart';
import '../theme/typography.dart';

class PillChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  final bool dense;
  const PillChip({super.key, required this.label, this.selected = false, this.onTap, this.dense = false});

  @override
  Widget build(BuildContext context) {
    final bg = selected ? AppColors.ink : Colors.transparent;
    final fg = selected ? Colors.white : AppColors.ink;
    final border = selected ? AppColors.ink : AppColors.lineStrong;

    return Material(
      color: bg,
      shape: StadiumBorder(side: BorderSide(color: border)),
      child: InkWell(
        customBorder: const StadiumBorder(),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: dense ? 12 : 16, vertical: dense ? 7 : 10),
          child: Text(label, style: AppText.label.copyWith(color: fg, fontSize: dense ? 10 : 11)),
        ),
      ),
    );
  }
}

class SizeChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;
  const SizeChip({super.key, required this.label, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.ink : AppColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        side: BorderSide(color: selected ? AppColors.ink : AppColors.lineStrong),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppRadius.md),
        onTap: onTap,
        child: Container(
          width: 52, height: 44,
          alignment: Alignment.center,
          child: Text(label, style: AppText.label.copyWith(
            color: selected ? Colors.white : AppColors.ink,
          )),
        ),
      ),
    );
  }
}

class ColorSwatch extends StatelessWidget {
  final Color color;
  final bool selected;
  final VoidCallback? onTap;
  final double size;
  const ColorSwatch({
    super.key,
    required this.color,
    this.selected = false,
    this.onTap,
    this.size = 36,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        width: size + 6,
        height: size + 6,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: selected ? AppColors.ink : AppColors.line,
            width: selected ? 1.8 : 1,
          ),
        ),
        padding: const EdgeInsets.all(3),
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color,
            border: Border.all(color: Colors.black.withOpacity(0.08)),
          ),
        ),
      ),
    );
  }
}
