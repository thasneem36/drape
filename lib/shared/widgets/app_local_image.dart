import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_spacing.dart';

class ProductArt extends StatelessWidget {
  final Product product;
  final double? fontSize;
  final BorderRadiusGeometry? borderRadius;
  final bool showLabel;
  const ProductArt({super.key, required this.product, this.fontSize, this.borderRadius, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    final tint  = product.tint;
    final start = Color(tint.first);
    final end   = Color(tint.last);
    final fs    = fontSize ?? 18;

    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.circular(AppRadius.base),
      child: Stack(
        fit: StackFit.expand,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [start, end], begin: Alignment.topLeft, end: Alignment.bottomRight),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.06), Colors.transparent, Colors.black.withOpacity(0.14)],
                begin: Alignment.topLeft, end: Alignment.bottomRight, stops: const [0, 0.55, 1],
              ),
            ),
          ),
          if (showLabel)
            Padding(
              padding: const EdgeInsets.all(AppSpacing.s16),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  (product.art.isEmpty ? product.name : product.art).toLowerCase(),
                  style: GoogleFonts.fraunces(
                    fontStyle: FontStyle.italic, color: Colors.white.withOpacity(0.85),
                    fontSize: fs, fontWeight: FontWeight.w400, height: 1.1, letterSpacing: -0.3,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
